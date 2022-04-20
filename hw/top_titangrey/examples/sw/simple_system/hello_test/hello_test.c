
// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"
#include <stdbool.h>

int main(int argc, char **argv) {

  #define PLIC_BASE     0x48000000
  #define PLIC_PRIO     PLIC_BASE + 0x030
  #define PLIC_CHECK    PLIC_BASE + 0x31C
  
  //enable bits for sources 0-31
  #define PLIC_EN_BITS  PLIC_BASE + 0x300
  
  int a, b, c, d, e, f;
  int volatile * p_reg, * p_reg1, * p_reg2, * p_reg3, * p_reg4, * p_reg5, * plic_check, * plic_prio, * plic_en, * ibex_intr_setup;
  int mbox_id = 100;

  unsigned val_1 = 0x00001808;  //set global interrupt enable in ibex regs
  unsigned val_2 = 0x00000800;  //set external interrupts
  
  asm volatile("csrw  mstatus, %0\n" : : "r"(val_1)); 
  asm volatile("csrw  mie, %0\n"     : : "r"(val_2));

  // init pointers for mem test
  
  p_reg  = (int *) 0x50000004;
  p_reg1 = (int *) 0x50000008;
  p_reg2 = (int *) 0x50000010;
  p_reg3 = (int *) 0x50000014;
  p_reg4 = (int *) 0x50000018;
  p_reg5 = (int *) 0x5000001C;
  
  //set mbox interrupt
  
  plic_prio  = (int *) 0x480001C0;  //priority reg
  plic_en    = (int *) 0x4800030C;  //enable reg

 *plic_prio  = 1;                   // set mbox interrupt priority to 1
 *plic_en    = 0x00000010;          // enable interrupt                       
   

  /////////////////////////// shared memory test start ///////////////////////////////

  asm volatile ("wfi");

  /* plic_check = (int *) 0x4800031C;
  while(*plic_check != mbox_id) 
    asm volatile ("wfi");
  
  // start of """Interrupt Service Routine"""
  
  p_reg = (int *) 0x50000020;
  
 *p_reg      = 0x00000000;
 *plic_check = mbox_id;
  
  // end   of """Interrupt Service Routine"""

  a = *p_reg1;
  b = *p_reg2;
  c = *p_reg3;
  d = *p_reg4;
  e = *p_reg5;

  if( a == 0xBAADC0DE && b == 0xBAADC0DE && c == 0xBAADC0DE && d == 0xBAADC0DE && e == 0xBAADC0DE){
      p_reg = (int *) 0x50000024; // completion interrupt
     *p_reg = 0x00000001;
  }
  else{
     sim_halt();
  }
  
  while(1);
  sim_halt();

 */
  return 0;
  
}
