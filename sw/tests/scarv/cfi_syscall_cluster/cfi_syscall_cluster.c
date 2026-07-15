// Copyright 2026 Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// cfi_syscall_cluster.c — Ibex side: mailbox relay for the cluster CFI inspector
//
// Paired with:
//   regression_tests/opentitan-cluster/cfi_syscall_cluster/test.c  (PULP cluster)
//   sw/tests/linux/cfi_syscall_monitor.c                            (CVA6/Linux)
//
// Derived from cluster_offload.c.  This firmware deliberately keeps ONLY the
// mailbox mechanism — it owns no snooper, VA->PA table or scratch-14 logic.
// All CFI work (snooper config, ring inspection, basic-block fetch, result
// write-back to CVA6) runs on the cluster; see the paired test.c.
//
// Responsibilities
// ----------------
//   1. Boot the PULP cluster (the cluster binary does everything else).
//   2. Own PLIC IRQ 159 — the CVA6 -> Ibex mailbox 1 doorbell that the Linux
//      monitor rings on every sensitive syscall (and once for app-done).
//   3. On each doorbell: read mailbox-1 letter0, clear the mailbox-1 interrupt,
//      forward the message word into the SECD mailbox letter0, and ring the
//      SECD RCV doorbell to kick cluster core 0.  Nothing more — the cluster
//      reads the snooper window and writes the result back to CVA6 itself.
//   4. Own PLIC IRQ 160 — the cluster's SECD SND doorbell, rung once when the
//      monitored app has exited.  Collect the return value and leave WFI.
//
// Message flow for one syscall
// ----------------------------
//   CVA6 : scratch14 = BUSY; mbox1.letter0 = CFI_MSG_SYSCALL|nr; ring mbox1
//   Ibex : IRQ159 -> forward letter0 to SECD mbox; ring SECD RCV
//   CL0  : RCV pending -> inspect snooper window -> scratch14 = PASS
//   CVA6 : polls scratch14 until != BUSY

#include <stdio.h>
#include "utils.h"
#include "mailboxes.h"

#include "sw/device/lib/dif/dif_rv_plic.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/runtime/irq.h"

#ifndef VERBOSE
#define VERBOSE 1
#endif
#define LOG(fmt, ...) do { if (VERBOSE) printf(fmt, ##__VA_ARGS__); } while (0)

// ---------------------------------------------------------------------------
// CVA6 <-> Ibex mailbox (the syscall doorbell channel).
// Mailbox 1 = MBOX_BASE_ADDR + 1 * MBOX_STRIDE; incoming doorbell = SND side.
// This is a distinct peripheral from the SECD (Ibex <-> cluster) mailbox that
// mailboxes.h/MAILBOX_BASE_ADDR refers to.
// ---------------------------------------------------------------------------
#define MBOX_BASE_ADDR   0x40000000u
#define MBOX_STRIDE      0x100u
#define MBOX1_BASE       (MBOX_BASE_ADDR + 1u * MBOX_STRIDE)
#define MBOX_IRQ_ID      159             // PLIC line for the mbox 1 doorbell

// Per-syscall message encoding (must match cfi_syscall_proto.h / the monitor).
#define CFI_MSG_TYPE_MASK   0xFF000000u
#define CFI_MSG_SYSCALL     0x01000000u
#define CFI_MSG_APP_DONE    0x02000000u

// ---------------------------------------------------------------------------
// SECD mailbox (Ibex -> cluster kick + cluster -> Ibex done).
// MAILBOX_BASE_ADDR comes from mailboxes.h (0xBF010000); SECD_MBOX_IRQ_ID = 160.
// ---------------------------------------------------------------------------
#define SECD_MBOX_BASE   MAILBOX_BASE_ADDR

// ---------------------------------------------------------------------------
// Cluster boot / SoC control registers
// ---------------------------------------------------------------------------
#define CLUSTER_BOOT_ADDR_REG   0xB0200040u
#define CLUSTER_FETCH_EN_REG    0xBF000000u
#define CLUSTER_CLK_EN_REG      0xBF000008u
#define EDN_EN_ADDR_REG         0xC1170014u
#define CLUSTER_NUM_CORES       8u
#define CLUSTER_ENTRY_ADDR      0xA0008080u   // cluster binary entry (L2)

static dif_rv_plic_t plic;

// Written by external_irq_handler once the cluster signals app-done.
static volatile int cluster_done = 0;
static volatile int cluster_ret  = 0;

// ---------------------------------------------------------------------------
// Boot the cluster (the cluster binary is already loaded at CLUSTER_ENTRY_ADDR)
// ---------------------------------------------------------------------------
static void cluster_boot(void) {
    *(volatile uint32_t *)EDN_EN_ADDR_REG = 0x9996u;
    for (uint32_t i = 0; i < CLUSTER_NUM_CORES; i++)
        *(volatile uint32_t *)(CLUSTER_BOOT_ADDR_REG + 4u * i) = CLUSTER_ENTRY_ADDR;
    *(volatile uint32_t *)CLUSTER_CLK_EN_REG   = 0x1u;
    *(volatile uint32_t *)CLUSTER_FETCH_EN_REG = 0x1u;
    fence();

    // Kick the cluster to start via the SECD RCV doorbell (as cluster_offload
    // does).  This start pulse is cleared by the cluster during its setup,
    // before it acks CVA6 — so it never registers as a spurious syscall.
    *(volatile uint32_t *)(SECD_MBOX_BASE + ARCHI_MAILBOX_IRQ_RCV_EN_OFFSET)  = 0x1u;
    *(volatile uint32_t *)(SECD_MBOX_BASE + ARCHI_MAILBOX_IRQ_RCV_SET_OFFSET) = 0x1u;
    fence();
}

