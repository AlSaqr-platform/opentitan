// Copyright 2026 Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdint.h>
#include "utils.h"
#include "regs/snooper_regs.h"
#include "host_uart.h"

#ifndef VERBOSE
#define VERBOSE 1
#endif
#define LOG(fmt, ...) do { if (VERBOSE) printf(fmt, ##__VA_ARGS__); } while (0)

// Snooper hardware base addresses
#define BASE_SNPRCFG ((void *)0x15000000)
#define BASE_SNPR    ((void *)0x16000000)

// Scratch register offsets (relative to HOST_REGS_BASE_ADDR)
// Written by CVA6 (ibex reads):
#define HOST_SCRATCH_8_REG_OFFSET  0x20  // dummy_code_start
#define HOST_SCRATCH_9_REG_OFFSET  0x24  // dummy_code_end
#define HOST_SCRATCH_10_REG_OFFSET 0x28  // CVA6 -> ibex sync state
// Written by ibex (CVA6 reads):
#define HOST_SCRATCH_11_REG_OFFSET 0x2c  // ibex -> CVA6 sync state

// Synchronization values (CVA6 -> ibex via scratch 10)
#define SYNC_ADDR_VALID  0xdeadbeef  // CVA6 has published all addresses
#define SYNC_DUMMY3_DONE 0xcafe0003  // CVA6 finished executing dummy

// Synchronization values (ibex -> CVA6 via scratch 11)
#define SYNC_IBEX_READY3 0x5a1e0003  // snooper configured, CVA6 may start dummy

void set_register_bit(void *base_addr, uint32_t reg_offset, uint32_t bit_position) {
    uint32_t reg_value = *reg32(base_addr, reg_offset);
    reg_value |= (1 << bit_position);
    *reg32(base_addr, reg_offset) = reg_value;
}

void clear_register_bit(void *base_addr, uint32_t reg_offset, uint32_t bit_position) {
    uint32_t reg_value = *reg32(base_addr, reg_offset);
    reg_value &= ~(1U << bit_position);
    *reg32(base_addr, reg_offset) = reg_value;
}


static inline int stable_last(void) {
    int val, stable_count;
    val = *reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);
    // stable_count = 0;
    // while (stable_count < 64) {
    //     int cur = *reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);
    //     if (cur == val) {
    //         stable_count++;
    //     } else {
    //         val = cur;
    //         stable_count = 0;
    //     }
    // }
    return val;
}

