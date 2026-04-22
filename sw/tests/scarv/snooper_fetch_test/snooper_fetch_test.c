// Copyright 2026 Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// snooper_fetch_test.c  –  Ibex side
//
// PURPOSE
//   The snooper logs every branch/jump taken by CVA6 while executing the dummy
//   region, recording (PC_SRC, PC_DST) per edge.  Between two consecutive snooper
//   entries, CVA6 executed a straight-line basic block:
//
//     [prev_PC_DST  ..  PC_SRC]   ← all instructions in this span
//
//   Ibex reconstructs and fetches every basic block by issuing data-port LOADs
//   to each 4-byte-aligned address in the range [prev_dst, pc_src_l] (inclusive).
//   After consuming an entry, prev_dst is updated to pc_dst_l for the next block.
//   This exercises the full path:
//     CVA6 executes basic block → snooper logs branch edge → ibex fetches the
//     instructions that CVA6 just ran.
//
// WHY DMA?
//   The stress test drains the snooper ring with 5 sequential ibex AXI loads per
//   entry (PC_SRC_H/L, PC_DST_H/L, CTR_TYPE).  Each AXI load costs ~10-30 cycles
//   of ibex stall.  Replacing them with an iDMA burst to TCDM means ibex reads
//   from 1-cycle TCDM instead; the AXI cost is entirely on the DMA engine, which
//   runs concurrently with the CPU.
//
// DOUBLE BUFFERING
//   Two TCDM buffers (buf[0] at TCDM_BASE, buf[1] at TCDM_BASE + BATCH_BYTES)
//   are used in alternation:
//
//     Iteration N:  DMA  fills buf[idle]   from snooper ring  ─┐ parallel
//                   CPU  reads buf[active]  → fetches basic blocks ─┘
//     Swap active ↔ idle.
//     Iteration N+1: DMA fills buf[idle], CPU processes buf[active]…
//
//   When CPU processing time ≥ DMA transfer time (true for BATCH_ENTRIES ≥ ~16
//   given AXI latency), the DMA latency is completely hidden.
//
// RING WRAP
//   Each DMA batch is capped so it never straddles the 16380-byte ring boundary;
//   wrap-around is handled by starting a fresh batch from offset 0 next iteration.
//
// BASIC BLOCK FETCH PER ENTRY
//   - 5 × 1-cycle TCDM loads  (all 5 entry words, from DMA-filled TCDM buffer)
//   - N × AXI loads           (one per 4-byte instruction in [prev_dst, pc_src_l])
//   - If prev_dst is outside the monitored region (e.g. after a call/return to
//     external code), only the branch instruction at pc_src_l is fetched.
//   The 5-word AXI burst from the snooper ring is fully offloaded to the DMA.
//
// CVA6 COUNTERPART
//   sw/tests/bare-metal/hostd/snooper_fetch_test.c
//   Uses scratch 8-11 with distinct sync constants (SYNC_ADDR_VALID_FETCH, etc.)
//   so this test cannot accidentally pair with the stress-test CVA6 binary.

#include <stdint.h>
#include "utils.h"
#include "regs/snooper_regs.h"
#include "host_uart.h"

#ifndef VERBOSE
#define VERBOSE 1
#endif
#define LOG(fmt, ...) do { if (VERBOSE) printf(fmt, ##__VA_ARGS__); } while (0)

// ---------------------------------------------------------------------------
// Address map
// ---------------------------------------------------------------------------
#define BASE_SNPRCFG   ((void *)0x15000000u)  // Snooper config registers
#define BASE_SNPR      (0x16000000u)          // Snooper ring buffer (AXI RAM)
#define IDMA_BASE      (0xfef00000u)          // iDMA engine
#define TCDM_BASE      (0xfff00000u)          // Tightly-Coupled Data Memory

