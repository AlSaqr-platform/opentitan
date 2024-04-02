// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/runtime/ibex.h"
#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/silicon_creator/rom/uart.h"
#include "sw/device/silicon_creator/rom/string_lib.h"

#include "sw/tests/opentitan/titanssl/titanssl_lib/headers/titanssl_utils.h"

uint32_t t_start;

// -------------------- PRINTF --------------------

void utils_printf_init(void) {

  int * tmp;
  #ifndef CFG_FPGA_EMULATION
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

}

void utils_printf_mbox() {
  for (int i=0; i<10; i++) {
    printf("[IBEX MBOX] reg %d:     0x%08x\r\n", i,
      ((uint32_t*) TITANSSL_MBOX_BASE)[i]); 
    uart_wait_tx_done();
  }
}

void utils_printf_scratch(uint32_t offset, uint32_t size) {
  if(offset + size < TITANSSL_SCRATCHPAD_SIZE) {
    for (int i=0; i<size/4; i++) {
      printf("[IBEX SCRATCH] %d:     0x%08x\r\n", i,
        ((uint32_t*) (TITANSSL_SCRATCHPAD_BASE + offset))[i]);
      uart_wait_tx_done();
    }
  } else {
    printf("error\r\n");
  }
}

// -------------------- MBOX --------------------
void utils_mbox_init(titanssl_mbox_t* titanssl_mbox) {
#if CFG_CVA6_STATUS < 2
  titanssl_mbox->code = TITANSSL_CODE;
  titanssl_mbox->in_size = TITANSSL_INPUT_SIZE;
  titanssl_mbox->bitfield = 0x00000000;

  uint8_t* p;
  uint32_t nb = 5;
  uint32_t npxb = (TITANSSL_PAGE_SIZE / sizeof(titanssl_batch_t));
  size_t bi = 0;

  for (size_t k = 0; k < nb; k++) {
    if (bi >= TITANSSL_INPUT_SIZE) {
      titanssl_mbox->p_index[k] = 0x0;
    } else {
      titanssl_mbox->p_index[k] = (titanssl_batch_t*) (TITANSSL_BATCH_BASE + k * TITANSSL_PAGE_SIZE);
      for (size_t i = 0; i < npxb; i++) {
        p = (uint8_t*)(TITANSSL_DATA_BASE + k * TITANSSL_PAGE_SIZE * npxb + i * TITANSSL_PAGE_SIZE);
        titanssl_mbox->p_index[k][i].page = p;
        for (size_t j = 0; j < TITANSSL_PAGE_SIZE; j++) {
          if (bi < TITANSSL_INPUT_SIZE) {
            p[j] = 0x00;
            bi++;
          } else {
            break;
          }
        }
        if (bi >= TITANSSL_INPUT_SIZE) {
          break;
        }
      }
    }
  }
#endif
}

void utils_mbox_read(titanssl_mbox_t* t_mbox, titanssl_mbox_t* titanssl_mbox) {

  memcpy(t_mbox, titanssl_mbox, sizeof(titanssl_mbox_t));

#if CFG_CVA6_STATUS == 1
  uint8_t* p;
  uint32_t l = (TITANSSL_INPUT_SIZE + TITANSSL_PAGE_SIZE -1 ) / TITANSSL_PAGE_SIZE;
  for (size_t k=0; k<l/TITANSSL_PAGE_SIZE+1; k++) {
    t_mbox->p_index[k] = (titanssl_batch_t*) (TITANSSL_BATCH_BASE + k*TITANSSL_PAGE_SIZE);
    for (size_t i=0; i<l || i<TITANSSL_PAGE_SIZE; i++) {
      p = (uint8_t*)(TITANSSL_DATA_BASE + i*TITANSSL_PAGE_SIZE);
      t_mbox->p_index[k][i].page = p;
    }
  }
#endif
}

// -------------------- SCRATCHPAD  --------------------

void utils_scratch_write(titanssl_batch_t* batch, uint32_t offset, uint32_t size) {
  static titanssl_batch_t titanssl_scratch;
  titanssl_scratch.page = (uint8_t*)TITANSSL_SCRATCHPAD_BASE+offset;
  memcpy(titanssl_scratch.page, batch->page, size);
}

// --------------------  IBEX l1 SCRATCHPAD  --------------------

