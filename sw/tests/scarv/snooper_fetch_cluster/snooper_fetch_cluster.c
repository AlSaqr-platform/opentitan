// Copyright 2026 Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// snooper_fetch_cluster.c — Ibex side
//
// Paired with:
//   regression_tests/opentitan-cluster/snooper_fetch_cluster/test.c  (cluster)
//   sw/tests/bare-metal/hostd/snooper_fetch_test.c                    (CVA6)
//
// Ibex responsibilities:
//   1. Configure PLIC + CSR interrupt so the cluster's mailbox SND doorbell
//      wakes Ibex via WFI at the end of the run-2 drain.
//   2. Wait for CVA6 to publish dummy code region (scratch 8/9/10).
//   3. Configure the snooper (RANGE_2, M-mode, halt at 800 entries,
//      watermark at 10 — identical to snooper_fetch_test.c Ibex side).
//   4. Write dummy_start/end + SFC_IBEX_RUN1_READY to the L2 ctrl block.
//   5. Signal CVA6 via scratch 11 (SYNC_IBEX_FETCH_READY).
//   6. Boot the PULP cluster.
//   7. Poll L2 ctrl for SFC_CLUSTER_RUN1_DONE (Ibex stays active here
//      because it still needs to reconfigure the snooper between runs).
//   8. Reconfigure snooper: disable halt, reset ring counter.
//   9. Write SFC_IBEX_RUN2_READY to L2 ctrl.
//  10. Signal CVA6 via scratch 11 (SYNC_IBEX_READY_RUN2).
//  11. WFI — cluster rings SND doorbell when run-2 drain is complete.
//      external_irq_handler clears the mailbox interrupt.
//  12. Read cluster return value from mailbox LETTER0; reset snooper ring;
//      disable cluster clock.

#include <stdint.h>
#include "utils.h"
#include "regs/snooper_regs.h"
#include "host_uart.h"
#include "mailboxes.h"
#include "snooper_fetch_cluster.h"

#ifndef VERBOSE
#define VERBOSE 1
#endif
#define LOG(fmt, ...) do { if (VERBOSE) printf(fmt, ##__VA_ARGS__); } while (0)

// ---------------------------------------------------------------------------
// Address map
// ---------------------------------------------------------------------------
#define BASE_SNPRCFG  ((void *)0x15000000u)  // snooper config registers

// PLIC registers for mailbox IRQ (interrupt line 160 = SECD_MBOX_IRQ_ID)
#define PLIC_PRIO_REG   0xC8000280u  // priority for IRQ line 160
#define PLIC_IE_REG     0xC8002014u  // interrupt enable IE0_5 (line 160 → bit 0)
#define PLIC_CHECK_REG  0xC8200004u  // claim/complete register CC0

// Mailbox SND side (cluster → Ibex doorbell)
#define MBOX_LETTER0_ADDR    (MAILBOX_BASE_ADDR + ARCHI_MAILBOX_LETTER0_OFFSET)
#define MBOX_SND_SET_ADDR    (MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_SND_SET_OFFSET)
#define MBOX_SND_CLR_ADDR    (MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_SND_CLR_OFFSET)
#define MBOX_SND_EN_ADDR     (MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_SND_EN_OFFSET)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
static inline volatile uint32_t *sfc_ctrl(uint32_t off) {
    return (volatile uint32_t *)(SFC_CTRL_BASE + off);
}

static inline void snooper_set_bit(uint32_t reg_off, uint32_t bit) {
    *reg32(BASE_SNPRCFG, reg_off) |= (1u << bit);
}

static inline void snooper_clr_bit(uint32_t reg_off, uint32_t bit) {
    *reg32(BASE_SNPRCFG, reg_off) &= ~(1u << bit);
}