int main(void) {
    LOG("[secd] snooper_stress_test: start\n\r");

    void *host_regs = (void *)HOST_REGS_BASE_ADDR;
    int PC_SRC_L, PC_SRC_H, PC_DST_L, PC_DST_H, CTR_TYPE;
    int new_last;

    // Wait for CVA6 to publish all dummy code addresses
    while (*reg32(host_regs, HOST_SCRATCH_10_REG_OFFSET) != (int)SYNC_ADDR_VALID)
        ;

    uintptr_t dummy_start = (uintptr_t)*reg32(host_regs, HOST_SCRATCH_8_REG_OFFSET);
    uintptr_t dummy_end   = (uintptr_t)*reg32(host_regs, HOST_SCRATCH_9_REG_OFFSET);

    LOG("[secd] dummy: 0x%x-0x%x\n\r", (unsigned)dummy_start, (unsigned)dummy_end);

    //-------------------------------------------------------------------------------------//
    //-------------------------- SNOOPER CONFIGURATION -----------------------------------//
    // RANGE_2 configured. Addr mode. Watermark enabled.
    //-------------------------------------------------------------------------------------//

    // Configure RANGE_2: dummy region
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_BASE_H_REG_OFFSET) = 0x00000000;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_BASE_L_REG_OFFSET) = (uint32_t)dummy_start;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_LAST_H_REG_OFFSET) = 0x00000000;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_LAST_L_REG_OFFSET) = (uint32_t)dummy_end;

    // Log only instructions executed in M mode
    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_M_MODE_BIT);

    // Addr mode: log PC_SRC, PC_DST, CTR_TYPE for each branch/jump
    clear_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_TRACE_MODE_OFFSET);

    // Set halt level: CVA6 stalls when buffer exceeds 800 unread addr entries (16000 bytes).
    // The stall releases automatically once ibex reads entries back via AXI.
    *reg32(BASE_SNPRCFG, CFG_REGS_HALT_LEVEL_REG_OFFSET) = 0x00003E80;
    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CORE_HALT_EN_BIT);

    // Watermark: 10 addr entries (200 bytes)
    *reg32(BASE_SNPRCFG, CFG_REGS_WATERMARK_LEVEL_REG_OFFSET) = 0x0000000a;
    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_WATERMARK_EN_BIT);

    // Enable RANGE_2
    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_PC_RANGE_2_BIT);

    fence();

    //------------------------------------------------------------------------//
    //------------------------- DUMMY3 REGION --------------------------------//
    // Tests halt/resume: CVA6 executes a loop long enough to push the        //
    // snooper buffer past HALT_LEVEL unread entries, stalling CVA6.          //
    // Ibex actively drains entries mid-flight; each read reduces the unread  //
    // count and the snooper automatically releases the halt once the count   //
    // drops back below HALT_LEVEL, allowing CVA6 to resume.  The cycle may   //
    // repeat until CVA6 finishes all iterations and signals SYNC_DUMMY3_DONE.//
    //------------------------------------------------------------------------//
    *reg32(host_regs, HOST_SCRATCH_11_REG_OFFSET) = SYNC_IBEX_READY3;
    fence();

    // drain_ptr tracks the next entry to read in the circular buffer.
    int drain_ptr = 0;
    int dummy_entry_count = 0;
    for (volatile int delay = 0; delay < 10; delay++);

    // Concurrently drain the snooper buffer while CVA6 executes dummy.
    // Whenever CVA6 fills the buffer past HALT_LEVEL it stalls; reading
    // entries back below HALT_LEVEL causes the snooper to release the halt.
    while (*reg32(host_regs, HOST_SCRATCH_10_REG_OFFSET) != (int)SYNC_DUMMY3_DONE) {
        int cur_last = *reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);
        while (drain_ptr != cur_last) {
            PC_SRC_L = *reg32(BASE_SNPR, drain_ptr + 0x00);
            PC_SRC_H = *reg32(BASE_SNPR, drain_ptr + 0x04);
            PC_DST_L = *reg32(BASE_SNPR, drain_ptr + 0x08);
            PC_DST_H = *reg32(BASE_SNPR, drain_ptr + 0x0C);
            CTR_TYPE  = *reg32(BASE_SNPR, drain_ptr + 0x10);
            if ((PC_SRC_L <= (int)dummy_start) || (PC_SRC_L >= (int)dummy_end)) {
                LOG("[secd] dummy FAIL: PC_SRC=0x%x out of [0x%x, 0x%x)\n\r",
                       (unsigned)PC_SRC_L, (unsigned)dummy_start, (unsigned)dummy_end);
                return 1;
            }
            dummy_entry_count++;
            drain_ptr += 20;
            if (drain_ptr >= 16380)
                drain_ptr = 0;              // wrap circular buffer
            // Re-sample to pick up new entries without exiting the inner loop
            //add some delay to fully test halt/resume functionality
            
            cur_last = *reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);
        }
    }

    // CVA6 has finished dummy; drain and verify any remaining entries.
    new_last = *reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);
    LOG("[secd] dummy done: entries so far=%d final_last=0x%x\n\r",
           dummy_entry_count, (unsigned)new_last);
    while (drain_ptr != new_last) {
        PC_SRC_L = *reg32(BASE_SNPR, drain_ptr + 0x00);
        PC_SRC_H = *reg32(BASE_SNPR, drain_ptr + 0x04);
        PC_DST_L = *reg32(BASE_SNPR, drain_ptr + 0x08);
        PC_DST_H = *reg32(BASE_SNPR, drain_ptr + 0x0C);
        CTR_TYPE  = *reg32(BASE_SNPR, drain_ptr + 0x10);
        if ((PC_SRC_L <= (int)dummy_start) || (PC_SRC_L >= (int)dummy_end)) {
            LOG("[secd] dummy FAIL (tail): PC_SRC=0x%x out of [0x%x, 0x%x)\n\r",
                   (unsigned)PC_SRC_L, (unsigned)dummy_start, (unsigned)dummy_end);
            return 1;
        }
        dummy_entry_count++;
        drain_ptr += 20;
        if (drain_ptr >= 16380)
            drain_ptr = 0;
    }
    LOG("[secd] dummy halt/resume ok: %d total entries verified\n\r", dummy_entry_count);

    // Reset circular buffer at end of test
    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CNT_RST_BIT);
    clear_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CNT_RST_BIT);

    LOG("[secd] snooper_stress_test: PASSED\n\r");
    return 0;
}
