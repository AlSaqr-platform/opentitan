#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include "utils.h"
#include "mailboxes.h"
#ifdef NO_STANDALONE
#include "host_uart.h"
#endif

// memory defines
#define EntryAddr 0xA0008080
#define L1BaseAddr 0xB0000000
// cluster defines
#define ClusterNumCores 8
#define ClusterBootAddrReg 0xB0200040
#define ClusterFetchEnableReg 0xBF000000
#define ClusterEocReg 0xBF000004
#define ClusterClkEnReg 0xBF000008
#define ClusterClkDivReg 0xBF00000C
// OT defines
#define OtClkDivReg 0xBF000010
#define EdnEnAddrReg 0xc1170014
#define PlicCheckAddrReg 0xC8200004 // CC0
#define PlicIntEnAddrReg 0xC8002010 // IE0_4
#define PlicPrioAddrReg 0xC800027C // int line 159

int main() {

  volatile int * fetch_en, * cluster_en, * cl_clk_div, * ot_clk_div, * eoc, * edn_enable, * boot_addr, * plic_prio, * plic_int_en;
  volatile int * p_reg1, * p_reg2, * p_reg3, * p_reg4, * p_reg5;

  #ifdef NO_STANDALONE
  uint32_t reset_freq = 100035000; // FIXME Fixed value exctracted from Cheshire
  host_uart_init(HOST_UART_BASE_ADDR, reset_freq, BAUDRATE);
  #endif

  // Mbox interrupt configuration
  unsigned mtvec_cfg = 0xe0000001;
  asm volatile("csrw mtvec, %0\n" : : "r"(mtvec_cfg));

  unsigned mstatus_cfg = 0x00001808;  // Set global interrupt enable in ibex regs
  unsigned mie_cfg = 0x00000800;  // Set external interrupts

  asm volatile("csrw  mstatus, %0\n" : : "r"(mstatus_cfg));
  asm volatile("csrw  mie, %0\n"     : : "r"(mie_cfg));

  plic_prio   = (int *) PlicPrioAddrReg;  // Priority reg
  plic_int_en = (int *) PlicIntEnAddrReg;  // Interrupt Enable reg

 *plic_prio   = 1;                   // Set mbox interrupt priority to 1
 *plic_int_en = 0x80000000;          // Enable interrupt for interrupt line 159 inside register IE0_4


  // Configure fetch enable
  fetch_en = (int *) ClusterFetchEnableReg;
  cluster_en = (int *) ClusterClkEnReg;
  eoc = (int *) ClusterEocReg;
  cl_clk_div = (int *) ClusterClkDivReg;
  ot_clk_div = (int *) OtClkDivReg;

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

  p_reg1 = (int *) (MAILBOX_BASE_ADDR + ARCHI_MAILBOX_LETTER0_OFFSET);
  p_reg2 = (int *) (MAILBOX_BASE_ADDR + ARCHI_MAILBOX_LETTER1_OFFSET);
  p_reg3 = 0;
  p_reg4 = 0;
  p_reg5 = 0;

  if(*p_reg1 == 0xBAADC0DE && *p_reg2 == 0xBAADC0DE && *p_reg3 == 0xBAADC0DE && *p_reg4 == 0xBAADC0DE && *p_reg5 == 0xBAADC0DE){
    return 0;
  } else if(*p_reg1 != 0){
    return -1;
  } else {
    return 0;
  }
}

void external_irq_handler(void){
  int mbox_id = EXT_MBOX_IRQ_ID; // for external irq on line 159
  int volatile * p_reg, * plic_check;

  // start of """Interrupt Service Routine"""
  plic_check = (int *) PlicCheckAddrReg;
  while(*plic_check != mbox_id);   //check whether the intr is the correct one

  p_reg = (int *) (MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_SND_SET_OFFSET);
 *p_reg = 0x00000000;         // clean MAILBOX_IRQ_SND_SET
  p_reg = (int *) (MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_SND_EN_OFFSET);
 *p_reg = 0x00000000;         // clean MAILBOX_IRQ_SND_EN
  p_reg = (int *) (MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_SND_CLR_OFFSET);
 *p_reg = 0x00000001;         // clean MAILBOX_IRQ_SND_CLR

 *plic_check = mbox_id;      //completing interrupt

  return;
}
