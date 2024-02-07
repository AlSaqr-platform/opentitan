// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "hw/ip/aes/model/aes_modes.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/dif/dif_aes.h"  
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/aes_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

#include "sw/device/silicon_creator/rom/uart.h"
#include "sw/device/silicon_creator/rom/string_lib.h"
#include "sw/device/lib/dif/dif_uart.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

#define TARGET_SYNTHESIS

#define TITANSSL_TEST_SRC_SIZE  1500 
#define TITANSSL_TEST_DST_SIZE  TITANSSL_TEST_SRC_SIZE
#define TITANSSL_PAGE_SIZE      4096
#define TITANSSL_MBOX_BASE      0x10404000
#define TITANSSL_BATCH_SRC_BASE 0x80700000
#define TITANSSL_BATCH_DST_BASE 0x80701000
#define TITANSSL_DATA_SRC_BASE  0x80720000
#define TITANSSL_DATA_DST_BASE  0x80740000

bool initialize_entropy(void) {
 
  int volatile * edn_enable, * csrng_enable, * entropy_src_enable;

  entropy_src_enable = (int *) 0xc1160024;
  *entropy_src_enable = 0x00909099;
 
  entropy_src_enable = (int *) 0xc1160020;
  *entropy_src_enable = 0x6;
 
  csrng_enable = (int *) 0xc1150014;
  *csrng_enable = 0x666;
 
  edn_enable = (int *) 0xc1170014;
  *edn_enable = 0x9966;
 
  return true;
}

typedef struct
{
    uint8_t  *data;
    uint32_t n;
} titanssl_batch_t;

typedef struct __attribute__((packed))
{
    titanssl_batch_t *src;
    titanssl_batch_t *dst;
    uint32_t         n_src;
    uint32_t         n_dst;
} titanssl_mbox_t;

static titanssl_mbox_t* const titanssl_mbox = (titanssl_mbox_t*)TITANSSL_MBOX_BASE;

void initialize_memory()
{
    uint32_t n = 0;
    uint8_t *p = 0;

    // Initialize mailbox content
    titanssl_mbox->src = (titanssl_batch_t*)TITANSSL_BATCH_SRC_BASE;
    titanssl_mbox->dst = (titanssl_batch_t*)TITANSSL_BATCH_DST_BASE;
    titanssl_mbox->n_src = 1 + (TITANSSL_TEST_SRC_SIZE-1) / TITANSSL_PAGE_SIZE;
    titanssl_mbox->n_dst = 1 + (TITANSSL_TEST_DST_SIZE-1) / TITANSSL_PAGE_SIZE;

    // Initialize batch content
    for (size_t i=0; i<titanssl_mbox->n_src; i++)
    {
        n = TITANSSL_TEST_SRC_SIZE - i*TITANSSL_PAGE_SIZE;
        p = (uint8_t*)(TITANSSL_DATA_SRC_BASE + i*TITANSSL_PAGE_SIZE);

        titanssl_mbox->src[i].data = p;
        if (n > TITANSSL_PAGE_SIZE)
        {
            for (size_t j=0; j<TITANSSL_PAGE_SIZE; j++) p[j] = 0x0;
            titanssl_mbox->src[i].n = TITANSSL_PAGE_SIZE;
        } else {
            for (size_t j=0; j<n; j++) p[j] = 0x0;
            titanssl_mbox->src[i].n = n;
        }
    }
    for (size_t i=0; i<titanssl_mbox->n_dst; i++)
    {
        n = TITANSSL_TEST_DST_SIZE - i*TITANSSL_PAGE_SIZE;
        p = (uint8_t*)(TITANSSL_DATA_DST_BASE + i*TITANSSL_PAGE_SIZE);

        titanssl_mbox->dst[i].data = p;
        if (n > TITANSSL_PAGE_SIZE)
        {
            for (size_t j=0; j<TITANSSL_PAGE_SIZE; j++) p[j] = 0x0;
            titanssl_mbox->dst[i].n = TITANSSL_PAGE_SIZE;
        } else {
            for (size_t j=0; j<n; j++) p[j] = 0x0;
            titanssl_mbox->dst[i].n = n;
        }
    }
}

enum {
  kTestTimeout = (1000 * 1000),
};

static const uint8_t kKeyShare1[] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
};

static const unsigned char kAesModesKey256Custom[32] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
};

static const unsigned char kAesModesIvCbcCustom[16] = {
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f
};

static const unsigned char kAesModesCypherTextCustom[64] =  { 
  0xb6, 0x5d, 0x30, 0x03, 0x0c, 0x88, 0xb4, 0x4c, 0x97, 0x5a, 0x34,
  0x3f, 0x93, 0xfb, 0x3c, 0x09, 0x45, 0x05, 0xc2, 0xa3, 0x05, 0xed,
  0xcf, 0x17, 0x61, 0xe7, 0x98, 0x38, 0x50, 0x65, 0x0f, 0xfc, 0x97,
  0x33, 0x21, 0x3d, 0xd5, 0x83, 0x1d, 0x19, 0xfb, 0x7c, 0x7b, 0x70,
  0xb1, 0x7c, 0xf9, 0x63, 0xb0, 0xe4, 0xb2, 0x7a, 0x7f, 0x1b, 0x80,
  0x1f, 0x84, 0x57, 0xcd, 0x7b, 0x03, 0xe8, 0x8b, 0xe3
  };

