// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/dif/dif_kmac.h"
#include "sw/device/silicon_creator/rom/uart.h"
#include "sw/device/silicon_creator/rom/string_lib.h"
#include "sw/device/lib/dif/dif_uart.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

#define TARGET_SYNTHESIS

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

#define TITANSSL_TEST_KMAC_MODE 128
#define TITANSSL_TEST_SRC_SIZE  1500 // don't work over TITANSSL_PAGE_SIZE 
#define TITANSSL_TEST_DST_SIZE  ( TITANSSL_TEST_KMAC_MODE / 4 )
#define TITANSSL_PAGE_SIZE      4096
#define TITANSSL_MBOX_BASE      0x10404000
#define TITANSSL_BATCH_SRC_BASE 0x80700000
#define TITANSSL_BATCH_DST_BASE 0x80701000
#define TITANSSL_DATA_SRC_BASE  0x80720000
#define TITANSSL_DATA_DST_BASE  0x80740000

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

/**
 * KMAC test description.
 */
typedef struct kmac_test {
  dif_kmac_mode_kmac_t mode;
  dif_kmac_key_t key;

  // const char *message;
  // size_t message_len;

  // const char *customization_string;
  // size_t customization_string_len;

  // const uint32_t digest[100]; // [TITANSSL_TEST_KMAC_MODE / 32];
  // size_t digest_len;
  // bool digest_len_is_fixed;
} kmac_test_t;

// KMAC
#if TITANSSL_TEST_KMAC_MODE == 128
const kmac_test_t test =
    {
        .mode = kDifKmacModeKmacLen128,
        .key =
            (dif_kmac_key_t){
                .share0 = {0x43424140, 0x47464544, 0x4B4A4948, 0x4F4E4D4C,
                           0x53525150, 0x57565554, 0x5B5A5958, 0x5F5E5D5C},
                .share1 = {0},
                .length = kDifKmacKeyLen256,
            },
        // .message = "\x00\x01\x02\x03",
        // .message_len = 4,
        // .customization_string = "",
        // .customization_string_len = 0,
        // .digest = {0x0D0B78E5, 0xD3F7A63E, 0x70C529A4, 0x003AA46A, 0xD4D7DBFA,
            //        0x9E832896, 0x3F248731, 0x4EE16E45},
        // .digest_len = 8,
        // .digest_len_is_fixed = true,
    };
#elif TITANSSL_TEST_KMAC_MODE == 256
const kmac_test_t test =
    {
        .mode = kDifKmacModeKmacLen256,
        .key =
            (dif_kmac_key_t){
                .share0 = {0x43424140, 0x47464544, 0x4B4A4948, 0x4F4E4D4C,
                           0x53525150, 0x57565554, 0x5B5A5958, 0x5F5E5D5C},
                .share1 = {0},
                .length = kDifKmacKeyLen256,
            },
        /* .message =
            "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
            "\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f"
            "\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f"
            "\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x3e\x3f"
            "\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f"
            "\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5a\x5b\x5c\x5d\x5e\x5f"
            "\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f"
            "\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7a\x7b\x7c\x7d\x7e\x7f"
            "\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f"
            "\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f"
            "\xa0\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf"
            "\xb0\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf"
            "\xc0\xc1\xc2\xc3\xc4\xc5\xc6\xc7", */
        // .message_len = 200,
        // .customization_string = "My Tagged Application",
        // .customization_string_len = 21,
        /* .digest = {0xF71886B5, 0xD5E1921F, 0x558C1B6C, 0x18CDD7DD, 0xCAB4978B,
                   0x1E83994D, 0x839A69B2, 0xD9E4A27D, 0xFDACFB70, 0xAE3300E5,
                   0xA2F185A5, 0xC3108570, 0x0888072D, 0x2818BD01, 0x6847FE98,
                   0x6589FC76}, */
        // .digest_len = 16,
        // .digest_len_is_fixed = true,
    };
#else
#error "Supported TITANSSL_TEST_KMAC_MODE are 128, 256"
#endif // TITANSSL_TEST_KMAC_MODE

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

    // Intialize KMAC hardware.
    dif_kmac_t kmac;
    dif_kmac_operation_state_t kmac_operation_state;
    dif_result_t res;

    // Configure KMAC hardware using software entropy.
    dif_kmac_config_t config = (dif_kmac_config_t){
        .entropy_mode = kDifKmacEntropyModeSoftware, // 3 mode to check
        .entropy_seed = {0xaa25b4bf, 0x48ce8fff, 0x5a78282a, 0x48465647,
                        0x70410fef},
        .entropy_fast_process = kDifToggleEnabled,
    };

    res = dif_kmac_init(mmio_region_from_addr(TOP_EARLGREY_KMAC_BASE_ADDR), &kmac);
    res = dif_kmac_configure(&kmac, config);

    res = dif_kmac_mode_kmac_start(&kmac, &kmac_operation_state,
        test.mode, ( TITANSSL_TEST_DST_SIZE / 4 ), &test.key, NULL);
    res = dif_kmac_absorb(&kmac, &kmac_operation_state, src[0].data,
        TITANSSL_TEST_SRC_SIZE, NULL);
    // res = dif_kmac_absorb(&kmac, &kmac_operation_state,  "\x00\x01\x02\x03",
    //    4, NULL);

    res = dif_kmac_squeeze(&kmac, &kmac_operation_state, (uint32_t*) dst[0].data,
        ( TITANSSL_TEST_DST_SIZE / 4 ), NULL); 
    res = dif_kmac_end(&kmac, &kmac_operation_state);

    for (int j = 0; j < TITANSSL_TEST_DST_SIZE; j++) // ( TITANSSL_TEST_DST_SIZE / 4 ); j++)
        printf("at %d got=0x%x \t\n", j, dst[0].data[j]);

  return true;
}
