// Copyright 2026 Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// snooper_fetch_test.c  –  Ibex side

#include <stdint.h>
#include "utils.h"
#include "regs/snooper_regs.h"
#include "host_uart.h"
#include "idma.h"

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
#define L2_SHARED_BASE (0xA0010000u)          // L2 shared SRAM (ARCHI_L2_SHARED_ADDR)

// ---------------------------------------------------------------------------
// L2 layout for USE_DMA 3 (snooper entry staging + instruction area)
//
//   SNPR_STAGE_ADDR    – staging area for a full batch of snooper entries;
//                        worst case = whole ring = SNPR_RING_BYTES = 16380 B.
//                        Rounded up to 0x4000 (16384 B).
//   L2_DMA3_INSTR_BASE – instruction DMA destination starts after staging.
// ---------------------------------------------------------------------------
#define SNPR_STAGE_ADDR    (L2_SHARED_BASE + 0x0000u)
#define L2_DMA3_INSTR_BASE (L2_SHARED_BASE + 0x4000u)

// ---------------------------------------------------------------------------
// Snooper ring geometry
// ---------------------------------------------------------------------------
#define SNPR_RING_BYTES  16380u   // wrap boundary (matches stress test)
#define ENTRY_SIZE       20u      // bytes: PC_SRC_H, PC_SRC_L, PC_DST_H, PC_DST_L, CTR_TYPE

// ---------------------------------------------------------------------------
// Scratch register protocol  (shared via host regs at HOST_REGS_BASE_ADDR)
// Distinct from snooper_stress_test to prevent accidental cross-pairing.
// ---------------------------------------------------------------------------
#define HOST_SCRATCH_8_REG_OFFSET   0x20   // CVA6 → ibex: dummy_code_start
#define HOST_SCRATCH_9_REG_OFFSET   0x24   // CVA6 → ibex: dummy_code_end
#define HOST_SCRATCH_10_REG_OFFSET  0x28   // CVA6 → ibex: sync state
#define HOST_SCRATCH_11_REG_OFFSET  0x2c   // ibex → CVA6: sync state

#define SYNC_ADDR_VALID_FETCH   0xdeadc0de   // CVA6 published region addresses
#define SYNC_FETCH_DONE         0xcafe00fe   // CVA6 finished run-1 (halt enabled)
#define SYNC_IBEX_FETCH_READY   0x5a1e00fe   // ibex configured snooper, CVA6 may start run-1
#define SYNC_IBEX_READY_RUN2    0x5a1e01fe   // ibex reconfigured (halt off), CVA6 may start run-2
#define SYNC_FETCH_DONE_RUN2    0xcafe01fe   // CVA6 finished run-2 (halt disabled)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
static void snooper_set_bit(uint32_t reg_off, uint32_t bit) {
    *reg32(BASE_SNPRCFG, reg_off) |= (1u << bit);
}

static void snooper_clr_bit(uint32_t reg_off, uint32_t bit) {
    *reg32(BASE_SNPRCFG, reg_off) &= ~(1u << bit);
}

// DMA mode selection:
//   0 = core loads (no DMA)
//   1 = DMA + wait per block (simple, safe)
//   2 = DMA pipelined: issue DMA[n+1] before waiting for DMA[n]; DMA[n] runs
//       while the CPU reads the next snooper entry and computes fetch_start,
//       hiding most of the AXI transfer latency. Requires iDMA depth >= 1.
//   3 = Batched full DMA: all snooper entries currently available (up to the
//       ring wrap) are drained in ONE 2D DMA (reps = batch×5, stride = 4,
//       forcing 32-bit AXI beats as required by the snooper pointer logic)
//       into L2 staging at SNPR_STAGE_ADDR.  The batch is then processed in
//       a CPU loop that reads from fast L2 staging and pipelines instruction
//       DMAs (DMA[i] overlaps CPU reading staging entry[i+1]).
//       Advantage over mode 2: DMA setup O(1)/batch; snooper reads are
//       burst by the DMA engine; staging reads hit L2 (low latency on Ibex).
//       The 2D word-granular approach also stays correct if AxiDataWidth is
//       ever widened to 64.
#ifndef USE_DMA
#define USE_DMA 2
#endif


