// Copyright 2026 ETH Zurich, University of Bologna and Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/*
 * OT clock-divider functional test
 * =================================
 *
 * Frequency relationship:
 *   f_OT = f_cheshire / (2 * ot_div)
 *   => cheshire_cycles / ot_cycles  ≈  2 * ot_div
 *
 * Protocol (ibex side):
 *   1. Write OtClkDivReg = N.
 *   2. Clear SCRATCH_13 (CVA6 done slot).
 *   3. Write SYNC_IBEX_START to SCRATCH_12; latch mcycle_start.
 *   4. Poll SCRATCH_13 until CVA6 writes SYNC_CVA6_DONE; latch mcycle_end.
 *   5. Read Cheshire elapsed cycles from SCRATCH_14 (lo) / SCRATCH_15 (hi).
 *   6. Verify ratio = cheshire_cycles / ot_cycles ≈ 2 * N  (±TOLERANCE_PCT).
 *   7. Clear SCRATCH_12 for the next round.
 *
 * CVA6 :
 *   - Poll SCRATCH_12 for SYNC_IBEX_START.
 *   - Snapshot rdcycle (start).
 *   - Busy-wait for a large number of Cheshire cycles (e.g. >= 1 000 000)
 *     so that polling latency is negligible.
 *   - Write elapsed cycles lo/hi to SCRATCH_14/15.
 *   - Write SYNC_CVA6_DONE to SCRATCH_13.
 *   - Repeat the same loop for each measurement round.
 */

#include <stdint.h>
#include "utils.h"
#include "host_uart.h"

#ifndef VERBOSE
#define VERBOSE 1
#endif
#define LOG(fmt, ...) do { if (VERBOSE) printf(fmt, ##__VA_ARGS__); } while (0)

// OT clock divider register
#define OtClkDivReg 0xBF000010

// Scratch register offsets relative to HOST_REGS_BASE_ADDR.
// Registers 0-3 (0x00-0x0C) are used by platform firmware; 4-11 (0x10-0x2C)
// are used by snooper/mbox tests. This test claims registers 12-15 (0x30-0x3C).
#define HOST_SCRATCH_12_REG_OFFSET  0x30  // ibex  -> CVA6: control
#define HOST_SCRATCH_13_REG_OFFSET  0x34  // CVA6  -> ibex: control
#define HOST_SCRATCH_14_REG_OFFSET  0x38  // CVA6  -> ibex: elapsed Cheshire cycles (lo 32 b)
#define HOST_SCRATCH_15_REG_OFFSET  0x3C  // CVA6  -> ibex: elapsed Cheshire cycles (hi 32 b)

// Synchronisation tokens
#define SYNC_IBEX_IDLE        0x00000000u  // ibex idle / slot cleared
#define SYNC_IBEX_BOOT_READY  0xAB000000u  // ibex signals it has booted and is ready
#define SYNC_IBEX_START       0xAB000001u  // ibex signals CVA6 to start measuring
#define SYNC_CVA6_BOOT_READY  0xCD000000u  // CVA6 signals it has booted and is ready
#define SYNC_CVA6_DONE        0xCD000001u  // CVA6 signals ibex that measurement is done

// Allowed deviation from the expected ratio (percent)
#define TOLERANCE_PCT  25u

// ---------------------------------------------------------------------------
// Read the 64-bit mcycle counter on a 32-bit RISC-V core (ibex).
// Uses the hi/lo/hi cross-read idiom to handle mid-read carry.
// ---------------------------------------------------------------------------
static inline uint64_t read_mcycle(void) {
    uint32_t lo, hi;
    asm volatile(
        "1: csrr %1, mcycleh\n"
        "   csrr %0, mcycle\n"
        "   csrr t0, mcycleh\n"
        "   bne  %1, t0, 1b\n"
        : "=r"(lo), "=r"(hi)
        :
        : "t0");
    return ((uint64_t)hi << 32) | lo;
}

