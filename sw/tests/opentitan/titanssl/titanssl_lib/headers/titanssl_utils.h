// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef TITANSSL_UTILS_H
#define TITANSSL_UTILS_H

#define CFG_FPGA_EMULATION 
#define CFG_CVA6_STATUS 1   // 0 Down; 1 Only irq; 2 Full pipeline
#define CFG_DEBUG 1         // Enable debug printf -> works only with CVA6_STATUS set to 0
#define CFG_PROF 0          // profiling
#define CFG_L3_TEST 0       // test in L3 (DRAM)

#define TITANSSL_MBOX_BASE        0x10404000
#define TITANSSL_PAGE_SIZE        4096
#define TITANSSL_MBOX_DOORBELL    0x10404020
#define TITANSSL_MBOX_COMPLETION  0x10404024

#define TITANSSL_SCRATCHPAD_BASE  0x1C000000 
#define TITANSSL_SCRATCHPAD_SIZE  32768      // 0x00008000  -> 32KB

// SIZES AND MAYBE MORE SHOULD BE MOVED FROM HERE
#define TITANSSL_KEY_BASE    0xe0002000
#define TITANSSL_KEY_SIZE    32 // 
#define TITANSSL_IV_BASE     0xe0002100
#define TITANSSL_IV_SIZE     16 // 

#define TITANSSL_MBOX_BASE_L1    0xe0002200
#define TITANSSL_DST_BASE_L1     0xe0003000
#define TITANSSL_SRC_BASE_L1     0xe0006000
#define TITANSSL_OP_L1           0xe0002500

typedef enum {
    SHA256_ENCRYPT      = 1,
    HMAC_ENCRYPT        = 2,
    SHA3_ENCRYPT        = 3,
    KMAC_ENCRYPT        = 4,
    AES_ENCRYPT         = 5,
    RSA_ENCRYPT         = 6,
} Operation;

#if CVA6_STATUS < 2
#define TITANSSL_CODE           AES_ENCRYPT
#define TITANSSL_INPUT_SIZE     32768+64 // (4096*(4096/4))+4096 
#define TITANSSL_BATCH_BASE     0x80700000
#define TITANSSL_DATA_BASE      0x80800000

#if TITANSSL_CODE == SHA256_ENCRYPT || TITANSSL_CODE == HMAC_ENCRYPT
    #define TITANSSL_OUTPUT_SIZE 32
#elif TITANSSL_CODE == SHA3_ENCRYPT || TITANSSL_CODE == KMAC_ENCRYPT
    #define TITANSSL_OUTPUT_SIZE 0
#elif TITANSSL_CODE == AES_ENCRYPT
    #define TITANSSL_OUTPUT_SIZE TITANSSL_INPUT_SIZE
#elif TITANSSL_CODE == RSA_ENCRYPT
    #define TITANSSL_OUTPUT_SIZE 0
#else
    #error "Unsupported code"
#endif
#endif

#define TITANSSL_MBOX_ID 159

#if CFG_CVA6_STATUS <= 1
#define DEB CFG_DEBUG
#else
#define DEB 0
#endif
#define PRF CFG_PROF

typedef struct {
    uint8_t *page;
} titanssl_batch_t;

typedef struct {
    uint32_t code;
    uint32_t in_size;
    titanssl_batch_t* p_index[5];
    uint32_t bitfield;
} titanssl_mbox_t;

void utils_printf_init(void);
void utils_printf_mbox(void);
void utils_printf_scratch(uint32_t, uint32_t);

void utils_mbox_init(titanssl_mbox_t*);
void utils_mbox_read(titanssl_mbox_t*, titanssl_mbox_t*);
// void utils_mbox_write();

void utils_scratch_write(titanssl_batch_t*, uint32_t, uint32_t);

void utils_ibexl1_init(uint32_t, uint8_t*);

void utils_dram_readp(titanssl_mbox_t*, titanssl_batch_t*, uint32_t);

void utils_entropy_init(void);

uint64_t utils_profile_timing(void);
void utils_profile_start(void);
void _utils_profile_analyses(uint64_t, uint64_t, char *);
void utils_profile_analyses(char *);

void utils_irq_reset_door(void);
void utils_irq_trig_door(void);
void utils_irq_reset_comp(void);
void utils_irq_trig_comp(void);
void utils_irq_enable(void);
void utils_irq_check(void);
void utils_irq_end(void);

#endif
