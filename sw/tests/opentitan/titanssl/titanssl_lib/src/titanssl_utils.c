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
    printf("mb %d:     0x%08x\r\n", i,
      ((uint32_t*) TITANSSL_MBOX_BASE)[i]); 
    uart_wait_tx_done();
  }
}

void utils_printf_input(titanssl_mbox_t* titanssl_mbox) {
  uint32_t r,c;
  for (size_t i=0; i<(titanssl_mbox->in_size)/4; i++) {
    r = i / (TITANSSL_PAGE_SIZE/4);
    c = i % (TITANSSL_PAGE_SIZE/4);
    printf("input page %d -> %d     0x%08x\r\n", r, c,
        ((uint32_t*) (titanssl_mbox->p_index[r].page))[c]);
      uart_wait_tx_done();
  }
}

void utils_printf_scratch(uint32_t offset, uint32_t size) {
  if(offset + size < TITANSSL_SCRATCHPAD_SIZE) {
    for (int i=0; i<size/4; i++) {
      printf("sratch %d:     0x%08x\r\n", i,
        ((uint32_t*) (TITANSSL_SCRATCHPAD_BASE + offset))[i]);
      uart_wait_tx_done();
    }
  } else {
    printf("error\r\n");
  }
}

// -------------------- MBOX --------------------

void utils_mbox_init(titanssl_mbox_t* titanssl_mbox) {
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
#if CVA6_DOWN
    for (size_t j=0; j<TITANSSL_PAGE_SIZE; j++) p[j] = 0x00;
#endif
  }
}

// -------------------- SCRATCHPAD  --------------------

void utils_scratch_init(titanssl_batch_t* titanssl_scratch) {
  titanssl_scratch->page = (uint8_t*)TITANSSL_SCRATCHPAD_BASE ;
#if !FAST_INIT
  for (size_t j=0; j<TITANSSL_SCRATCHPAD_SIZE; j++) titanssl_scratch->page[j] = 0x00;
#endif
}

// --------------------  DST  --------------------

void utils_dst_init(titanssl_batch_t* titanssl_dst, uint32_t size) {
  // titanssl_dst = malloc(TITANSSL_PAGE_SIZE) ?
  titanssl_dst->page = (uint8_t*)TITANSSL_DST_BASE;
#if !FAST_INIT
  for (size_t j=0; j<size; j++) titanssl_dst->page[j] = 0x00;
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

uint64_t utils_profile_timing(void) { return ibex_mcycle_read(); }

void utils_profile_analyses(uint64_t t_start, uint64_t t_end, const char *msg) {
  uint32_t cycles = t_end - t_start;
  uint32_t time_us = cycles / 100;
  printf("%s took %u cycles or %u us @ 100 MHz.\t\n", msg, cycles, time_us);
}

// -------------------- IRQ --------------------

void utils_irq_reset(){
  uint32_t* doorbell = (uint32_t *) TITANSSL_MBOX_DOORBELL;
 *doorbell = 0x00000000;
}

void utils_irq_trigger(){
  uint32_t* completion = (uint32_t *) TITANSSL_MBOX_COMPLETION;
 *completion = 0x00000001;
}