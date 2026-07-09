// Copyright 2026 ETH Zurich, University of Bologna and Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include "utils.h"
#include "mailboxes.h"

#include "sw/device/lib/dif/dif_rv_plic.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/runtime/irq.h"

// Cluster entry point override and iteration count — adjust per test.
// Set CLUSTER_ENTRY_ADDR to a non-zero address to override the cluster's
// default entry _start (0xA0008080). Set to 0 to keep the default.
#define CLUSTER_ENTRY_ADDR  0x0
#define NUM_ITERATIONS      4

// SoC peripheral addresses
#define ClusterFetchEnableReg  0xBF000000
#define ClusterClkEnReg        0xBF000008
#define EdnEnAddrReg           0xC1170014

static dif_rv_plic_t plic;

// Set by external_irq_handler once the cluster SND doorbell is acknowledged.
static volatile int doorbell_seen;

// Total number of genuine cluster doorbells serviced.
static volatile int doorbell_count;

int main(void) {
  volatile int *fetch_en        = (volatile int *)ClusterFetchEnableReg;
  volatile int *cluster_en      = (volatile int *)ClusterClkEnReg;
  volatile int *mailbox_letter0 = (volatile int *)(MAILBOX_BASE_ADDR + ARCHI_MAILBOX_LETTER0_OFFSET);
  volatile int *mailbox_letter1 = (volatile int *)(MAILBOX_BASE_ADDR + ARCHI_MAILBOX_LETTER1_OFFSET);
  volatile int *mailbox_reg;
  int had_error = 0;

  printf("Hello from IBEX!\r\n");

  // CPU interrupt setup
  irq_set_vector_offset(0xe0000001);
  irq_global_ctrl(true);
  irq_external_ctrl(true);

  // PLIC setup for the cluster-side mailbox IRQ
  plic.base_addr = mmio_region_from_addr(0xC8000000);
  (void)dif_rv_plic_reset(&plic);
  (void)dif_rv_plic_target_set_threshold(&plic, 0, 0);
  (void)dif_rv_plic_irq_set_priority(&plic, SECD_MBOX_IRQ_ID, 1);
  (void)dif_rv_plic_irq_set_enabled(&plic, SECD_MBOX_IRQ_ID, 0, kDifToggleEnabled);

  // Enable entropy distribution network
  *(volatile int *)EdnEnAddrReg = 0x9996;

  // Enable the cluster clock and instruction fetch for the whole test. The
  // RCV/SND mailbox handshake now provides all run-to-run synchronisation, so
  // the cluster clock no longer needs to be gated between iterations.
  *cluster_en = 0x1;
  *fetch_en   = 0x1;

  for (int i = 0; i < NUM_ITERATIONS; i++) {
#if CLUSTER_ENTRY_ADDR
    // Point the cluster at the requested entry point for this run.
    *mailbox_letter0 = ARCHI_MAILBOX_ENTRY_LOAD;
    *mailbox_letter1 = CLUSTER_ENTRY_ADDR;
#endif

    mailbox_reg  = (volatile int *)(MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_RCV_EN_OFFSET);
    *mailbox_reg = 0x1;
    mailbox_reg  = (volatile int *)(MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_RCV_SET_OFFSET);
    *mailbox_reg = 0x1;

    // Wait for the completion doorbell. wfi can wake for other reasons, so spin
    // until external_irq_handler confirms the mailbox IRQ was serviced.
    doorbell_seen = 0;
    do {
      asm volatile("wfi");
    } while (!doorbell_seen);

    // LETTER0 now holds the cluster return value. Read it, then neutralise the
    // register: it is reused as the OT->cluster entry token (== 0x1), so a stale
    // return value of 1 would be misread as a reload command on the next run.
    int retval = *mailbox_letter0;
    *mailbox_letter0 = 0;

    if (retval != 0) {
      had_error = 1;
      printf("Iteration %d: cluster returned error 0x%x\r\n", i, retval);
    }
  }

  if (doorbell_count != NUM_ITERATIONS) {
    had_error = 1;
    printf("Doorbell mismatch: serviced=%d expected=%d\r\n",
           doorbell_count, NUM_ITERATIONS);
  }

  return had_error;
}

void external_irq_handler(void) {
  dif_rv_plic_irq_id_t irq_id;
  volatile int *mailbox_reg;

  if (dif_rv_plic_irq_claim(&plic, 0, &irq_id) != kDifOk ||
      irq_id != SECD_MBOX_IRQ_ID) {
    if (irq_id != 0)
      (void)dif_rv_plic_irq_complete(&plic, 0, irq_id);
    return;
  }

  // Acknowledge the cluster-side SND doorbell
  mailbox_reg  = (volatile int *)(MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_SND_EN_OFFSET);
  *mailbox_reg = 0x0;
  mailbox_reg  = (volatile int *)(MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_SND_CLR_OFFSET);
  *mailbox_reg = 0x1;

  (void)dif_rv_plic_irq_complete(&plic, 0, irq_id);

  // Signal the main loop that a genuine cluster doorbell was serviced.
  doorbell_count++;
  doorbell_seen = 1;
}