void utils_ibexl1_init(uint32_t size, uint8_t* addr) {
  static titanssl_batch_t batch;
  batch.page = (uint8_t*)addr;
  for (size_t j=0; j<size; j++) batch.page[j] = 0x00;
}

// --------------------  DRAM  --------------------

void utils_dram_readp(titanssl_mbox_t* mbox, titanssl_batch_t* l1, uint32_t n) {
  uint32_t c, b;
  b = n/(TITANSSL_PAGE_SIZE*TITANSSL_PAGE_SIZE/4);
  c = n/TITANSSL_PAGE_SIZE - b*TITANSSL_PAGE_SIZE/4;
#if CFG_L3_TEST == 0
  if(b<5 && c<1024) // write better
    memcpy(l1->page, mbox->p_index[b][c].page, TITANSSL_PAGE_SIZE);
  else
    l1->page = NULL;
#else
  if(b<5 && c<1024) // write better
    l1->page = mbox->p_index[b][c].page;
  else
    l1->page = NULL;
#endif
}

// -------------------- ENTROPY --------------------

void utils_entropy_init(void) {
 
  int volatile * edn_enable, * csrng_enable, * entropy_src_enable;

  entropy_src_enable = (int *) 0xc1160024;
  *entropy_src_enable = 0x00909099;
 
  entropy_src_enable = (int *) 0xc1160020;
  *entropy_src_enable = 0x00000006;
 
  csrng_enable = (int *) 0xc1150014;
  *csrng_enable = 0x00000666;
 
  edn_enable = (int *) 0xc1170014;
  *edn_enable = 0x00009966;
}

// -------------------- PROFILE --------------------

uint64_t utils_profile_timing() { return ibex_mcycle_read(); }

void utils_profile_start(){
  t_start = utils_profile_timing();
}

void _utils_profile_analyses(uint64_t t_s, uint64_t t_e, char *msg) {
  uint32_t cycles;
  cycles = t_e - t_s;
  if(DEB) printf("[IBEX PROFILE] %s took %u cycles.\r\n", msg, cycles);
  // if cva6 enable put in dram  ++ 
}

void utils_profile_analyses(char *msg) {
  uint32_t t_end;
  t_end = utils_profile_timing();
  _utils_profile_analyses(t_start, t_end, msg);
  t_start = utils_profile_timing();
}

// -------------------- IRQ --------------------

void utils_irq_reset_door(){
  uint32_t* doorbell = (uint32_t *) TITANSSL_MBOX_DOORBELL;
 *doorbell = 0x00000000;
}

void utils_irq_trig_door(){
  uint32_t* doorbell = (uint32_t *) TITANSSL_MBOX_DOORBELL;
 *doorbell = 0x00000001;
}

void utils_irq_reset_comp(){
  uint32_t* completion = (uint32_t *) TITANSSL_MBOX_COMPLETION;
 *completion = 0x00000000;
}

void utils_irq_trig_comp(){
  uint32_t* completion = (uint32_t *) TITANSSL_MBOX_COMPLETION;
 *completion = 0x00000001;
}

void utils_irq_enable(){
  int volatile  *plic_prio, *plic_en, *edn_enable;
  unsigned val = 0xe0000001;
  asm volatile("csrw mtvec, %0\n" : : "r"(val));
  unsigned val_1 = 0x00001808;  // Set global interrupt enable in ibex regs
  unsigned val_2 = 0x00000800;  // Set external interrupts
  asm volatile("csrw  mstatus, %0\n" : : "r"(val_1));
  asm volatile("csrw  mie, %0\n"     : : "r"(val_2));
  plic_prio  = (int *) 0xC800027C;  // Priority reg
  plic_en    = (int *) 0xC8002010;  // Enable reg
 *plic_prio  = 1;                   // Set mbox interrupt priority to 1
 *plic_en    = 0x80000000;          // Enable interrupt
}

void utils_irq_check(){
  int volatile *plic_check;
  plic_check = (int *) 0xC8200004;
  while(*plic_check != TITANSSL_MBOX_ID);   //check wether the intr is the correct one
}

void utils_irq_end(){
  int volatile *plic_check;
  plic_check = (int *) 0xC8200004;
  *plic_check = TITANSSL_MBOX_ID;
}