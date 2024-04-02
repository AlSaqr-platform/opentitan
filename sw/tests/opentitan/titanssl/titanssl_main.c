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

#include "sw/tests/opentitan/common/utils.h"
#include <stdlib.h>

static titanssl_mbox_t* const titanssl_mbox = (titanssl_mbox_t*) TITANSSL_MBOX_BASE;

void external_irq_handler(void) {

  if(DEB) printf("[IBEX handler] starting \r\n");

  if(PRF) utils_profile_start();

#if CFG_CVA6_STATUS != 0
  utils_irq_check();
  utils_irq_reset_door();
#endif

  if(PRF) utils_profile_analyses("irq init and reset doorbell");

  static titanssl_mbox_t t_mbox;

  if(PRF) utils_profile_analyses("variables init");

  utils_mbox_read(&t_mbox, titanssl_mbox);
  
  if(PRF) utils_profile_analyses("read mbox");

  utils_printf_mbox(); // to remove

  if (t_mbox.code == SHA256_ENCRYPT || t_mbox.code == HMAC_ENCRYPT) {
    hmac_run(&t_mbox);
  } else if (t_mbox.code == SHA3_ENCRYPT || t_mbox.code == KMAC_ENCRYPT) { 
    if(DEB) printf("[IBEX handler] code 2\r\n");
  } else if (t_mbox.code == AES_ENCRYPT) {
    aes_run(&t_mbox);
  } else if (t_mbox.code == RSA_ENCRYPT) {
    if(DEB) printf("[IBEX handler] code 4\r\n");
  } else{
    if(DEB) printf("[IBEX handler] invalid code\r\n");
  }

  if(PRF) utils_profile_analyses("crypto");

#if CFG_CVA6_STATUS != 0    
    utils_irq_end();
    utils_irq_trig_comp();
#endif

  if(PRF) utils_profile_analyses("completing irq");

  if(DEB) printf("[IBEX handler] ending\r\n");

  return;
}

int main(int argc, char **argv) {

  if(DEB){
    utils_printf_init();
    printf("[IBEX main] printf init\r\n");
  }

  utils_ibexl1_init(TITANSSL_PAGE_SIZE, (uint8_t*) TITANSSL_SRC_BASE_L1); 
  utils_ibexl1_init(TITANSSL_PAGE_SIZE, (uint8_t*) TITANSSL_DST_BASE_L1); 
  utils_ibexl1_init(TITANSSL_PAGE_SIZE, (uint8_t*) TITANSSL_OP_L1); 
  if(DEB) printf("[IBEX main] mem init\r\n");

#if CFG_CVA6_STATUS == 0
  utils_mbox_init(titanssl_mbox);
  if(DEB) printf("[IBEX main] mbox init\r\n");
  external_irq_handler();
#elif CFG_CVA6_STATUS == 1
  utils_mbox_init(titanssl_mbox);
  utils_irq_enable();
  while(1)
    asm volatile ("wfi");
#elif CFG_CVA6_STATUS == 2
  utils_irq_enable();
  while(1)
    asm volatile ("wfi");
#endif
  return true;
}
