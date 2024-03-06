// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/runtime/ibex.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/silicon_creator/rom/uart.h"
#include "sw/device/silicon_creator/rom/string_lib.h"

#include "sw/tests/opentitan/titanssl/titanssl_lib/headers/titanssl_utils.h"

uint32_t flag = 0;

// -------------------- PRINTF --------------------

void utils_printf_init(void) {

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

}

void utils_printf_mbox() {
  for (int i=0; i<10; i++) {
    printf("[IBEX MBOX] reg %d:     0x%08x\r\n", i,
      ((uint32_t*) TITANSSL_MBOX_BASE)[i]); 
    uart_wait_tx_done();
  }
}

void utils_printf_input(titanssl_mbox_t* titanssl_mbox) {
  uint32_t r,c;
  for (size_t i=0; i<(titanssl_mbox->in_size)/4; i++) {
    r = i / (TITANSSL_PAGE_SIZE/4);
    c = i % (TITANSSL_PAGE_SIZE/4);
    printf("[IBEX INPUT] pag %d reg %d     0x%08x\r\n", r, c,
        ((uint32_t*) (titanssl_mbox->p_index[r].page))[c]);
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
#if CVA6_STATUS < 2
  titanssl_mbox->code = TITANSSL_CODE;
  titanssl_mbox->in_size = TITANSSL_INPUT_SIZE;

  titanssl_mbox->p_index = (titanssl_batch_t*) TITANSSL_BATCH_BASE;
  titanssl_mbox->num_round = (TITANSSL_INPUT_SIZE + TITANSSL_SCRATCHPAD_SIZE -1 ) / TITANSSL_SCRATCHPAD_SIZE;
  titanssl_mbox->cur_round = 0x00000000;
  titanssl_mbox->rtw = 0x00000000;

  uint8_t* p;
  uint32_t l = (TITANSSL_INPUT_SIZE + TITANSSL_PAGE_SIZE -1 ) / TITANSSL_PAGE_SIZE;
  for (size_t i=0; i<l; i++) {
    p = (uint8_t*)(TITANSSL_DATA_BASE + i*TITANSSL_PAGE_SIZE);
    titanssl_mbox->p_index[i].page = p;
    for (size_t j=0; j<TITANSSL_PAGE_SIZE; j++) p[j] = 0x00;
  }
#endif
}

// -------------------- SCRATCHPAD  --------------------

void utils_scratch_init(titanssl_batch_t* titanssl_scratch) {
  titanssl_scratch->page = (uint8_t*)TITANSSL_SCRATCHPAD_BASE;
  // for (size_t j=0; j<TITANSSL_SCRATCHPAD_SIZE; j++) titanssl_scratch->page[j] = 0x00;
}

// --------------------  DST  --------------------

void utils_dst_init(titanssl_batch_t* titanssl_dst, uint32_t size) {
  // titanssl_dst = malloc(TITANSSL_PAGE_SIZE) ?
  titanssl_dst->page = (uint8_t*)TITANSSL_DST_BASE;
  // for (size_t j=0; j<size; j++) titanssl_dst->page[j] = 0x00;
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

uint64_t utils_profile_timing(void) { return ibex_mcycle_read(); }

void utils_profile_analyses(uint64_t t_start, uint64_t t_end, const char *msg) {
  uint32_t cycles = t_end - t_start;
  uint32_t time_us = cycles / 100;
  printf("[IBEX PROFILE] %s took %u cycles or %u us @ 100 MHz.\t\n", msg, cycles, time_us);
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
  int mbox_id = 159;
  int volatile *plic_check;
  plic_check = (int *) 0xC8200004;
  while(*plic_check != mbox_id);   //check wether the intr is the correct one
}

