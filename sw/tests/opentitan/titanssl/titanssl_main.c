// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/silicon_creator/rom/uart.h"
#include "sw/device/silicon_creator/rom/string_lib.h"

#include "sw/tests/opentitan/titanssl/titanssl_lib/headers/titanssl_utils.h"
#include "sw/tests/opentitan/titanssl/titanssl_lib/headers/titanssl_hmac.h"
#include "sw/tests/opentitan/titanssl/titanssl_lib/headers/titanssl_aes.h"

static titanssl_mbox_t* const titanssl_mbox = (titanssl_mbox_t*) TITANSSL_MBOX_BASE;
static titanssl_batch_t titanssl_scratch;

void _external_irq_handler(void) { // __attribute__((interrupt)) { // __attribute__((weak)) {}

/*
  static titanssl_mbox_t* const titanssl_mbox = (titanssl_mbox_t*) TITANSSL_MBOX_BASE;
  static titanssl_batch_t titanssl_scratch;
  static titanssl_batch_t titanssl_out;
  main();
*/

  utils_irq_reset();
    
  if (titanssl_mbox->code == SHA256_ENCRYPT || titanssl_mbox->code == HMAC_ENCRYPT) {
    hmac_run(titanssl_mbox, &titanssl_scratch);
  } else if (titanssl_mbox->code == SHA3_ENCRYPT || titanssl_mbox->code == KMAC_ENCRYPT) { 
    printf("code 2\r\n");
  } else if (titanssl_mbox->code == AES_ENCRYPT) {
    aes_run(titanssl_mbox, &titanssl_scratch);
  } else if (titanssl_mbox->code == RSA_ENCRYPT) {
    printf("code 4\r\n");
  } else{
    printf("invalid code\r\n");
  }

  utils_irq_trigger();
  printf("complete\r\n");

  return;
}

int main(int argc, char **argv) {

  utils_printf_init();
  printf("printf init\r\n");

  #if CVA6_DOWN
  utils_mbox_init(titanssl_mbox);
  printf("mbox init\r\n");

  utils_scratch_init(&titanssl_scratch);
  printf("scratch init\r\n");

  _external_irq_handler(); // __attribute__((weak)) -> common/utils.c
  #endif
  
  return true;
}