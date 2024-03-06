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

void external_irq_handler(void) {

  if(DEB) printf("[IBEX handler]\r\n");

#if CVA6_STATUS == 1
  utils_mbox_init(titanssl_mbox); // first reg mbox overwrite, loosing pointers references 
#endif

#if CVA6_STATUS != 0
  utils_irq_check();
  utils_irq_reset_door();
#endif

  if(titanssl_mbox->rtw == 1)
    flag = 1;
  else {
    if (titanssl_mbox->code == SHA256_ENCRYPT || titanssl_mbox->code == HMAC_ENCRYPT) {
      hmac_run(titanssl_mbox, &titanssl_scratch);
    } else if (titanssl_mbox->code == SHA3_ENCRYPT || titanssl_mbox->code == KMAC_ENCRYPT) { 
      if(DEB) printf("[IBEX handler] code 2\r\n");
    } else if (titanssl_mbox->code == AES_ENCRYPT) {
      aes_run(titanssl_mbox, &titanssl_scratch);
    } else if (titanssl_mbox->code == RSA_ENCRYPT) {
      if(DEB) printf("[IBEX handler] code 4\r\n");
    } else{
      if(DEB) printf("[IBEX handler] invalid code\r\n");
    }
    utils_irq_reset_comp(); // to move
    utils_irq_trig_comp(); // to move 
  }

  if(DEB) printf("[IBEX handler] ending\r\n");

  return;
}

int main(int argc, char **argv) {

#if CVA6_STATUS == 0
  utils_printf_init();
  if(DEB) printf("[IBEX main] printf init\r\n");
  utils_mbox_init(titanssl_mbox);
  if(DEB) printf("[IBEX main] mbox init\r\n");
  utils_scratch_init(&titanssl_scratch);
  if(DEB) printf("[IBEX main] scratch init\r\n");
  external_irq_handler();
#elif CVA6_STATUS == 1
  utils_mbox_init(titanssl_mbox);
  utils_scratch_init(&titanssl_scratch);
  utils_irq_enable();
  while(1)
    asm volatile ("wfi");
#elif CVA6_STATUS == 2
  utils_irq_enable();
  while(1)
    asm volatile ("wfi");
#endif
  return true;
}