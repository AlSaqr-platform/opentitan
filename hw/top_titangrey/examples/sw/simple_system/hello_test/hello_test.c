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

#include "simple_system_common.h"
#include <stdbool.h>

#define TARGET_SYNTHESIS

int main(int argc, char **argv) {

   
  //  #ifdef TARGET_SYNTHESIS                
  int baud_rate = 115200;
  int test_freq = 50000000;
  //#else
  // set_flls();
  //int baud_rate = 115200;
  //int test_freq = 100000000;
  //#endif
  
  int volatile  * plic_prio, * plic_en;
  int volatile * p_reg, * p_reg1;
  int a = 0;
 
  unsigned val = 0xE0000001;
  asm volatile("csrw mtvec, %0\n" : : "r"(val));
  uart_set_cfg(0,(test_freq/baud_rate)>>4);

  printf("Hello World :) \r\n");
  printf("FPGA test, only opentitan preloaded. Performing some w/r to the mbox and other regfiles\r\n");

  unsigned val_1 = 0x00001808;  // Set global interrupt enable in ibex regs
  unsigned val_2 = 0x00000800;  // Set external interrupts

  printf("Enabling ibex irqs\r\n"); 
  asm volatile("csrw  mstatus, %0\n" : : "r"(val_1)); 
  asm volatile("csrw  mie, %0\n"     : : "r"(val_2));

  printf("Enabling the interrupt controller and the mbox irq\r\n");
  plic_prio  = (int *) 0xC80001C0;  // Priority reg
  plic_en    = (int *) 0xC800030C;  // Enable reg

 *plic_prio  = 1;                   // Set mbox interrupt priority to 1
 *plic_en    = 0x00000010;          // Enable interrupt
 
  printf("Writing and reading to the mailbox\r\n");
  p_reg = (int *) 0x10404000;
 *p_reg = 0xbaadc0de;

  a = *p_reg;
 
  if(a == 0xbaadc0de){
    printf("R & W succeeded\r\n");
    p_reg1 = (int *) 0x10404020;
    *p_reg1 = 0x1;
  }
  else{
    printf("Test failed, the mbox has not been accessed correctly\r\n");
    return 0;
  }
  
  /////////////////////////// Wait for shared memory test to start ///////////////////////////////
  //printf("Test succeeded!!!\r\n");

  while(1) asm volatile ("wfi"); // Ready to receive a command from the Agent --> Jump to the External_Irq_Handler 
  
  uart_wait_tx_done();
  return 0;
  
}
