// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "utils.h"
#ifdef NO_STANDALONE
#include "host_uart.h"
#endif

#ifndef VERBOSE
#define VERBOSE 0
#endif
#define LOG(fmt, ...) do { if (VERBOSE) printf(fmt, ##__VA_ARGS__); } while (0)

// Scratch register offset (relative to HOST_REGS_BASE_ADDR) used for sync
#define HOST_SCRATCH_4_REG_OFFSET  0x10

// Synchronization values (ibex -> CVA6 via scratch 4)
#define SYNC_IBEX_READY  0xa5a5a5a5  // ibex interrupt setup done, CVA6 may send mbox message

int main(void) {
  int volatile * plic_prio, * plic_en;
  int volatile * p_reg;
  int a = 0;
  unsigned val = 0xe0000001;
  asm volatile("csrw mtvec, %0\n" : : "r"(val)); // move irq vector to SRAM base address

  unsigned val_1 = 0x00001808;      // Set global interrupt enable in ibex regs
  unsigned val_2 = 0x00000800;      // Set external interrupts

  asm volatile("csrw  mstatus, %0\n" : : "r"(val_1));
  asm volatile("csrw  mie, %0\n"     : : "r"(val_2));

  plic_prio  = (int *) 0xC800027C;  // Priority reg
  plic_en    = (int *) 0xC8002010;  // Enable reg

 *plic_prio  = 1;                   // Set mbox interrupt priority to 1
 *plic_en    = 0x80000000;          // Enable interrupt

  // Signal CVA6 that ibex interrupt setup is complete and we are ready to receive
  *(volatile int *)(HOST_REGS_BASE_ADDR + HOST_SCRATCH_4_REG_OFFSET) = SYNC_IBEX_READY;

  while(1)
    asm volatile ("wfi"); // Ready to receive a command from the Agent --> Jump to the External_Irq_Handler

  return 0;

}

void external_irq_handler(void)  {

  int mbox_id = 159;
  int a, b, c, e, d;
  int volatile * p_reg, * p_reg1, * plic_check, * p_reg2, * p_reg3, * p_reg4, * p_reg5 ;

//   //init pointer to check memory
  LOG("interrut received, entering ISR...\n\r");

  p_reg1 = (int *) (0x40000180); // mbox 1 LETTER0

  // start of """Interrupt Service Routine"""

  plic_check = (int *) 0xC8200004;
  while(*plic_check != mbox_id); //check wether the intr is the correct one

  p_reg = (int *) (0x40000104); // mbox 1 INT_SND_SET
 *p_reg = 0x00000000; //clearing the pending interrupt signal

  p_reg = (int *) (0x4000010C); // mbox 1 INT_SND_EN
 *p_reg = 0x00000000; // disable irq

  p_reg = (int *) (0x40000108); // mbox 1 INT_SND_CLR
 *p_reg = 0x00000001; // raise irq completion (mbox side)

 *plic_check = mbox_id; // completing interrupt (plic side)

  // check mbox content
  a = *p_reg1;

  if( a == 0xBAADC0DE){
    LOG("Received expected message from mailbox: 0x%08x\n\r", a);
     // Loop through mailboxes 0 to 9
  
        // Calculate the base address for mailbox 'i'
        // i << 8 is equivalent to i * 0x100
        
        int mbox_base = 0x40000000 + (7 << 8); 
        LOG("mbox_base %x", mbox_base);

        // INT_SND_EN register for the current mailbox (Offset 0x0C)
        p_reg = (volatile  int *) (mbox_base + 0x0C); 
        *p_reg = 0x00000001;

        // INT_SND_SET register for the current mailbox (Offset 0x04)
        p_reg = (volatile  int *) (mbox_base + 0x04); 
        *p_reg = 0x00000001;
    
      // completion interrupt to ariane agent if msg = expected msg
    //   p_reg = (int *) (0x4000070C); // mbox 7 INT_SND_EN
    //  *p_reg = 0x00000001;
    //   // completion interrupt to ariane agent if msg = expected msg
    //   p_reg = (int *) (0x40000704); // mbox 7 INT_SND_SET
    //  *p_reg = 0x00000001;
  }
  return;
}