#ifndef LOG_INSTRUCTIONS
#define LOG_INSTRUCTIONS 0
#endif
// iDMA helpers are provided by idma.h (idma_issue_1d, idma_issue_word_granular,
// idma_wait, etc.). The old local functions are removed.

// ---------------------------------------------------------------------------
// Mode-3 debug wait
//   Wraps idma_wait with a spin counter that prints STATUS + DONE_ID every
//   ~1M nops so we can see which DMA is hung and why, instead of silently
//   looping forever.
// ---------------------------------------------------------------------------
#if USE_DMA == 3
#define DMA3_WAIT_REPORT_PERIOD (1u << 20)   /* ~1M nops ≈ few seconds */
static void dma3_dbg_wait(uint32_t base, idma_txn_id_t id, const char *tag) {
    uint32_t tick = 0;
    while ((int32_t)idma_reg_read(base, IDMA_DONE_ID_0_REG_OFFSET) < (int32_t)id) {
        __asm__ volatile("nop");
        if (++tick == DMA3_WAIT_REPORT_PERIOD) {
            tick = 0;
            LOG("[dma3] WAIT %s: id=%u done_id=%u status=0x%03x\n\r",
                tag,
                (unsigned)id,
                (unsigned)idma_reg_read(base, IDMA_DONE_ID_0_REG_OFFSET),
                (unsigned)idma_reg_read(base, IDMA_STATUS_0_REG_OFFSET));
        }
    }
}
#endif  /* USE_DMA == 3 */

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
    // 4. Drain loop — run 1 (halt enabled)
    //    Read entries directly from the snooper ring at BASE_SNPR and
    //    fetch instructions from CVA6 code memory via DMA into L2.
    // ------------------------------------------------------------------
    uint32_t drain_ptr    = 0;
    uint32_t fetch_count  = 0;
    uint32_t prev_dst     = (uint32_t)dummy_start;
    int      cva6_done    = 0;
    uint32_t l2_write_ptr = 0;   // running write offset into L2_SHARED_BASE
#if USE_DMA == 2
    idma_txn_id_t pending_dma_id = IDMA_INVALID_ID;