// ---------------------------------------------------------------------------
// Single measurement round.
//
// Sets OtClkDivReg to `ot_div`, performs one handshake with CVA6, and checks
// that the measured cycle ratio matches the expected 2 * ot_div within
// TOLERANCE_PCT percent.
//
// Returns 0 on pass, -1 on fail.
// ---------------------------------------------------------------------------
static int measure_clk_div(void *host_regs, uint32_t ot_div) {
    volatile uint32_t *ot_clk_div_reg = (volatile uint32_t *)OtClkDivReg;

    LOG("[secd] ot_clk_div_test: measuring div=%u\n\r", (unsigned)ot_div);

    // Apply the new divider and let it propagate before measuring.
    *ot_clk_div_reg = ot_div;
    fence();

    // Clear CVA6's done slot so we cannot accidentally see a stale token.
    *reg32(host_regs, HOST_SCRATCH_13_REG_OFFSET) = (uint32_t)SYNC_IBEX_IDLE;
    fence();

    // Signal CVA6 then immediately latch mcycle so we do not waste OT cycles
    // before CVA6 begins its window.
    *reg32(host_regs, HOST_SCRATCH_12_REG_OFFSET) = (uint32_t)SYNC_IBEX_START;
    fence();
    uint64_t ot_start = read_mcycle();

    // Wait for CVA6 to finish its fixed-length measurement window.
    while ((uint32_t)*reg32(host_regs, HOST_SCRATCH_13_REG_OFFSET) != SYNC_CVA6_DONE)
        ;
    uint64_t ot_end = read_mcycle();

    // Let CVA6 know we have consumed the result (resets for next round).
    *reg32(host_regs, HOST_SCRATCH_12_REG_OFFSET) = (uint32_t)SYNC_IBEX_IDLE;
    fence();

    // Reconstruct Cheshire elapsed cycles written by CVA6.
    uint32_t cheshire_lo = (uint32_t)*reg32(host_regs, HOST_SCRATCH_14_REG_OFFSET);
    uint32_t cheshire_hi = (uint32_t)*reg32(host_regs, HOST_SCRATCH_15_REG_OFFSET);
    uint64_t cheshire_cycles = ((uint64_t)cheshire_hi << 32) | cheshire_lo;

    uint64_t ot_cycles = ot_end - ot_start;
    if (ot_cycles == 0) {
        LOG("[secd] ot_clk_div_test: ERROR div=%u ot_cycles=0\n\r", (unsigned)ot_div);
        return -1;
    }

    // Both cheshire_cycles (≤ MEASURE_CHESHIRE_CYCLES = 2 000 000) and
    // ot_cycles (≤ cheshire_cycles * 2 * max_div ≈ 8 000 000) fit in 32 bits.
    // Use 32-bit arithmetic to avoid __udivdi3 (64-bit division), which is
    // intentionally not implemented on the ibex RV32 toolchain.
    uint32_t cheshire32    = (uint32_t)cheshire_cycles;
    uint32_t ot32          = (uint32_t)ot_cycles;

    // Compute ratio * 100 (integer arithmetic, no FP needed).
    // Expected: cheshire_cycles / ot_cycles  ==  2 * ot_div
    uint32_t ratio_x100    = (cheshire32 * 100u) / ot32;
    uint32_t expected_x100 = 2u * (uint32_t)ot_div * 100u;
    uint32_t margin_x100   = expected_x100 * (uint32_t)TOLERANCE_PCT / 100u;

    LOG("[secd] ot_clk_div_test: div=%u ot_cycles=%u cheshire_cycles=%u ratio_x100=%u expected_x100=%u\n\r",
        (unsigned)ot_div, (unsigned)ot32, (unsigned)cheshire32,
        (unsigned)ratio_x100, (unsigned)expected_x100);

    if (ratio_x100 < (expected_x100 - margin_x100) ||
        ratio_x100 > (expected_x100 + margin_x100)) {
        LOG("[secd] ot_clk_div_test: FAIL div=%u ratio_x100=%u not in [%u, %u]\n\r",
            (unsigned)ot_div, (unsigned)ratio_x100,
            (unsigned)(expected_x100 - margin_x100),
            (unsigned)(expected_x100 + margin_x100));
        return -1;
    }

    LOG("[secd] ot_clk_div_test: PASS div=%u\n\r", (unsigned)ot_div);
    return 0;
}

int main(void) {
    void *host_regs = (void *)HOST_REGS_BASE_ADDR;

    LOG("[secd] ot_clk_div_test: start\n\r");

    // Boot-time barrier: announce ibex is ready, then wait for CVA6.
    // Either side can reach this point first; both will proceed only after
    // seeing each other's token.
    *reg32(host_regs, HOST_SCRATCH_12_REG_OFFSET) = (uint32_t)SYNC_IBEX_BOOT_READY;
    fence();
    while ((uint32_t)*reg32(host_regs, HOST_SCRATCH_13_REG_OFFSET) != SYNC_CVA6_BOOT_READY)
        ;
    // Clear own slot so it starts at IDLE for the measurement loop.
    *reg32(host_regs, HOST_SCRATCH_12_REG_OFFSET) = (uint32_t)SYNC_IBEX_IDLE;
    fence();
    LOG("[secd] ot_clk_div_test: sync done, starting measurement\n\r");

    if (measure_clk_div(host_regs,   1u) != 0) return -1;  // f_OT = f_cheshire /   2
    if (measure_clk_div(host_regs,   2u) != 0) return -1;  // f_OT = f_cheshire /   4
    if (measure_clk_div(host_regs,   4u) != 0) return -1;  // f_OT = f_cheshire /   8
    if (measure_clk_div(host_regs,   8u) != 0) return -1;  // f_OT = f_cheshire /  16
    if (measure_clk_div(host_regs,  16u) != 0) return -1;  // f_OT = f_cheshire /  32
    if (measure_clk_div(host_regs,  32u) != 0) return -1;  // f_OT = f_cheshire /  64
    if (measure_clk_div(host_regs,  64u) != 0) return -1;  // f_OT = f_cheshire / 128
    if (measure_clk_div(host_regs, 128u) != 0) return -1;  // f_OT = f_cheshire / 256

    LOG("[secd] ot_clk_div_test: all rounds PASSED\n\r");
    return 0;
}