// ---------------------------------------------------------------------------
// Mailbox SND interrupt handler
//
// Called when the cluster rings its SND doorbell (Ibex external IRQ line 160).
// Clears the SND interrupt so Ibex can return from WFI cleanly.
// ---------------------------------------------------------------------------
void external_irq_handler(void) {
    volatile int *plic_check = (volatile int *)PLIC_CHECK_REG;

    // Confirm this is the mailbox interrupt (line 160)
    while (*plic_check != SECD_MBOX_IRQ_ID)
        ;

    // Clear the SND interrupt in the mailbox
    *(volatile uint32_t *)MBOX_SND_SET_ADDR = 0u;
    *(volatile uint32_t *)MBOX_SND_EN_ADDR  = 0u;
    *(volatile uint32_t *)MBOX_SND_CLR_ADDR = 1u;

    // Complete the PLIC claim
    *plic_check = SECD_MBOX_IRQ_ID;
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------
int main(void) {
    LOG("[secd] snooper_fetch_cluster (ibex): start\n\r");

    void *host_regs = (void *)HOST_REGS_BASE_ADDR;

    // ------------------------------------------------------------------
    // 1. Configure PLIC + Ibex CSRs to receive the cluster's SND doorbell.
    //    The cluster rings interrupt line 160 (SECD_MBOX_IRQ_ID) when done.
    // ------------------------------------------------------------------
    // Point mtvec to external_irq_handler (vectored mode, base aligned)
    unsigned mtvec_cfg = 0xe0000001u;
    asm volatile ("csrw mtvec, %0\n" : : "r"(mtvec_cfg));

    // Enable global interrupts + external interrupt in Ibex
    unsigned mstatus_cfg = 0x00001808u;  // MIE + MPIE
    unsigned mie_cfg     = 0x00000800u;  // MEIE (external interrupt enable)
    asm volatile ("csrw mstatus, %0\n" : : "r"(mstatus_cfg));
    asm volatile ("csrw mie,     %0\n" : : "r"(mie_cfg));

    // Set mailbox IRQ (line 160) priority to 1 and enable it in PLIC IE0_5
    *(volatile uint32_t *)PLIC_PRIO_REG = 1u;
    *(volatile uint32_t *)PLIC_IE_REG   = 0x00000001u;

    // ------------------------------------------------------------------
    // 2. Initialise shared control block to a known idle state
    // ------------------------------------------------------------------
    *sfc_ctrl(SFC_IBEX_STATE_OFF)    = SFC_IDLE;
    *sfc_ctrl(SFC_DUMMY_START_OFF)   = 0u;
    *sfc_ctrl(SFC_DUMMY_END_OFF)     = 0u;
    *sfc_ctrl(SFC_CLUSTER_STATE_OFF) = SFC_IDLE;
    fence();

    // ------------------------------------------------------------------
    // 3. Wait for CVA6 to publish dummy code region addresses
    // ------------------------------------------------------------------
    while (*reg32(host_regs, HOST_SCRATCH_10_REG_OFFSET) != (int)SYNC_ADDR_VALID_FETCH)
        ;

    uintptr_t dummy_start = (uintptr_t)*reg32(host_regs, HOST_SCRATCH_8_REG_OFFSET);
    uintptr_t dummy_end   = (uintptr_t)*reg32(host_regs, HOST_SCRATCH_9_REG_OFFSET);
    LOG("[secd] dummy region: 0x%x-0x%x\n\r",
        (unsigned)dummy_start, (unsigned)dummy_end);

    // ------------------------------------------------------------------
    // 4. Configure snooper — RANGE_2, M-mode, addr mode,
    //    halt at 800 unread entries, watermark at 10 entries.
    // ------------------------------------------------------------------
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_BASE_H_REG_OFFSET) = 0u;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_BASE_L_REG_OFFSET) = (uint32_t)dummy_start;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_LAST_H_REG_OFFSET) = 0u;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_LAST_L_REG_OFFSET) = (uint32_t)dummy_end;

    snooper_set_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_M_MODE_BIT);
    snooper_clr_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_TRACE_MODE_OFFSET);

    *reg32(BASE_SNPRCFG, CFG_REGS_HALT_LEVEL_REG_OFFSET) = 0x00003E80u;  // 800 entries × 20 B
    snooper_set_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CORE_HALT_EN_BIT);

    *reg32(BASE_SNPRCFG, CFG_REGS_WATERMARK_LEVEL_REG_OFFSET) = 0x0000000au;
    snooper_set_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_WATERMARK_EN_BIT);

    snooper_set_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_PC_RANGE_2_BIT);
    fence();

    // ------------------------------------------------------------------
    // 5. Publish dummy region + RUN1_READY to L2 ctrl block.
    //    dummy_start/end written first (store-fence) so cluster reads a
    //    consistent snapshot once it observes SFC_IBEX_RUN1_READY.
    // ------------------------------------------------------------------
    *sfc_ctrl(SFC_DUMMY_START_OFF) = (uint32_t)dummy_start;
    *sfc_ctrl(SFC_DUMMY_END_OFF)   = (uint32_t)dummy_end;
    fence();
    *sfc_ctrl(SFC_IBEX_STATE_OFF)  = SFC_IBEX_RUN1_READY;
    fence();

    // ------------------------------------------------------------------
    // 6. Signal CVA6: snooper armed, start run-1 dummy loop
    // ------------------------------------------------------------------
    *reg32(host_regs, HOST_SCRATCH_11_REG_OFFSET) = SYNC_IBEX_FETCH_READY;
    fence();

    // ------------------------------------------------------------------
    // 7. Boot the cluster (cluster binary already loaded at ENTRY_ADDR)
    // ------------------------------------------------------------------
    *(volatile uint32_t *)SFC_EDN_EN_ADDR = 0x9996u;
    for (uint32_t i = 0; i < SFC_CLUSTER_NUM_CORES; i++) {
        volatile uint32_t *ba = (volatile uint32_t *)(SFC_CLUSTER_BOOT_REG + 4u * i);
        *ba = SFC_CLUSTER_ENTRY_ADDR;
    }
    *(volatile uint32_t *)SFC_CLUSTER_CLK_EN   = 0x1u;
    *(volatile uint32_t *)SFC_CLUSTER_FETCH_EN = 0x1u;
    fence();
    LOG("[secd] cluster booted; polling for run-1 done...\n\r");

    // ------------------------------------------------------------------
    // 8. Poll for cluster run-1 done.
    //    Ibex stays active here (not WFI) because it must immediately
    //    reconfigure the snooper and signal CVA6 when run-1 finishes.
    // ------------------------------------------------------------------
    while (*sfc_ctrl(SFC_CLUSTER_STATE_OFF) != SFC_CLUSTER_RUN1_DONE)
        ;
    *sfc_ctrl(SFC_CLUSTER_STATE_OFF) = SFC_IDLE;
    fence();
    LOG("[secd] run-1 done; reconfiguring snooper...\n\r");

    // ------------------------------------------------------------------
    // 9. Reconfigure snooper for run-2: disable halt, reset ring counter
    // ------------------------------------------------------------------
    snooper_clr_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CORE_HALT_EN_BIT);
    snooper_set_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CNT_RST_BIT);
    snooper_clr_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CNT_RST_BIT);
    fence();

    // ------------------------------------------------------------------
    // 10. Signal cluster: run-2 ready (halt off, ring reset)
    // ------------------------------------------------------------------
    *sfc_ctrl(SFC_IBEX_STATE_OFF) = SFC_IBEX_RUN2_READY;
    fence();

    // ------------------------------------------------------------------
    // 11. Signal CVA6: start run-2 baseline measurement
    // ------------------------------------------------------------------
    *reg32(host_regs, HOST_SCRATCH_11_REG_OFFSET) = SYNC_IBEX_READY_RUN2;
    fence();

    // ------------------------------------------------------------------
    // 12. WFI — sleep until cluster rings the SND doorbell (run-2 done).
    //     external_irq_handler clears the interrupt; WFI returns.
    // ------------------------------------------------------------------
    LOG("[secd] waiting for cluster run-2 done (WFI)...\n\r");
    asm volatile ("wfi");

    // ------------------------------------------------------------------
    // 13. Cluster completed run-2.  Read return value; disable cluster.
    // ------------------------------------------------------------------
    uint32_t cluster_ret = *(volatile uint32_t *)MBOX_LETTER0_ADDR;
    *(volatile uint32_t *)SFC_CLUSTER_FETCH_EN = 0x0u;

    // ------------------------------------------------------------------
    // 14. Reset snooper ring counter
    // ------------------------------------------------------------------
    snooper_set_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CNT_RST_BIT);
    snooper_clr_bit(CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_CNT_RST_BIT);

    LOG("[secd] snooper_fetch_cluster (ibex): cluster_ret=%u DONE\n\r",
        (unsigned)cluster_ret);
    return (int)cluster_ret;
}