#endif

    do {
        if (*reg32(host_regs, HOST_SCRATCH_10_REG_OFFSET) == (int)SYNC_FETCH_DONE)
            cva6_done = 1;

        while (1) {
            uint32_t cur_last = (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);
            if (drain_ptr == cur_last)
                break;
#if USE_DMA == 3
            /* Batched word-granular drain:
             * Compute how many complete entries are available without crossing
             * the ring wrap boundary, issue one 2D DMA (reps=batch×5,
             * stride=4 → 32-bit beats) to copy the batch to L2 staging, then
             * process entries from staging while pipelining instruction DMAs
             * (DMA[i] overlaps CPU reading staging entry[i+1]).
             *
             * Wrap handling: if cur_last has wrapped past drain_ptr we clamp
             * to SNPR_RING_BYTES - drain_ptr so the DMA never crosses the
             * ring boundary; the outer do-while will run another batch for
             * the remaining entries after drain_ptr resets to 0. */
            {
                uint32_t avail_bytes = (cur_last >= drain_ptr)
                    ? (cur_last - drain_ptr)
                    : (SNPR_RING_BYTES - drain_ptr);  /* stop at wrap */
                uint32_t batch = avail_bytes / ENTRY_SIZE;
                if (batch == 0) break;

                /* Single 2D DMA: reads batch×ENTRY_SIZE bytes from the ring
                 * as batch×5 consecutive 32-bit word transactions. */
                LOG("[dma3] batch drain: drain_ptr=0x%x cur_last=0x%x batch=%u "
                    "src=0x%x dst=0x%x len=%u\n\r",
                    (unsigned)drain_ptr, (unsigned)cur_last, (unsigned)batch,
                    (unsigned)(BASE_SNPR + drain_ptr), (unsigned)SNPR_STAGE_ADDR,
                    (unsigned)(batch * ENTRY_SIZE));
                idma_txn_id_t sid = idma_issue_word_granular(
                    IDMA_BASE, BASE_SNPR + drain_ptr, SNPR_STAGE_ADDR,
                    batch * ENTRY_SIZE, IDMA_CONF_1D_AXI_TO_AXI);
                LOG("[dma3] batch drain id=%u issued, done_id=%u status=0x%03x\n\r",
                    (unsigned)sid,
                    (unsigned)idma_reg_read(IDMA_BASE, IDMA_DONE_ID_0_REG_OFFSET),
                    (unsigned)idma_reg_read(IDMA_BASE, IDMA_STATUS_0_REG_OFFSET));
                dma3_dbg_wait(IDMA_BASE, sid, "drain");
                LOG("[dma3] batch drain id=%u done\n\r", (unsigned)sid);

                /* Process entries from L2 staging; pipeline instruction DMAs
                 * so DMA[i] runs while the CPU reads staging entry[i+1]. */
                idma_txn_id_t pending_fid = IDMA_INVALID_ID;
                for (uint32_t i = 0; i < batch; i++) {
                    volatile uint32_t *e =
                        (volatile uint32_t *)(SNPR_STAGE_ADDR + i * ENTRY_SIZE);
                    uint32_t pc_src_l = e[0];
                    uint32_t pc_dst_l = e[2];

                    if (pc_src_l < (uint32_t)dummy_start ||
                        pc_src_l >= (uint32_t)dummy_end) {
                        LOG("[secd] FETCH FAIL: PC_SRC=0x%x not in [0x%x, 0x%x)\n\r",
                            pc_src_l, (uint32_t)dummy_start, (uint32_t)dummy_end);
                        return 1;
                    }

                    uint32_t fetch_start = prev_dst;
                    if (fetch_start < (uint32_t)dummy_start ||
                        fetch_start >= (uint32_t)dummy_end)
                        fetch_start = pc_src_l;

                    uint32_t bytes = (pc_src_l - fetch_start) + 4u;
                    LOG("[dma3] instr[%u/%u]: fetch_start=0x%x dst=0x%x bytes=%u\n\r",
                        (unsigned)i, (unsigned)batch,
                        (unsigned)fetch_start,
                        (unsigned)(L2_DMA3_INSTR_BASE + l2_write_ptr),
                        (unsigned)bytes);
                    idma_txn_id_t new_fid = idma_issue_1d(
                        IDMA_BASE, fetch_start,
                        L2_DMA3_INSTR_BASE + l2_write_ptr, bytes,
                        IDMA_CONF_1D_AXI_TO_AXI);
                    LOG("[dma3] instr[%u] id=%u issued, done_id=%u status=0x%03x\n\r",
                        (unsigned)i, (unsigned)new_fid,
                        (unsigned)idma_reg_read(IDMA_BASE, IDMA_DONE_ID_0_REG_OFFSET),
                        (unsigned)idma_reg_read(IDMA_BASE, IDMA_STATUS_0_REG_OFFSET));
                    if (pending_fid != IDMA_INVALID_ID)
                        dma3_dbg_wait(IDMA_BASE, pending_fid, "instr");
                    pending_fid = new_fid;

                    fetch_count  += (bytes + 3u) >> 2;
                    l2_write_ptr += bytes;
                    prev_dst = pc_dst_l;
                }
                if (pending_fid != IDMA_INVALID_ID)
                    dma3_dbg_wait(IDMA_BASE, pending_fid, "instr_last");

                drain_ptr += batch * ENTRY_SIZE;
                if (drain_ptr >= SNPR_RING_BYTES) drain_ptr = 0;
            }
#else
            uint32_t pc_src_l = *reg32((void *)BASE_SNPR, drain_ptr + 0x00);
            uint32_t pc_src_h = *reg32((void *)BASE_SNPR, drain_ptr + 0x04);
            uint32_t pc_dst_l = *reg32((void *)BASE_SNPR, drain_ptr + 0x08);
            uint32_t pc_dst_h = *reg32((void *)BASE_SNPR, drain_ptr + 0x0C);
            uint32_t ctr_type = *reg32((void *)BASE_SNPR, drain_ptr + 0x10);
            (void)pc_src_h; (void)pc_dst_h; (void)ctr_type;

            // if (pc_src_l < (uint32_t)dummy_start || pc_src_l >= (uint32_t)dummy_end) {
            //     LOG("[secd] FETCH FAIL: PC_SRC=0x%x not in [0x%x, 0x%x)\n\r",
            //         pc_src_l, (uint32_t)dummy_start, (uint32_t)dummy_end);
            //     return 1;
            // }

            uint32_t fetch_start = prev_dst;
            if (fetch_start < (uint32_t)dummy_start || fetch_start >= (uint32_t)dummy_end)
                fetch_start = pc_src_l;

            /* Fetch instructions for the basic block.
             * - USE_DMA 1: DMA → wait per block (simple)
             * - USE_DMA 2: issue DMA, wait for *previous* DMA (pipelined)
             * - USE_DMA 0: core mixed 32/16-bit reads (no DMA)
             */
#if USE_DMA == 1
            {
                uint32_t bytes = (pc_src_l - fetch_start) + 4u;
                idma_txn_id_t dma_id = idma_issue_1d(IDMA_BASE, fetch_start,
                                           L2_SHARED_BASE + l2_write_ptr, bytes,
                                           IDMA_CONF_1D_AXI_TO_AXI);
                idma_wait(IDMA_BASE, dma_id);
                fetch_count  += (bytes + 3u) >> 2;
                l2_write_ptr += bytes;
            }
#elif USE_DMA == 2
            {
                uint32_t bytes = (pc_src_l - fetch_start) + 4u;
                // Issue DMA[n] first so it is in flight during the wait,
                // then wait for DMA[n-1].  DMA[n] runs while the CPU reads
                // the next snooper entry (5 async-CDC loads) on the next
                // iteration, hiding most of the transfer latency.
                // Keeping only 1 DMA in flight avoids competing ARs on the
                // Ext-port serializer (MaxSlvTrans=1) with Ibex's snooper reads.
                idma_txn_id_t new_id = idma_issue_1d(IDMA_BASE, fetch_start,
                                           L2_SHARED_BASE + l2_write_ptr, bytes,
                                           IDMA_CONF_1D_AXI_TO_AXI);
                if (pending_dma_id != IDMA_INVALID_ID)
                    idma_wait(IDMA_BASE, pending_dma_id);
                pending_dma_id = new_id;
                fetch_count  += (bytes + 3u) >> 2;
                l2_write_ptr += bytes;
            }
#else
            {
                for (uint32_t addr = fetch_start; addr <= pc_src_l; ) {
                    if ((addr & 3u) == 2u) {
                        volatile uint16_t *p16 = (volatile uint16_t *)addr;
                        (void)*p16; fetch_count++; addr += 2u; continue;
                    }
                    if (addr + 3u <= pc_src_l) {
                        volatile uint32_t *p32 = (volatile uint32_t *)addr;
                        (void)*p32; fetch_count++; addr += 4u; continue;
                    }
                    volatile uint16_t *p16 = (volatile uint16_t *)addr;
                    (void)*p16; fetch_count++; break;
                }
            }
#endif
            prev_dst = pc_dst_l;
            drain_ptr += ENTRY_SIZE;
            if (drain_ptr >= SNPR_RING_BYTES)
                drain_ptr = 0;
#endif  /* USE_DMA == 3 */
        }

    } while (!cva6_done || (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET) != drain_ptr);

