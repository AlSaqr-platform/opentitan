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


#include "./inc/drivers/inc/uart.h"
#include "./inc/string_lib/inc/string_lib.h"
#include "simple_system_common.h"
#include <stdbool.h>

//#define FPGA_EMULATION

int main(int argc, char **argv) {

   
  //#ifdef FPGA_EMULATION                  
  //int baud_rate = 9600;
  //int test_freq = 50000000;
  //#else
  // set_flls();
  int baud_rate = 115200;
  int test_freq = 50000000;
  //#endif
  
  int volatile  * plic_prio, * plic_en;
  int volatile * p_reg, * p_reg1;
  int a = 0xbaadf00d;
  
  uart_set_cfg(0,(test_freq/baud_rate)>>4);

  printf("FPGA test, only opentitan preloaded\n");
 
  unsigned val = 0x10000001;
  asm volatile("csrw mtvec, %0\n" : : "r"(val));

  unsigned val_1 = 0x00001808;  // Set global interrupt enable in ibex regs
  unsigned val_2 = 0x00000800;  // Set external interrupts

  printf("Enabling ibex irqs\n"); 
  asm volatile("csrw  mstatus, %0\n" : : "r"(val_1)); 
  asm volatile("csrw  mie, %0\n"     : : "r"(val_2));

  printf("Enabling the interrupt controller and the mbox irq\n");
  plic_prio  = (int *) 0x480001C0;  // Priority reg
  plic_en    = (int *) 0x4800030C;  // Enable reg

 *plic_prio  = 1;                   // Set mbox interrupt priority to 1
 *plic_en    = 0x00000010;          // Enable interrupt
 
  printf("Writing and reading to the mailbox\n");
  p_reg = (int *) 0x40002000;
 *p_reg = a;

  if(*p_reg == a){
    printf("R & W succeeded\n");
    //p_reg1 = (int *) 40002020;
    //*p_reg1 = 0x1;
  }
  else{
    printf("Test failed, the mbox has not been accessed correctly\n");
    return 0;
  }
 
  /////////////////////////// Wait for shared memory test to start ///////////////////////////////
  //printf("Test succeeded!!!\n");
  uart_wait_tx_done();
  while(1) asm volatile ("wfi"); // Ready to receive a command from the Agent --> Jump to the External_Irq_Handler 
  
  return 0;
  
}
