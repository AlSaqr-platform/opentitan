// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/base/abs_mmio.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/dif/dif_rv_plic.h"
#include "sw/device/lib/runtime/hart.h"
#include "sw/device/lib/runtime/irq.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "sw/device/lib/testing/test_framework/status.h"

#include "sw/device/silicon_creator/rom/string_lib.h"
#include "sw/device/silicon_creator/rom/uart.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "rv_plic_regs.h"  // Generated.

#define MBOX_ID 159

OTTF_DEFINE_TEST_CONFIG();

static const dif_rv_plic_target_t kPlicTarget = kTopEarlgreyPlicTargetIbex0;

static dif_rv_plic_t plic0;

static uint32_t external_intr_triggered = 0;
static uint32_t software_intr_triggered = 0;

// #define FPGA_EMULATION

void printf_init(void) {
  int * tmp;
  #ifdef FPGA_EMULATION
  /*
    tmp = (int *) 0x1a104004;
    *tmp = 3;
    tmp = (int *) 0x1a10400C;
    *tmp = 3;
  */
    int baud_rate = 115200;
    int test_freq = 100000000;
  #else
  /*
    tmp = (int *) 0x1a104074;
    *tmp = 1;
    tmp = (int *) 0x1a10407C;
    *tmp = 1;
  */
    int baud_rate = 115200;
    int test_freq = 40000000;
  #endif
  uart_set_cfg(0,(test_freq/baud_rate)>>4);
}

/**
 * Configures all interrupts in PLIC.
 */
static void plic_configure_irqs(dif_rv_plic_t *plic) {

  printf("IBEX: plic_configure_irqs 1\r\n");

  // Set IRQ priorities to MAX and Enable the IRQ
  CHECK_DIF_OK(dif_rv_plic_irq_set_priority(plic, MBOX_ID, kDifRvPlicMaxPriority));
  CHECK_DIF_OK(
      dif_rv_plic_irq_set_enabled(plic, MBOX_ID, kPlicTarget, kDifToggleEnabled));

  // Set Ibex IRQ priority threshold level
  CHECK_DIF_OK(dif_rv_plic_target_set_threshold(plic, kPlicTarget,
                                                kDifRvPlicMinPriority));

  printf("IBEX: plic_configure_irqs 2\r\n");
}

/**
 * External ISR.
 *
 * PLIC interrupt triggers ottf_external_isr() function. The expectation is
 * MSIP triggers this. Inside the routine, it reads all Interrupt Pending bits
 * and confirms only MSIP occurs.
 */
void ottf_external_isr(void) {

  printf("IBEX: ottf_external_isr 1\r\n");

  dif_rv_plic_irq_id_t interrupt_id;

  ++external_intr_triggered;
  test_status_set(kTestStatusFailed);

  printf("IBEX: ottf_external_isr 2\r\n");

  // Clean up external ISRs (claim & complete)
  CHECK_DIF_OK(dif_rv_plic_irq_claim(&plic0, kPlicTarget, &interrupt_id));
  CHECK_DIF_OK(dif_rv_plic_irq_complete(&plic0, kPlicTarget, interrupt_id));

  printf("IBEX: ottf_external_isr 3\r\n");
}

/**
 * Software ISR
 *
 * Only SW ISR should occur in this test.
 */
void ottf_software_isr(void) {
  printf("IBEX: ottf_software_isr 1\r\n");
  ++software_intr_triggered;

  // Clean up software ISRs (claim? clear?)
  CHECK_DIF_OK(dif_rv_plic_software_irq_acknowledge(&plic0, kPlicTarget));

  printf("IBEX: ottf_software_isr 2\r\n");
}

int main(int argc, char **argv) {
  // Enable IRQs on Ibex

  printf_init();
  printf("IBEX: MAIN 1\r\n");

  irq_global_ctrl(true);
  irq_external_ctrl(true);

  mmio_region_t plic_base_addr =
      mmio_region_from_addr(TOP_EARLGREY_RV_PLIC_BASE_ADDR);
  CHECK_DIF_OK(dif_rv_plic_init(plic_base_addr, &plic0));

  plic_configure_irqs(&plic0);

  // Enable MSIE
  irq_software_ctrl(true);

  uint32_t *p_reg;
  p_reg = (uint32_t *) 0x10404020;
  printf("IBEX: A %d\r\n", *p_reg);
  *p_reg = 0x00000000;
  printf("IBEX: B %d\r\n", *p_reg);

  while(1){}
  // *p_reg = 0x00000001;
  // printf("DONE\r\n");

  return false;
}