// ---------------------------------------------------------------------------
// iDMA register offsets  (verified against sw/tests/scarv/idma_test/idma_test.c)
// ---------------------------------------------------------------------------
#define IDMA_CONF_OFFSET      0x000000u   // configuration / protocol select
#define IDMA_NEXT_ID_OFFSET   0x00000cu   // write triggers dispatch; returns txn ID
#define IDMA_DONE_ID_OFFSET   0x000014u   // last completed transaction ID
#define IDMA_DST_ADDR_OFFSET  0x0000d0u
#define IDMA_SRC_ADDR_OFFSET  0x0000d8u
#define IDMA_LENGTH_OFFSET    0x0000e0u
#define IDMA_REPS_2_OFFSET    0x0000f8u   // number of repetitions (set to 1)

// ---------------------------------------------------------------------------
// Snooper ring geometry
// ---------------------------------------------------------------------------
#define SNPR_RING_BYTES  16380u   // wrap boundary (matches stress test)
#define ENTRY_SIZE       20u      // bytes: PC_SRC_H, PC_SRC_L, PC_DST_H, PC_DST_L, CTR_TYPE

// Entry word indices within one 5-word TCDM slot
#define W_PC_SRC_L  0
#define W_PC_SRC_H  1
#define W_PC_DST_L  2
#define W_PC_DST_H  3
#define W_CTR_TYPE  4

// ---------------------------------------------------------------------------
// Double-buffer geometry in TCDM
//   buf[0]: TCDM_BASE + 0              (BATCH_BYTES bytes)
//   buf[1]: TCDM_BASE + BATCH_BYTES    (BATCH_BYTES bytes)
// Total = 2 × 64 × 20 = 2560 bytes  (well within a typical 128 KB TCDM)
// ---------------------------------------------------------------------------
#define BATCH_ENTRIES  64u
#define BATCH_BYTES    (BATCH_ENTRIES * ENTRY_SIZE)   // 1280 bytes per buffer

// ---------------------------------------------------------------------------
// Scratch register protocol  (shared via host regs at HOST_REGS_BASE_ADDR)
// Distinct from snooper_stress_test to prevent accidental cross-pairing.
// ---------------------------------------------------------------------------
#define HOST_SCRATCH_8_REG_OFFSET   0x20   // CVA6 → ibex: dummy_code_start
#define HOST_SCRATCH_9_REG_OFFSET   0x24   // CVA6 → ibex: dummy_code_end
#define HOST_SCRATCH_10_REG_OFFSET  0x28   // CVA6 → ibex: sync state
#define HOST_SCRATCH_11_REG_OFFSET  0x2c   // ibex → CVA6: sync state

#define SYNC_ADDR_VALID_FETCH   0xdeadc0de   // CVA6 published region addresses
#define SYNC_FETCH_DONE         0xcafe00fe   // CVA6 finished executing dummy
#define SYNC_IBEX_FETCH_READY   0x5a1e00fe   // ibex configured snooper, CVA6 may start

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
static void snooper_set_bit(uint32_t reg_off, uint32_t bit) {
    *reg32(BASE_SNPRCFG, reg_off) |= (1u << bit);
}

static void snooper_clr_bit(uint32_t reg_off, uint32_t bit) {
    *reg32(BASE_SNPRCFG, reg_off) &= ~(1u << bit);
}

// Issue one iDMA transfer src→dst of len bytes.
// Reading NEXT_ID triggers dispatch and returns the transaction ID.
static int idma_issue(uint32_t src, uint32_t dst, uint32_t len) {
    void *base = (void *)IDMA_BASE;
    *reg32(base, IDMA_SRC_ADDR_OFFSET) = src;
    *reg32(base, IDMA_DST_ADDR_OFFSET) = dst;
    *reg32(base, IDMA_LENGTH_OFFSET)   = len;
    *reg32(base, IDMA_CONF_OFFSET)     = 0x3u << 10;  // AXI→AXI protocol
    *reg32(base, IDMA_REPS_2_OFFSET)   = 1u;
    return (int)*reg32(base, IDMA_NEXT_ID_OFFSET);    // triggers dispatch
}

