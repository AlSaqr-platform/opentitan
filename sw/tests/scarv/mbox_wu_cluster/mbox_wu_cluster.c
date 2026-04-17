// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// mbox_wfe_host - Ibex side of the reverse-mailbox WFE test
//
// This test is the counterpart of
//   sw/tests/regression_tests/opentitan-cluster/mbox_wfe_test/test.c
//
// Scenario
// ========
// The cluster side configures EU event bit 22 (= mbox_irq_i) and executes a
// p.elw (Wait-For-Event) instruction.  This ibex program:
//
//   1. Enables the EDN entropy source (required for the SoC).
//   2. Configures and starts the PULP cluster.
//   3. Waits until the cluster has enabled the mailbox RCV interrupt path by
//      polling the IRQ_RCV_EN register - this is the cluster's "ready" signal.
//   4. Writes test data into the two mailbox letter registers.
//   5. Asserts IRQ_RCV_SET = 1 -> the mailbox asserts mbox_irq_i ->
//      EU bit 22 fires -> cluster core 0 wakes from WFE.
//   6. Waits for the cluster End-Of-Computation (EOC) flag.
//   7. Disables cluster fetch and exits.
//
// No PLIC-based interrupt is needed on the ibex side for this test; ibex is
// the sender/trigger and the cluster is the recipient.
//
// Mailbox register map (ibex side, from sw/tests/common/mailboxes.h)
// ===================================================================
//   MAILBOX_BASE_ADDR              = 0xBF010000
//   + ARCHI_MAILBOX_IRQ_RCV_STAT   = 0x40  -> 0xBF010040  (read: RCV pending)
//   + ARCHI_MAILBOX_IRQ_RCV_SET    = 0x44  -> 0xBF010044  (write 1: trigger)
//   + ARCHI_MAILBOX_IRQ_RCV_CLR    = 0x48  -> 0xBF010048  (write 1: clear)
//   + ARCHI_MAILBOX_IRQ_RCV_EN     = 0x4C  -> 0xBF01004C  (poll: cluster rdy)
//   + ARCHI_MAILBOX_LETTER0        = 0x80  -> 0xBF010080
//   + ARCHI_MAILBOX_LETTER1        = 0x84  -> 0xBF010084
//

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "utils.h"
#include "mailboxes.h"

/* -- Cluster control registers --------------------------------------------- */
/* Entry point in L2 where every cluster PE starts execution.                 */
#define CLUSTER_ENTRY_ADDR      0xA0008080
/* Per-core boot address registers (8 cores, 4-byte stride).                  */
#define CLUSTER_BOOT_ADDR_REG   0xB0200040
/* Security-island peripheral registers (mapped in ibex's address space).     */
#define CLUSTER_FETCH_EN_REG    0xBF000000   /* write 1 to start cluster      */
#define CLUSTER_EOC_REG         0xBF000004   /* read: non-zero = completed    */
#define CLUSTER_CLK_EN_REG      0xBF000008
#define CLUSTER_CLK_DIV_REG     0xBF00000C
#define OT_CLK_DIV_REG          0xBF000010
/* EDN entropy source enable.                                                 */
#define EDN_EN_ADDR_REG         0xC1170014
/* Number of compute cores in the PULP cluster.                               */
#define CLUSTER_NUM_CORES       8

/* -- Test data written into the mailbox ------------------------------------ */
#define TEST_LETTER0  0xBAADC0DE
#define TEST_LETTER1  0xDEADBEEF

int main(void)
{
    volatile int *p_reg;
    volatile int *fetch_en    = (int *)CLUSTER_FETCH_EN_REG;
    volatile int *eoc         = (int *)CLUSTER_EOC_REG;
    volatile int *edn_enable  = (int *)EDN_EN_ADDR_REG;

    /* -- Step 1: Enable EDN entropy source --------------------------------- */
    *edn_enable = 0x9996;

    /* -- Step 2: Configure and start the cluster --------------------------- */
    for (int i = 0; i < CLUSTER_NUM_CORES; i++) {
        volatile int *boot_addr = (int *)(CLUSTER_BOOT_ADDR_REG + 0x4 * i);
        *boot_addr = CLUSTER_ENTRY_ADDR;
    }

    /* Release all cluster cores.  They will boot, run cluster_core_init()
     * then enter main() where core 0 enables IRQ_RCV_EN and sleeps in WFE. */
    *fetch_en = 0x1;

    /* -- Step 3: Poll IRQ_RCV_EN - wait for cluster "ready" signal --------- */
    /*
     * Spinning here ensures we do not trigger the RCV interrupt before the
     * cluster EU mask is set and the core is actually sleeping.
     */
    p_reg = (int *)(MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_RCV_EN_OFFSET);
    while (*p_reg == 0) {
        /* busy-wait: cluster not ready yet */
    }

    /* -- Step 4: Write test data into the mailbox letters ------------------ */
    p_reg  = (int *)(MAILBOX_BASE_ADDR + ARCHI_MAILBOX_LETTER0_OFFSET);
    *p_reg = TEST_LETTER0;

    p_reg  = (int *)(MAILBOX_BASE_ADDR + ARCHI_MAILBOX_LETTER1_OFFSET);
    *p_reg = TEST_LETTER1;

    /* -- Step 5: Assert IRQ_RCV_SET to wake the cluster -------------------- */
    /*
     * Writing 1 to IRQ_RCV_SET while IRQ_RCV_EN=1 causes the mailbox to
     * assert rcv_irq_o = s_mbox2cl_irq = mbox_irq_i on the cluster.
     * The cluster_peripherals assigns this to s_cluster_events[I][0] which
     * cluster_event_map routes to EU event bit 22 for every PE.
     * Core 0 has bit 22 in its EU event mask -> it wakes from p.elw.
     */
    p_reg  = (int *)(MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_RCV_SET_OFFSET);
    *p_reg = 0x1;

    /* -- Step 6: Wait for cluster End-Of-Computation ----------------------- */
    while (!(*eoc)) {
        /* busy-wait */
    }

    /* -- Step 7: Disable cluster and exit ---------------------------------- */
    *fetch_en = 0x0;

    return 0;
}
