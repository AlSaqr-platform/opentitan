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

int main(int argc, char **argv) {

  int * tmp;
  #ifdef FPGA_EMULATION
    tmp = (int *) 0x1a104004;
    *tmp = 3;
    tmp = (int *) 0x1a10400C;
    *tmp = 3;
    int baud_rate = 115200;
    int test_freq = 100000000;
  #else
    tmp = (int *) 0x1a104074;
    *tmp = 1;
    tmp = (int *) 0x1a10407C;
    *tmp = 1;
    int baud_rate = 115200;
    int test_freq = 40000000;
  #endif
  uart_set_cfg(0,(test_freq/baud_rate)>>4);

 /*
     scratch@1C000000 {
      device_type = "memory";
      reg = <0x0 0x1C000000 0x0 0x00008000>;
    };
 */

  int volatile  * plic_prio, * plic_en;
  int volatile * p_reg, * p_reg1, * edn_enable;
  int a = 0;

  unsigned val = 0xe0000001;
  asm volatile("csrw mtvec, %0\n" : : "r"(val));

  edn_enable = (int *) 0xc1170014;
 *edn_enable = 0x9996;

  printf("FPGA test with two indipendent JTAG for Ibex and Ariane\r\n");
  uart_wait_tx_done();
  unsigned val_1 = 0x00001808;  // Set global interrupt enable in ibex regs
  unsigned val_2 = 0x00000800;  // Set external interrupts

  asm volatile("csrw  mstatus, %0\n" : : "r"(val_1));
  asm volatile("csrw  mie, %0\n"     : : "r"(val_2));

  plic_prio  = (int *) 0xC800027C;  // Priority reg
  plic_en    = (int *) 0xC8002010;  // Enable reg

 *plic_prio  = 1;                   // Set mbox interrupt priority to 1
 *plic_en    = 0x80000000;          // Enable interrupt

  
  /////////////////////////// Wait for shared memory test to start ///////////////////////////////


  while(1)
    asm volatile ("wfi"); // Ready to receive a command from the Agent --> Jump to the External_Irq_Handler

  return 0;
}

void external_irq_handler(void){
  int mbox_id = 159;
  int volatile *plic_check, *p_reg;
  // start of """Interrupt Service Routine"""
  plic_check = (int *) 0xC8200004;
  while(*plic_check != mbox_id);   //check wether the intr is the correct one

  p_reg = (int *) 0x10404020;
 *p_reg = 0x00000000;        //clearing the pending interrupt signal

  uint8_t *data, *scratch, *mbox;
  uint32_t *door, *comp;
  data = (uint8_t*) 0x80700000;
  mbox = (uint8_t*) 0x10404000;
  scratch = (uint8_t*) 0x1C000000;
  door = (uint32_t*) 0x10404020;
  comp = (uint32_t*) 0x10404024;
  scratch[0] = data[0];
  scratch[1] = data[1];
  scratch[2] = data[2];
  scratch[3] = data[3];
  scratch[4] = mbox[0];
  scratch[5] = mbox[1];
  scratch[6] = mbox[2];
  scratch[7] = mbox[3];
  scratch[8] = 0xCC;
  scratch[9] = 0xCC;
  scratch[10] = 0xCC;
  scratch[11] = 0xCC;

  p_reg = (int *) 0x10404024; // completion interrupt to ariane agent
  *p_reg = 0x00000001;

  return;
}
