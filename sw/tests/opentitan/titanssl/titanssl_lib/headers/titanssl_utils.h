// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef TITANSSL_UTILS_H
#define TITANSSL_UTILS_H

#define FPGA_EMULATION

#define TITANSSL_MBOX_BASE        0x10404000
#define TITANSSL_PAGE_SIZE        4096
#define TITANSSL_MBOX_DOORBELL    0x10404020
#define TITANSSL_MBOX_COMPLETION  0x10404024

#define TITANSSL_SCRATCHPAD_BASE  0x1C000000
#define TITANSSL_SCRATCHPAD_SIZE  32768         // 0x00008000  -> 32KB

#define TITANSSL_DST_BASE    0x80900000 
#define TITANSSL_KEY_BASE    0xe0006000
#define TITANSSL_IV_BASE     0xe0006100
#define TITANSSL_IV_SIZE     16

#define FAST_INIT 1
#define CVA6_DOWN 1

typedef enum {
    SHA256_ENCRYPT      = 1,
    HMAC_ENCRYPT        = 2,
    SHA3_ENCRYPT        = 3,
    KMAC_ENCRYPT        = 4,
    AES_ENCRYPT         = 5,
    RSA_ENCRYPT         = 6,
} Operation;

#if CVA6_DOWN
#define TITANSSL_CODE AES_ENCRYPT
#define TITANSSL_INPUT_SIZE 64   // Payload size  65536, 2354, 1500, 64
#define TITANSSL_BATCH_BASE 0x80700000
#define TITANSSL_DATA_BASE  0x80800000

 #if TITANSSL_CODE == SHA256_ENCRYPT || TITANSSL_CODE == HMAC_ENCRYPT
    #define TITANSSL_OUTPUT_SIZE 32
    #define TITANSSL_KEY_SIZE    32
#elif TITANSSL_CODE == SHA3_ENCRYPT || TITANSSL_CODE == KMAC_ENCRYPT
    #define TITANSSL_OUTPUT_SIZE 0
#elif TITANSSL_CODE == AES_ENCRYPT
    #define TITANSSL_OUTPUT_SIZE TITANSSL_INPUT_SIZE
    #define TITANSSL_KEY_SIZE    32
#elif TITANSSL_CODE == RSA_ENCRYPT
    #define TITANSSL_OUTPUT_SIZE 0
#else
    #error "Unsupported code"
#endif
#endif

typedef struct {
    uint8_t *page;
} titanssl_batch_t;

typedef struct {
    uint32_t code;
    uint64_t in_size;
    titanssl_batch_t* p_index;
    uint32_t num_round;
    uint32_t cur_round;
    uint32_t rtw;
} titanssl_mbox_t;

void utils_printf_init(void);
void utils_printf_mbox(void);
void utils_printf_input(titanssl_mbox_t*);
void utils_printf_scratch(uint32_t, uint32_t);

void utils_mbox_init(titanssl_mbox_t*);

void utils_scratch_init(titanssl_batch_t*);

void utils_dst_init(titanssl_batch_t*, uint32_t);

void utils_entropy_init(void);

uint64_t utils_profile_timing(void);
void utils_profile_analyses(uint64_t, uint64_t, const char *);

void utils_irq_reset(void);
void utils_irq_trigger(void);

#endif
