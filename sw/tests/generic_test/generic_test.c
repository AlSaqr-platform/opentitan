#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include "utils.h"

#define EntryAddr 0xA0008080
#define L1BaseAddr 0xB0000000
#define ClusterBootAddrReg 0xB0200040
#define ClusterFetchEnableReg 0xff000020
#define ClusterEocReg 0xff000024
#define ClusterNumCores 8
#define EdnEnAddrReg 0xc1170014
#define PlicPrioAddrReg 0xC800027C
#define PlicEnAddrReg 0xC8002010
#define PlicCheckAddrReg 0xC8200004

// Mailbox addresses //
#define MboxAddrReg0 0x10404008
#define MboxAddrReg1 0x10404010
#define MboxAddrReg2 0x10404014
#define MboxAddrReg3 0x10404018
#define MboxAddrReg4 0x1040401C
#define MboxIrqAddrReg 0x10404020


int main() {

  volatile int * fetch_en, * eoc, * edn_enable, * boot_addr, * plic_prio, * plic_en;
  volatile int * p_reg1, * p_reg2, * p_reg3, * p_reg4, * p_reg5;

  // Mbox interrupt configuration
  unsigned mtvec_cfg = 0xe0000001;
  asm volatile("csrw mtvec, %0\n" : : "r"(mtvec_cfg));

  unsigned mstatus_cfg = 0x00001808;  // Set global interrupt enable in ibex regs
  unsigned mie_cfg = 0x00000800;  // Set external interrupts

  asm volatile("csrw  mstatus, %0\n" : : "r"(mstatus_cfg));
  asm volatile("csrw  mie, %0\n"     : : "r"(mie_cfg));

  plic_prio  = (int *) PlicPrioAddrReg;  // Priority reg
  plic_en    = (int *) PlicEnAddrReg;  // Enable reg

 *plic_prio  = 1;                   // Set mbox interrupt priority to 1
 *plic_en    = 0x80000000;          // Enable interrupt

  // Configure fetch enable
  fetch_en = (int *) ClusterFetchEnableReg;
  eoc = (int *) ClusterEocReg;
  edn_enable = (int *) EdnEnAddrReg;
  *edn_enable = 0x9996;

  for (int i = 0; i < ClusterNumCores; i++) {
    boot_addr = (int *) (ClusterBootAddrReg + 0x4*i);
    *boot_addr = EntryAddr;
  }

  /////////////////////////
  // Cluster offloading  //
  /////////////////////////

  *fetch_en = 0x1;
  // wait for mbox doorbell irq
  asm volatile ("wfi");
  // wait for EOC (redundant)
  while(!(*eoc));
  *fetch_en = 0x0;

  /////////////////
  // Test Check  //
  /////////////////

  p_reg1 = (int *) MboxAddrReg0;
  p_reg2 = (int *) MboxAddrReg1;
  p_reg3 = (int *) MboxAddrReg2;
  p_reg4 = (int *) MboxAddrReg3;
  p_reg5 = (int *) MboxAddrReg4;

  if(*p_reg1 == 0xBAADC0DE && *p_reg2 == 0xBAADC0DE && *p_reg3 == 0xBAADC0DE && *p_reg4 == 0xBAADC0DE && *p_reg5 == 0xBAADC0DE){
    return 0;
  } else if(*p_reg1 != 0){
    return -1;
  } else {
    return 0;
  }
}

void external_irq_handler(void){
  int mbox_id = 159;
  int volatile * p_reg, * plic_check;

  // start of """Interrupt Service Routine"""
  plic_check = (int *) PlicCheckAddrReg;
  while(*plic_check != mbox_id);   //check wether the intr is the correct one

  p_reg = (int *) MboxIrqAddrReg;
 *p_reg = 0x00000000;        //clearing the pending interrupt signal
 *plic_check = mbox_id;      //completing interrupt

  return;
}