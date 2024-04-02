// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/tests/opentitan/titanssl/titanssl_lib/headers/titanssl_utils.h"

void hmac_run(titanssl_mbox_t*);
void _hmac_key_init();
void _hmac_check(titanssl_batch_t*);
void _hmac_run(titanssl_mbox_t*, titanssl_batch_t*, titanssl_batch_t*);

static const uint32_t HmacKey[8] = {
    0xec4e6c89, 0x082efa98, 0x299f31d0, 0xa4093822,
    0x03707344, 0x13198a2e, 0x85a308d3, 0x243f6a88,
};

#if CFG_CVA6_STATUS < 2 && TITANSSL_CODE == SHA256_ENCRYPT
    #if TITANSSL_INPUT_SIZE == 65536
        static const uint32_t ExpectedHmacDigest[8] = {
            0x00000000, 0x00000000, 0x00000000, 0x00000000,
            0x00000000, 0x00000000, 0x00000000, 0x00000000
        };
    #elif TITANSSL_INPUT_SIZE == 2354
        static const uint32_t ExpectedHmacDigest[8] = {
            0x00000000, 0x00000000, 0x00000000, 0x00000000,
            0x00000000, 0x00000000, 0x00000000, 0x00000000
        };
    #elif TITANSSL_INPUT_SIZE == 1500
        static const uint32_t ExpectedHmacDigest[8] = {
            0x00000000, 0x00000000, 0x00000000, 0x00000000,
            0x00000000, 0x00000000, 0x00000000, 0x00000000
        };
    #elif TITANSSL_INPUT_SIZE == 64
        static const uint32_t ExpectedHmacDigest[8] = {
            0xf5a5fd42, 0xd16a2030, 0x2798ef6e, 0xd309979b,
            0x43003d23, 0x20d9f0e8, 0xea9831a9, 0x2759fb4b
        };
    #else
        static const uint32_t ExpectedHmacDigest[8] = {
            0x00000000, 0x00000000, 0x00000000, 0x00000000,
            0x00000000, 0x00000000, 0x00000000, 0x00000000
        };
    #endif // TITANSSL_INPUT_SIZE
#elif CFG_CVA6_STATUS < 2 && TITANSSL_CODE == HMAC_ENCRYPT 
    #if TITANSSL_INPUT_SIZE == 65536
        static const uint32_t ExpectedHmacDigest[8] = {
            0x00000000, 0x00000000, 0x00000000, 0x00000000,
            0x00000000, 0x00000000, 0x00000000, 0x00000000
        };
    #elif TITANSSL_INPUT_SIZE == 2354
        static const uint32_t ExpectedHmacDigest[8] = {
            0x00000000, 0x00000000, 0x00000000, 0x00000000,
            0x00000000, 0x00000000, 0x00000000, 0x00000000
        };
    #elif TITANSSL_INPUT_SIZE == 1500
        static const uint32_t ExpectedHmacDigest[8] = {
            0x00000000, 0x00000000, 0x00000000, 0x00000000,
            0x00000000, 0x00000000, 0x00000000, 0x00000000
        };
    #elif TITANSSL_INPUT_SIZE == 64
        static const uint32_t ExpectedHmacDigest[8] = {
            0x00000000, 0x00000000, 0x00000000, 0x00000000,
            0x00000000, 0x00000000, 0x00000000, 0x00000000
        };
    #else
        static const uint32_t ExpectedHmacDigest[8] = {
            0x00000000, 0x00000000, 0x00000000, 0x00000000,
            0x00000000, 0x00000000, 0x00000000, 0x00000000
        };
    #endif // TITANSSL_INPUT_SIZE
#endif // CFG_CVA6_STATUS