#if USE_DMA == 2
    if (pending_dma_id != IDMA_INVALID_ID)
        idma_wait(IDMA_BASE, pending_dma_id);
#endif

    //    L2 is a flat byte stream; RISC-V encoding is self-delimiting:
    //      hw[1:0] == 0b11  ->  4-byte RVI
    //      hw[1:0] != 0b11  ->  2-byte RVC
    // ------------------------------------------------------------------
#if LOG_INSTRUCTIONS
    LOG("[secd] -- Instruction log (%u bytes in L2) --\n\r", (unsigned)l2_write_ptr);
    {
        uint32_t byte_off = 0;
#if USE_DMA == 3
        uint32_t log_base = L2_DMA3_INSTR_BASE;
#else
        uint32_t log_base = L2_SHARED_BASE;
#endif
        while (byte_off < l2_write_ptr) {
            uint16_t hw0 = *(volatile uint16_t *)(log_base + byte_off);
            if ((hw0 & 0x3u) == 0x3u) {
                uint16_t hw1   = *(volatile uint16_t *)(log_base + byte_off + 2u);
                uint32_t instr = (uint32_t)hw0 | ((uint32_t)hw1 << 16);
                LOG("  0x%08x\n\r", (unsigned)instr);
                byte_off += 4u;
            } else {
                LOG("  0x%04x (RVC)\n\r", (unsigned)hw0);
                byte_off += 2u;
            }
        }
    }
