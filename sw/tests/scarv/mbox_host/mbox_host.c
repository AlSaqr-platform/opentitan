// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "utils.h"
#include "host_uart.h"
#include "mailboxes.h"
#include "mbox_host.h"

// OpenTitan Library Includes
#include "sw/device/lib/dif/dif_rv_plic.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/runtime/irq.h"

// Global PLIC Handle
dif_rv_plic_t plic;

#ifndef VERBOSE
#define VERBOSE 1
#endif
#define LOG(fmt, ...) do { if (VERBOSE) printf(fmt, ##__VA_ARGS__); } while (0)

// Scratch register offset (relative to HOST_REGS_BASE_ADDR) used for sync
#define HOST_SCRATCH_4_REG_OFFSET  0x10

// Synchronization values (ibex -> CVA6 via scratch 4)
#define SYNC_IBEX_READY  0xa5a5a5a5  // ibex interrupt setup done, CVA6 may send mbox message

int main(void) {
  LOG("Starting mailbox host test...\n\r");
  // CPU interrupt configuration using helper routines
  irq_set_vector_offset(0xe0000001); // Sets mtvec (Base address 0xe0000000 + Vectored mode 1)
  irq_global_ctrl(true);             // Sets mstatus MIE bit (Global interrupt enable)
  irq_external_ctrl(true);           // Sets mie MEIE bit (External interrupt enable)

  // PLIC peripheral configuration
  plic.base_addr = mmio_region_from_addr(0xC8000000);
  (void)dif_rv_plic_reset(&plic);
  (void)dif_rv_plic_target_set_threshold(&plic, 0, 0);                  // Unmask interrupts above priority 0
  (void)dif_rv_plic_irq_set_priority(&plic, 159, 1);                    // Set mbox IRQ 159 to priority 1
  (void)dif_rv_plic_irq_set_enabled(&plic, 159, 0, kDifToggleEnabled);  // Enable mbox IRQ 159 for target 0

  // Signal CVA6 that ibex interrupt setup is complete and we are ready to receive
  *(volatile int *)(HOST_REGS_BASE_ADDR + HOST_SCRATCH_4_REG_OFFSET) = SYNC_IBEX_READY;

  while(1)
    asm volatile ("wfi"); // Ready to receive a command from the Agent --> Jump to the External_Irq_Handler

  return 0;

}

void external_irq_handler(void) {

  dif_rv_plic_irq_id_t irq_id;
  volatile int *p_reg;

  LOG("interrupt received, entering ISR...\n\r");

  // Claim the interrupt via PLIC library and verify it is the expected one
  if (dif_rv_plic_irq_claim(&plic, 0, &irq_id) != kDifOk || irq_id != MBOX_IRQ_ID) {
    LOG("Unexpected or failed IRQ claim: %d\n\r", (int)irq_id);
    if (irq_id != 0)
      (void)dif_rv_plic_irq_complete(&plic, 0, irq_id);
    return;
  }

  LOG("IRQ %d claimed, handling interrupt...\n\r", (int)irq_id);

  // Mailbox 1: clear and disable incoming interrupt, raise mbox-side completion
  const uintptr_t mbox1_base = MBOX_BASE_ADDR + (1 * MBOX_STRIDE);

  p_reg = (volatile int *)(mbox1_base + ARCHI_MAILBOX_IRQ_SND_SET_OFFSET);
  *p_reg = 0x00000000; // clear pending interrupt signal

  p_reg = (volatile int *)(mbox1_base + ARCHI_MAILBOX_IRQ_SND_EN_OFFSET);
  *p_reg = 0x00000000; // disable irq

  p_reg = (volatile int *)(mbox1_base + ARCHI_MAILBOX_IRQ_SND_CLR_OFFSET);
  *p_reg = 0x00000001; // raise irq completion (mbox side)

  // Complete the interrupt on the PLIC side
  (void)dif_rv_plic_irq_complete(&plic, 0, irq_id);

  // Check mailbox content
  int a = *(volatile int *)(mbox1_base + ARCHI_MAILBOX_LETTER0_OFFSET);

  if (a == 0xBAADC0DE) {
    LOG("Received expected message from mailbox: 0x%08x\n\r", a);

    // Send completion interrupt to CVA6 agent via mailbox 7
    const uintptr_t mbox7_base = MBOX_BASE_ADDR + (7 * MBOX_STRIDE);
    LOG("mbox7_base %x\n\r", (unsigned int)mbox7_base);

    p_reg = (volatile int *)(mbox7_base + ARCHI_MAILBOX_IRQ_SND_EN_OFFSET);
    *p_reg = 0x00000001;

    p_reg = (volatile int *)(mbox7_base + ARCHI_MAILBOX_IRQ_SND_SET_OFFSET);
    *p_reg = 0x00000001;
  }
}
