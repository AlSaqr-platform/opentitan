// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/tests/opentitan/titanssl/titanssl_lib/headers/titanssl_utils.h"

void aes_run(titanssl_mbox_t*);
void _aes_key_init();
void _aes_check(titanssl_batch_t*);
void _aes_run(titanssl_mbox_t*, titanssl_batch_t*, titanssl_batch_t*);
void _aes_run_ibex(titanssl_mbox_t*, titanssl_batch_t*, titanssl_batch_t*);


static const uint32_t AesKey[8] = {
    0xec4e6c89, 0x082efa98, 0x299f31d0, 0xa4093822,
    0x03707344, 0x13198a2e, 0x85a308d3, 0x243f6a88
};

static const unsigned char AesIv[TITANSSL_IV_SIZE] = {
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f
};

#if CFG_CVA6_STATUS < 2
    #if TITANSSL_INPUT_SIZE == 65536
        static const uint32_t ExpectedAesDigest[8] = {
            0x00000000, 0x00000000, 0x00000000, 0x00000000,
            0x00000000, 0x00000000, 0x00000000, 0x00000000
        };
    #elif TITANSSL_INPUT_SIZE == 2354
        static const uint32_t ExpectedAesDigest[8] = {
            0x00000000, 0x00000000, 0x00000000, 0x00000000,
            0x00000000, 0x00000000, 0x00000000, 0x00000000
        };
    #elif TITANSSL_INPUT_SIZE == 1500
        static const uint32_t ExpectedAesDigest[8] = {
            0x00000000, 0x00000000, 0x00000000, 0x00000000,
            0x00000000, 0x00000000, 0x00000000, 0x00000000
        };
    #elif TITANSSL_INPUT_SIZE == 64
        static const uint32_t ExpectedAesDigest[8] = {
            0x00000000, 0x00000000, 0x00000000, 0x00000000,
            0x00000000, 0x00000000, 0x00000000, 0x00000000
        };
    #else
        static const uint32_t ExpectedAesDigest[8] = {
            0x00000000, 0x00000000, 0x00000000, 0x00000000,
            0x00000000, 0x00000000, 0x00000000, 0x00000000
        };
    #endif // TITANSSL_INPUT_SIZE
#endif // CFG_CVA6_STATUS