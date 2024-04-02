// Copyright (c) 2022 ETH Zurich and University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
//

#include "sw/device/silicon_creator/rom/uart.h"
#include "sw/device/silicon_creator/rom/string_lib.h"
#include "sw/tests/opentitan/common/utils.h"
#include <stdbool.h>

#define FPGA_EMULATION
// #define DEBUG

int main(int argc, char **argv) {

#ifdef DEBUG
  int * tmp;
  #ifndef FPGA_EMULATION
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
#endif


  int volatile  * plic_prio, * plic_en;
  int volatile * p_reg, * p_reg1, * edn_enable;
  int a = 0;

  unsigned val = 0xe0000001;
  asm volatile("csrw mtvec, %0\n" : : "r"(val));

  // edn_enable = (int *) 0xc1170014;
  // *edn_enable = 0x9996;

  unsigned val_1 = 0x00001808;  // Set global interrupt enable in ibex regs
  unsigned val_2 = 0x00000800;  // Set external interrupts

  asm volatile("csrw  mstatus, %0\n" : : "r"(val_1));
  asm volatile("csrw  mie, %0\n"     : : "r"(val_2));

  plic_prio  = (int *) 0xC800027C;  // Priority reg
  plic_en    = (int *) 0xC8002010;  // Enable reg

 *plic_prio  = 1;                   // Set mbox interrupt priority to 1
 *plic_en    = 0x80000000;          // Enable interrupt

  
  /////////////////////////// Wait for shared memory test to start ///////////////////////////////
#ifdef DEBUG
  printf("IBEX: going on wfi\r\n");
#endif

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

#ifdef DEBUG
  printf("IBEX: handler\r\n");
#endif

  p_reg = (int *) 0x10404020;
 *p_reg = 0x00000000;        //clearing the pending interrupt signal

 *plic_check = mbox_id;

  p_reg = (int *) 0x10404024;
 *p_reg = 0x00000001;

  return;
}
