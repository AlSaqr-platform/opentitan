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
#define CLUSTER_ENTRY_ADDR  0
#define NUM_ITERATIONS      4

// SoC peripheral addresses
#define ClusterFetchEnableReg  0xBF000000
#define ClusterClkEnReg        0xBF000008
#define EdnEnAddrReg           0xC1170014

static dif_rv_plic_t plic;

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

  // Override the cluster entry point if requested
#if CLUSTER_ENTRY_ADDR
  *mailbox_letter0 = ARCHI_MAILBOX_ENTRY_LOAD;
  *mailbox_letter1 = CLUSTER_ENTRY_ADDR;
#endif

  // Arm the RCV mailbox event. On a fresh boot the cluster event unit is not
  // yet initialised so this fires harmlessly. After a host-only PC reset the
  // cluster is already be sitting in pos_wait_forever(), in which case this
  // wakes it without needing an additional RCV arm inside the loop.
  mailbox_reg  = (volatile int *)(MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_RCV_EN_OFFSET);
  *mailbox_reg = 0x1;
  mailbox_reg  = (volatile int *)(MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_RCV_SET_OFFSET);
  *mailbox_reg = 0x1;

  for (int i = 0; i < NUM_ITERATIONS; i++) {
    *cluster_en = 0x1;
    *fetch_en   = 0x1;

    asm volatile("wfi");

    *cluster_en = 0x0;

    if (*mailbox_letter0 != 0) {
      had_error = 1;
      printf("Iteration %d: cluster returned error 0x%x\r\n", i, *mailbox_letter0);
    }

    if (i < NUM_ITERATIONS - 1) {
#if CLUSTER_ENTRY_ADDR
      *mailbox_letter0 = ARCHI_MAILBOX_ENTRY_LOAD;
      *mailbox_letter1 = CLUSTER_ENTRY_ADDR;
#endif

      for (volatile int j = 0; j < 1000; j++);

      *cluster_en = 0x1;

      mailbox_reg  = (volatile int *)(MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_RCV_EN_OFFSET);
      *mailbox_reg = 0x1;
      mailbox_reg  = (volatile int *)(MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_RCV_SET_OFFSET);
      *mailbox_reg = 0x1;
    }
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
}