#endif

    // ------------------------------------------------------------------
    // 6. Reconfigure snooper for run 2: disable halt, reset ring.
    //    Signal CVA6 to start run 2; drain entries to keep the ring from
    //    overflowing (reads from BASE_SNPR consume entries).  No DMA to
    //    L2 needed — run 2 is purely for CVA6 cycle measurement.
    // ------------------------------------------------------------------
    snooper_clr_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CORE_HALT_EN_BIT);
    snooper_set_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CNT_RST_BIT);
    snooper_clr_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CNT_RST_BIT);
    fence();
    *reg32(host_regs, HOST_SCRATCH_11_REG_OFFSET) = SYNC_IBEX_READY_RUN2;
    fence();

    {
        uint32_t drain2_ptr = 0;
        int      cva6_done2 = 0;
        do {
            if (*reg32(host_regs, HOST_SCRATCH_10_REG_OFFSET) == (int)SYNC_FETCH_DONE_RUN2)
                cva6_done2 = 1;

            uint32_t cur_last2 = (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);
            while (drain2_ptr != cur_last2) {
                // Read entry from ring (the AXI read itself consumes the slot).
                (void)*reg32((void *)BASE_SNPR, drain2_ptr + 0x00);
                (void)*reg32((void *)BASE_SNPR, drain2_ptr + 0x04);
                (void)*reg32((void *)BASE_SNPR, drain2_ptr + 0x08);
                (void)*reg32((void *)BASE_SNPR, drain2_ptr + 0x0C);
                (void)*reg32((void *)BASE_SNPR, drain2_ptr + 0x10);
                drain2_ptr += ENTRY_SIZE;
                if (drain2_ptr >= SNPR_RING_BYTES)
                    drain2_ptr = 0;
                cur_last2 = (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);
            }
        } while (!cva6_done2 ||
                 (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET) != drain2_ptr);
    }

    // ------------------------------------------------------------------
    // 7. Reset snooper circular buffer
    // ------------------------------------------------------------------
    snooper_set_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CNT_RST_BIT);
    snooper_clr_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CNT_RST_BIT);

    LOG("[secd] snooper_fetch_test: fetched %u instructions, PASSED\n\r",
        (unsigned)fetch_count);
    return 0;
}