// ---------------------------------------------------------------------------
// external_irq_handler — mailbox relay only.
// ---------------------------------------------------------------------------
void external_irq_handler(void) {
    dif_rv_plic_irq_id_t irq_id;
    if (dif_rv_plic_irq_claim(&plic, 0, &irq_id) != kDifOk)
        return;

    if (irq_id == MBOX_IRQ_ID) {
        // CVA6 syscall / app-done doorbell.  Snapshot the message, then clear
        // the mbox 1 interrupt so a subsequent doorbell can be detected.
        // LOG("[secd] cfi_syscall_arrived: passing to cluster\r\n");
        uint32_t msg =
            (uint32_t)*(volatile int *)(MBOX1_BASE + ARCHI_MAILBOX_LETTER0_OFFSET);

        volatile int *p;
        p = (volatile int *)(MBOX1_BASE + ARCHI_MAILBOX_IRQ_SND_SET_OFFSET); *p = 0;
        p = (volatile int *)(MBOX1_BASE + ARCHI_MAILBOX_IRQ_SND_EN_OFFSET);  *p = 0;
        p = (volatile int *)(MBOX1_BASE + ARCHI_MAILBOX_IRQ_SND_CLR_OFFSET); *p = 1;
        fence();

        // Forward the message to the cluster and ring the SECD RCV doorbell.
        // The cluster keeps RCV_EN asserted; we set it here too for safety.
        *(volatile uint32_t *)(SECD_MBOX_BASE + ARCHI_MAILBOX_LETTER0_OFFSET)     = msg;
        *(volatile uint32_t *)(SECD_MBOX_BASE + ARCHI_MAILBOX_IRQ_RCV_EN_OFFSET)  = 1u;
        *(volatile uint32_t *)(SECD_MBOX_BASE + ARCHI_MAILBOX_IRQ_RCV_SET_OFFSET) = 1u;
        fence();

        (void)dif_rv_plic_irq_complete(&plic, 0, irq_id);
    } else if (irq_id == SECD_MBOX_IRQ_ID) {
        // Cluster finished the monitored app.  Collect the return value and
        // clear the SECD SND interrupt.
        cluster_ret =
            (int)*(volatile uint32_t *)(SECD_MBOX_BASE + ARCHI_MAILBOX_LETTER0_OFFSET);

        volatile uint32_t *p;
        p = (volatile uint32_t *)(SECD_MBOX_BASE + ARCHI_MAILBOX_IRQ_SND_SET_OFFSET); *p = 0;
        p = (volatile uint32_t *)(SECD_MBOX_BASE + ARCHI_MAILBOX_IRQ_SND_EN_OFFSET);  *p = 0;
        p = (volatile uint32_t *)(SECD_MBOX_BASE + ARCHI_MAILBOX_IRQ_SND_CLR_OFFSET); *p = 1;
        fence();

        cluster_done = 1;
        (void)dif_rv_plic_irq_complete(&plic, 0, irq_id);
    } else {
        if (irq_id != 0)
            (void)dif_rv_plic_irq_complete(&plic, 0, irq_id);
    }
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------
int main(void) {
    // LOG("[secd] cfi_syscall_cluster (ibex): start\r\n");

    // Interrupt / PLIC setup — enable both the CVA6 mbox 1 doorbell (159) and
    // the cluster SECD SND doorbell (160).
    irq_set_vector_offset(0xe0000001);
    irq_global_ctrl(true);
    irq_external_ctrl(true);

    plic.base_addr = mmio_region_from_addr(0xC8000000);
    (void)dif_rv_plic_reset(&plic);
    (void)dif_rv_plic_target_set_threshold(&plic, 0, 0);
    (void)dif_rv_plic_irq_set_priority(&plic, MBOX_IRQ_ID, 1);
    (void)dif_rv_plic_irq_set_enabled(&plic, MBOX_IRQ_ID, 0, kDifToggleEnabled);
    (void)dif_rv_plic_irq_set_priority(&plic, SECD_MBOX_IRQ_ID, 1);
    (void)dif_rv_plic_irq_set_enabled(&plic, SECD_MBOX_IRQ_ID, 0, kDifToggleEnabled);

    // Boot the cluster; it runs the whole CFI inspector and talks to CVA6
    // directly.  Ibex only relays mailbox traffic from here on.
    cluster_boot();
    // LOG("[secd] cluster booted, relaying syscall doorbells\r\n");

    // Sleep until the cluster signals app-done via the SECD SND doorbell.
    while (!cluster_done)
        asm volatile ("wfi");

    // Cleanup: gate the cluster fetch. (The cluster disarms the snooper.)
    *(volatile uint32_t *)CLUSTER_FETCH_EN_REG = 0x0u;

    LOG("[secd] cfi_syscall_cluster (ibex): cluster_ret=%u DONE\r\n",
        (unsigned)cluster_ret);
    return cluster_ret;
}