OTTF_DEFINE_TEST_CONFIG();

int main(int argc, char **argv) {
  
  #ifdef TARGET_SYNTHESIS
  #define baud_rate 115200
  #define test_freq 50000000
  #else
  #define baud_rate 115200
  #define test_freq 100000000
  #endif
  uart_set_cfg(0,(test_freq/baud_rate)>>4);

  initialize_memory();

  titanssl_batch_t* const src = titanssl_mbox->src;
  titanssl_batch_t* const dst = titanssl_mbox->dst;
  const uint32_t n_src = titanssl_mbox->n_src;
  const uint32_t n_dst = titanssl_mbox->n_dst;

  dif_aes_t aes;
  dif_result_t res;
  dif_aes_transaction_t transaction = {
      .operation = kDifAesOperationEncrypt,
      .mode = kDifAesModeCbc,
      .key_len = kDifAesKey256,
      .key_provider = kDifAesKeySoftwareProvided,
      .mask_reseeding = kDifAesReseedPer64Block,  
      .manual_operation = kDifAesManualOperationAuto,
      .reseed_on_key_change = false,
      .ctrl_aux_lock = false,
  };

  uint8_t key_share0[sizeof(kAesModesKey256Custom)];
  for (int i = 0; i < sizeof(kAesModesKey256Custom); ++i) {
    key_share0[i] = kAesModesKey256Custom[i] ^ kKeyShare1[i];
  }

  dif_aes_key_share_t key;
  memcpy(key.share0, key_share0, sizeof(key.share0));
  memcpy(key.share1, kKeyShare1, sizeof(key.share1));

  dif_aes_iv_t iv;
  memcpy(iv.iv, kAesModesIvCbcCustom, sizeof(iv.iv));

  initialize_entropy(); // to try -> entropy_testutils_auto_mode_init();

  uint8_t *kDataSrc;
  uint8_t *kDataDst;
  uint32_t kDataSize;
  uint8_t *dpSrc;
  uint8_t *dpDst;
  uint32_t sent_bytes = 16;

  dif_aes_data_t aes_data;

  // Initialise AES.
  res = dif_aes_init(mmio_region_from_addr(TOP_EARLGREY_AES_BASE_ADDR), &aes);
  res = dif_aes_reset(&aes);

  res = dif_aes_start(&aes, &transaction, &key, &iv);

  for (size_t i=0; i<n_src; i++) {

    kDataSrc = src[i].data;
    kDataSize = src[i].n;
    dpSrc = src[i].data;

    if (i==0) {
      memcpy(aes_data.data, dpSrc, sizeof(aes_data.data));
      res = dif_aes_load_data(&aes, aes_data); // ( dif_aes_data_t ) {*((uint32_t*)dpSrc)});
      AES_TESTUTILS_WAIT_FOR_STATUS(&aes, kDifAesStatusInputReady, true, kTestTimeout);
      dpSrc += sent_bytes;
      kDataDst = dst[i].data;
      dpDst = dst[i].data;
    }
    
    while (dpSrc - kDataSrc < kDataSize) {
      
      memcpy(aes_data.data, dpSrc, sizeof(aes_data.data));
      res = dif_aes_load_data(&aes, aes_data); //( dif_aes_data_t ) {*((uint32_t*)dpSrc)});
      AES_TESTUTILS_WAIT_FOR_STATUS(&aes, kDifAesStatusOutputValid, true, kTestTimeout);
      res = dif_aes_read_output(&aes, &aes_data); // &(( dif_aes_data_t ) {*((uint32_t*)dpDst)}));
      memcpy(dpDst, aes_data.data, sizeof(aes_data.data));

      dpDst += sent_bytes;

      if(dpSrc == kDataSrc) { 
        dpDst = dst[i].data;
        kDataDst = dst[i].data;
      }

      dpSrc += sent_bytes;

    }

  }

  AES_TESTUTILS_WAIT_FOR_STATUS(&aes, kDifAesStatusOutputValid, true, kTestTimeout);
  res = dif_aes_read_output(&aes, &aes_data); // &(( dif_aes_data_t ) {*((uint32_t*)dpDst)}));
  memcpy(dpDst, aes_data.data, sizeof(aes_data.data));

  res = dif_aes_end(&aes);

  for (int p = 0; p<TITANSSL_TEST_SRC_SIZE; p++)
    if (TITANSSL_TEST_SRC_SIZE == 64)
      printf("%d: 0x%x vs 0x%x \t\n", p, dst[0].data[p], kAesModesCypherTextCustom[p]);
    else 
      printf("%d: 0x%x \t\n", p, dst[0].data[p]);

  return true;

}