// Busy-poll until iDMA reports the given transaction completed.
// Ibex stalls here only if the CPU has processed its active buffer faster
// than the DMA can fill the idle buffer (rare at BATCH_ENTRIES = 64).
static void idma_wait(int id) {
    while ((int)*reg32((void *)IDMA_BASE, IDMA_DONE_ID_OFFSET) != id)
        asm volatile("nop");
}

// ---------------------------------------------------------------------------
// process_buffer
//
// Walk n_entries entries that the DMA has placed in the TCDM buffer at
// tcdm_addr.  For each entry the snooper recorded one branch edge:
//
//   prev_dst ──────────────────── pc_src_l   ← basic block ibex must fetch
//                                     ↓
//                                 pc_dst_l   ← new prev_dst for next block
//
// Ibex fetches every 4-byte-aligned word in [prev_dst .. pc_src_l] (inclusive)
// via data-port AXI LOADs into CVA6's code region in L2/DRAM.
//
// If prev_dst is outside the monitored region (e.g. after a call/return to
// external code), reconstruction is not possible; only the branch instruction
// at pc_src_l is fetched and prev_dst is advanced to pc_dst_l.
//
// prev_dst persists across batch boundaries via the caller-owned pointer.
//
// Returns 0 on success, 1 on first range error (fails fast).
// ---------------------------------------------------------------------------
static int process_buffer(uint32_t tcdm_addr, uint32_t n_entries,
                           uintptr_t dummy_start, uintptr_t dummy_end,
                           uint32_t *prev_dst,
                           uint32_t *fetch_count) {
    volatile uint32_t *base = (volatile uint32_t *)tcdm_addr;

    for (uint32_t i = 0; i < n_entries; i++) {
        // Read all 5 words of the entry from TCDM (DMA-filled from snooper ring).
        uint32_t pc_src_l = base[i * 5 + W_PC_SRC_L];
        uint32_t pc_src_h = base[i * 5 + W_PC_SRC_H];
        uint32_t pc_dst_l = base[i * 5 + W_PC_DST_L];
        uint32_t pc_dst_h = base[i * 5 + W_PC_DST_H];
        uint32_t ctr_type = base[i * 5 + W_CTR_TYPE];
        (void)pc_src_h;   // 32-bit security island: high word is always 0
        (void)pc_dst_h;
        (void)ctr_type;   // available for future per-type filtering

        // Range check: every branch/jump SOURCE must be inside the monitored region.
        if (pc_src_l < (uint32_t)dummy_start || pc_src_l >= (uint32_t)dummy_end) {
            LOG("[secd] FETCH FAIL: PC_SRC=0x%x not in [0x%x, 0x%x)\n\r",
                pc_src_l, (uint32_t)dummy_start, (uint32_t)dummy_end);
            return 1;
        }

        // ---- Basic block fetch: [fetch_start .. pc_src_l] inclusive ----
        // fetch_start is the PC_DST of the previous branch (the point where
        // CVA6 resumed after that branch and started executing this block).
        // If it fell outside the monitored region (e.g. after an external call
        // returned here), we cannot reconstruct the intervening instructions;
        // fall back to fetching only the branch instruction at pc_src_l.
        uint32_t fetch_start = *prev_dst;
        if (fetch_start < (uint32_t)dummy_start || fetch_start >= (uint32_t)dummy_end)
            fetch_start = pc_src_l;

        // Step by 4 bytes.  For RVC code some words contain two 16-bit instructions
        // but a 4-byte aligned load always captures them; granularity is sufficient
        // for the stress / reachability purpose of this test.
        for (uint32_t addr = fetch_start; addr <= pc_src_l; addr += 4) {
            volatile uint32_t *insn_ptr = (volatile uint32_t *)addr;
            (void)*insn_ptr;
            (*fetch_count)++;
        }

        // Advance: next basic block begins at the branch target.
        *prev_dst = pc_dst_l;
    }
    return 0;
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------
int main(void) {
    LOG("[secd] snooper_fetch_test: start\n\r");

    void *host_regs = (void *)HOST_REGS_BASE_ADDR;

    // ------------------------------------------------------------------
    // 1. Wait for CVA6 to publish dummy code region addresses
    // ------------------------------------------------------------------
    while (*reg32(host_regs, HOST_SCRATCH_10_REG_OFFSET) != (int)SYNC_ADDR_VALID_FETCH)
        ;

    uintptr_t dummy_start = (uintptr_t)*reg32(host_regs, HOST_SCRATCH_8_REG_OFFSET);
    uintptr_t dummy_end   = (uintptr_t)*reg32(host_regs, HOST_SCRATCH_9_REG_OFFSET);
    LOG("[secd] dummy region: 0x%x-0x%x\n\r",
        (unsigned)dummy_start, (unsigned)dummy_end);

    // ------------------------------------------------------------------
    // 2. Configure snooper — identical settings to snooper_stress_test:
    //    RANGE_2 covering the dummy region, addr mode, M-mode only,
    //    halt enabled at 800 unread entries, watermark at 10 entries.
    // ------------------------------------------------------------------
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_BASE_H_REG_OFFSET) = 0u;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_BASE_L_REG_OFFSET) = (uint32_t)dummy_start;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_LAST_H_REG_OFFSET) = 0u;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_LAST_L_REG_OFFSET) = (uint32_t)dummy_end;

    // M-mode only
    snooper_set_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_M_MODE_BIT);
    // Addr mode: log PC_SRC / PC_DST / CTR_TYPE per branch
    snooper_clr_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_TRACE_MODE_OFFSET);

    // Halt level: 800 entries × 20 bytes = 16000 bytes → CVA6 stalls when buffer
    // exceeds this; ibex draining via DMA releases the halt automatically.
    *reg32(BASE_SNPRCFG, CFG_REGS_HALT_LEVEL_REG_OFFSET) = 0x00003E80u;
    snooper_set_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CORE_HALT_EN_BIT);

    // Watermark: 10 entries (200 bytes)
    *reg32(BASE_SNPRCFG, CFG_REGS_WATERMARK_LEVEL_REG_OFFSET) = 0x0000000au;
    snooper_set_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_WATERMARK_EN_BIT);

    // Enable RANGE_2
    snooper_set_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_PC_RANGE_2_BIT);
    fence();

    // ------------------------------------------------------------------
    // 3. Signal CVA6 that the snooper is configured; CVA6 will start the
    //    dummy loop, pushing branch records into the snooper ring.
    // ------------------------------------------------------------------
    *reg32(host_regs, HOST_SCRATCH_11_REG_OFFSET) = SYNC_IBEX_FETCH_READY;
    fence();

    // ------------------------------------------------------------------
    // 4. Double-buffered DMA drain loop
    //
    // State:
    //   drain_ptr      – byte offset of next unread entry in snooper ring
    //   active_buf     – TCDM buffer index (0 or 1) ibex is currently processing
    //   idle_buf       – TCDM buffer index the DMA is (or will be) filling
    //   active_entries – number of valid entries in active_buf
    //
    // Each iteration:
    //   A. Sample LAST; compute how many bytes are new since drain_ptr.
    //   B. Compute batch: min(avail, BATCH_BYTES, bytes_to_ring_wrap).
    //      Capping at the ring wrap boundary means one DMA never crosses offset 0,
    //      avoiding a split transfer for a circular region.
    //   C. Launch DMA: snooper ring → idle_buf (non-blocking, runs in parallel).
    //   D. Process active_buf while DMA runs  ← latency hidden here.
    //   E. Wait for DMA to complete (usually already done by the time we get here).
    //   F. Advance drain_ptr; swap active ↔ idle; active_entries = next batch.
    //
    // Exit: CVA6 has finished AND all ring entries have been processed.
    // ------------------------------------------------------------------
    uint32_t drain_ptr      = 0;
    uint32_t fetch_count    = 0;
    int      active_buf     = 0;
    int      idle_buf       = 1;
    uint32_t active_entries = 0;   // valid entries in active_buf awaiting processing
    int      cva6_done      = 0;
    // prev_dst: PC_DST of the last processed entry; seeds the start address of
    // each basic block.  Initialised to dummy_start so the first basic block
    // (from dummy_code_start up to the first branch) is fetched in full.
    uint32_t prev_dst       = (uint32_t)dummy_start;

    do {
        // ---- A: Check CVA6 completion ----
        if (*reg32(host_regs, HOST_SCRATCH_10_REG_OFFSET) == (int)SYNC_FETCH_DONE)
            cva6_done = 1;

        // ---- B: Compute DMA batch ----
        uint32_t cur_last = (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);

        uint32_t avail;
        if (cur_last >= drain_ptr)
            avail = cur_last - drain_ptr;
        else
            avail = SNPR_RING_BYTES - drain_ptr + cur_last;  // ring wrapped

        // Never cross the ring wrap point within one DMA transfer
        uint32_t to_end   = SNPR_RING_BYTES - drain_ptr;
        uint32_t batch    = (avail < BATCH_BYTES) ? avail : BATCH_BYTES;
        if (batch > to_end) batch = to_end;
        batch = (batch / ENTRY_SIZE) * ENTRY_SIZE;   // align down to entry boundary

        uint32_t next_entries = batch / ENTRY_SIZE;

        // ---- C: Launch DMA from snooper ring → TCDM idle buffer ----
        // The DMA engine is another AXI master on the same interconnect as ibex;
        // it can reach BASE_SNPR (0x16000000) exactly as ibex can.
        int dma_active = 0;
        int dma_id     = 0;
        if (batch > 0) {
            uint32_t dma_src = BASE_SNPR + drain_ptr;
            uint32_t dma_dst = TCDM_BASE + (uint32_t)idle_buf * BATCH_BYTES;
            dma_id     = idma_issue(dma_src, dma_dst, batch);
            dma_active = 1;
        }

        // ---- D: Process active buffer (overlaps with DMA) ----
        // While the DMA is filling idle_buf with the next batch of snooper entries,
        // ibex works through active_buf: verify PC_SRC range, then fetch the
        // instruction at each logged address from CVA6's code memory.
        if (active_entries > 0) {
            uint32_t buf_addr = TCDM_BASE + (uint32_t)active_buf * BATCH_BYTES;
            int rc = process_buffer(buf_addr, active_entries,
                                    dummy_start, dummy_end, &prev_dst, &fetch_count);
            if (rc) return 1;
            active_entries = 0;   // mark buffer consumed
        }

        // ---- E: Wait for DMA ----
        // If processing finished before the DMA (unlikely at BATCH_ENTRIES = 64),
        // ibex stalls here briefly until the DMA completes.
        if (dma_active) {
            idma_wait(dma_id);

            // ---- F: Advance ring pointer and swap buffers ----
            drain_ptr += batch;
            if (drain_ptr >= SNPR_RING_BYTES) drain_ptr = 0;

            // idle_buf now holds next_entries valid entries; make it active
            active_buf     = idle_buf;
            idle_buf       = 1 - idle_buf;
            active_entries = next_entries;
        } else if (!cva6_done) {
            // Snooper ring is temporarily empty and CVA6 is still running.
            // Yield briefly so CVA6 can produce more entries before we poll again.
            for (volatile int d = 0; d < 16; d++) asm volatile("nop");
        }

    } while (!cva6_done || active_entries > 0 ||
             (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET) != drain_ptr);

    // ------------------------------------------------------------------
    // 5. Reset snooper circular buffer
    // ------------------------------------------------------------------
    snooper_set_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CNT_RST_BIT);
    snooper_clr_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CNT_RST_BIT);

    LOG("[secd] snooper_fetch_test: fetched %u instructions, PASSED\n\r",
        (unsigned)fetch_count);
    return 0;
}
