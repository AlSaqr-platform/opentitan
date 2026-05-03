// Copyright 2026 Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// snooper_fetch_test.c  –  Ibex side

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
#define L2_SHARED_BASE (0xA0010000u)          // L2 shared SRAM (ARCHI_L2_SHARED_ADDR)

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
#ifndef USE_DMA
#define USE_DMA 2
#endif

#ifndef LOG_INSTRUCTIONS
#define LOG_INSTRUCTIONS 0
#endif
// iDMA helpers (used when USE_DMA==1)
static int idma_issue(uint32_t src, uint32_t dst, uint32_t len) {
    void *base = (void *)IDMA_BASE;
    *reg32(base, IDMA_SRC_ADDR_OFFSET) = src;
    *reg32(base, IDMA_DST_ADDR_OFFSET) = dst;
    *reg32(base, IDMA_LENGTH_OFFSET)   = len;
    *reg32(base, IDMA_CONF_OFFSET)     = 0x3u << 10;  // AXI→AXI protocol
    *reg32(base, IDMA_REPS_2_OFFSET)   = 1u;
    return (int)*reg32(base, IDMA_NEXT_ID_OFFSET);
}

static void idma_wait(int id) {
    // Use >= (not ==): in pipelined mode the engine may have already completed
    // later transactions, advancing DONE_ID past `id`.  Exact equality would
    // spin forever in that case.
    while ((int)*reg32((void *)IDMA_BASE, IDMA_DONE_ID_OFFSET) < id)
        asm volatile("nop");
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
    int      pending_dma_id  = -1;  // last issued code DMA not yet waited on (mode 2)
#endif

    do {
        if (*reg32(host_regs, HOST_SCRATCH_10_REG_OFFSET) == (int)SYNC_FETCH_DONE)
            cva6_done = 1;

        uint32_t cur_last = (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);

        while (drain_ptr != cur_last) {
            uint32_t pc_src_l = *reg32((void *)BASE_SNPR, drain_ptr + 0x00);
            uint32_t pc_src_h = *reg32((void *)BASE_SNPR, drain_ptr + 0x04);
            uint32_t pc_dst_l = *reg32((void *)BASE_SNPR, drain_ptr + 0x08);
            uint32_t pc_dst_h = *reg32((void *)BASE_SNPR, drain_ptr + 0x0C);
            uint32_t ctr_type = *reg32((void *)BASE_SNPR, drain_ptr + 0x10);
            (void)pc_src_h; (void)pc_dst_h; (void)ctr_type;

            if (pc_src_l < (uint32_t)dummy_start || pc_src_l >= (uint32_t)dummy_end) {
                LOG("[secd] FETCH FAIL: PC_SRC=0x%x not in [0x%x, 0x%x)\n\r",
                    pc_src_l, (uint32_t)dummy_start, (uint32_t)dummy_end);
                return 1;
            }

            uint32_t fetch_start = prev_dst;
            if (fetch_start < (uint32_t)dummy_start || fetch_start >= (uint32_t)dummy_end)
                fetch_start = pc_src_l;

            /* Fetch instructions for the basic block.
             * - USE_DMA 1: DMA -> wait per block (simple)
             * - USE_DMA 2: issue DMA, wait for *previous* DMA (pipelined)
             * - USE_DMA 0: core mixed 32/16-bit reads (no DMA)
             */
#if USE_DMA == 1
            {
                uint32_t bytes = (pc_src_l - fetch_start) + 4u;
                int dma_id = idma_issue(fetch_start, L2_SHARED_BASE + l2_write_ptr, bytes);
                idma_wait(dma_id);
                fetch_count  += (bytes + 3u) >> 2;
                l2_write_ptr += bytes;
            }
#elif USE_DMA == 2
            {
                uint32_t bytes = (pc_src_l - fetch_start) + 4u;
                int new_id = idma_issue(fetch_start, L2_SHARED_BASE + l2_write_ptr, bytes);
                if (pending_dma_id >= 0)
                    idma_wait(pending_dma_id);
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
            cur_last = (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);
        }

    } while (!cva6_done || (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET) != drain_ptr);

#if USE_DMA == 2
    // Wait for the last outstanding pipelined DMA before reading L2.
    if (pending_dma_id >= 0)
        idma_wait(pending_dma_id);
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
    //    L2 is a flat byte stream; RISC-V encoding is self-delimiting:
    //      hw[1:0] == 0b11  ->  4-byte RVI
    //      hw[1:0] != 0b11  ->  2-byte RVC
    // ------------------------------------------------------------------
#if LOG_INSTRUCTIONS
    LOG("[secd] -- Instruction log (%u bytes in L2) --\n\r", (unsigned)l2_write_ptr);
    {
        uint32_t byte_off = 0;
        while (byte_off < l2_write_ptr) {
            uint16_t hw0 = *(volatile uint16_t *)(L2_SHARED_BASE + byte_off);
            if ((hw0 & 0x3u) == 0x3u) {
                uint16_t hw1   = *(volatile uint16_t *)(L2_SHARED_BASE + byte_off + 2u);
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
    // 7. Reset snooper circular buffer
    // ------------------------------------------------------------------
    snooper_set_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CNT_RST_BIT);
    snooper_clr_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CNT_RST_BIT);

    LOG("[secd] snooper_fetch_test: fetched %u instructions, PASSED\n\r",
        (unsigned)fetch_count);
    return 0;
}
