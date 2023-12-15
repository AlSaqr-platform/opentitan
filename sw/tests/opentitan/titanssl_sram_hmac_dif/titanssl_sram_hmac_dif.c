// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/base/bitfield.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/dif/dif_hmac.h"
#include "sw/device/lib/dif/dif_aes.h"
#include "sw/device/lib/dif/dif_kmac.h"
#include "sw/device/silicon_creator/rom/uart.h"
#include "sw/device/silicon_creator/rom/string_lib.h"

#include "kmac_regs.h"  // Generated
#include "hmac_regs.h"  // Generated.
#include "aes_regs.h"  // Generated.


#define TARGET_SYNTHESIS


typedef struct
{
    uint8_t *data;
    size_t n;
} titanssl_buffer_t;


static titanssl_buffer_t titanssl_data_src;
static titanssl_buffer_t titanssl_data_dst;
static titanssl_buffer_t titanssl_data_key;
static titanssl_buffer_t titanssl_data_iv;

/* ============================================================================
 * Benchmark setup
 * ========================================================================= */

// Configure debug mode.
#define TITANSSL_BENCHMARK_DEBUG 1

// Configure memory.
#define TITANSSL_BENCHMARK_L3 1
#define TITANSSL_BENCHMARK_L1 0

// Configure payload size.
#define TITANSSL_BENCHMARK_PAYLOAD_2354  1
#define TITANSSL_BENCHMARK_PAYLOAD_65536 0

// Configure cryptographic operation.
#define TITANSSL_BENCHMARK_SHA256 0
#define TITANSSL_BENCHMARK_HMAC   0
#define TITANSSL_BENCHMARK_AES    0
#define TITANSSL_BENCHMARK_SHA3   1

/* ============================================================================
 * Benchmark automatic configuration
 * ========================================================================= */

#if TITANSSL_BENCHMARK_L3
#define TITANSSL_DATA_SRC 0x80720000
#define TITANSSL_DATA_DST 0x80740000
#define TITANSSL_DATA_KEY 0xe0006000
#define TITANSSL_DATA_IV  0xe0006100
#elif TITANSSL_BENCHMARK_L1
#define TITANSSL_DATA_SRC 0xe0002000
#define TITANSSL_DATA_DST 0xe0004000
#define TITANSSL_DATA_KEY 0xe0006000
#define TITANSSL_DATA_IV  0xe0006100
#else
#error "Wrong benchmark memory configuration"
#endif

#if TITANSSL_BENCHMARK_PAYLOAD_2354
#define TITANSSL_PAYLOAD_SIZE 2354
#elif TITANSSL_BENCHMARK_PAYLOAD_65536
#define TITANSSL_PAYLOAD_SIZE 65536
#else
#error "Wrong benchmark payload configuration"
#endif

#if TITANSSL_BENCHMARK_SHA256

#define TITANSSL_OUTPUT_SIZE 32
#define TITANSSL_KEY_SIZE 0
#define TITANSSL_IV_SIZE 0
#define titanssl_benchmark titanssl_benchmark_sha256

#elif TITANSSL_BENCHMARK_HMAC

#define TITANSSL_OUTPUT_SIZE 32
#define TITANSSL_KEY_SIZE 32
#define TITANSSL_IV_SIZE 0
#define titanssl_benchmark titanssl_benchmark_hmac

#elif TITANSSL_BENCHMARK_AES

#define TITANSSL_OUTPUT_SIZE ((TITANSSL_PAYLOAD_SIZE+0xF) & ~0xF)
#define TITANSSL_KEY_SIZE 32
#define TITANSSL_IV_SIZE 16
#define titanssl_benchmark titanssl_benchmark_aes


#elif TITANSSL_BENCHMARK_SHA3

#define TITANSSL_OUTPUT_SIZE 32
#define TITANSSL_KEY_SIZE 0
#define TITANSSL_IV_SIZE 0
#define titanssl_benchmark titanssl_benchmark_sha3

#else
#error "Wrong benchmark operation configuration"
#endif

/**
 * SHA-3 tests.
 */
const sha3_test_t sha3_tests = {
        .mode = kDifKmacModeSha3Len512,
        .message =
            "\x66\x4e\xf2\xe3\xa7\x05\x9d\xaf\x1c\x58\xca\xf5\x20\x08\xc5\x22"
            "\x7e\x85\xcd\xcb\x83\xb4\xc5\x94\x57\xf0\x2c\x50\x8d\x4f\x4f\x69"
            "\xf8\x26\xbd\x82\xc0\xcf\xfc\x5c\xb6\xa9\x7a\xf6\xe5\x61\xc6\xf9"
            "\x69\x70\x00\x52\x85\xe5\x8f\x21\xef\x65\x11\xd2\x6e\x70\x98\x89"
            "\xa7\xe5\x13\xc4\x34\xc9\x0a\x3c\xf7\x44\x8f\x0c\xae\xec\x71\x14"
            "\xc7\x47\xb2\xa0\x75\x8a\x3b\x45\x03\xa7\xcf\x0c\x69\x87\x3e\xd3"
            "\x1d\x94\xdb\xef\x2b\x7b\x2f\x16\x88\x30\xef\x7d\xa3\x32\x2c\x3d"
            "\x3e\x10\xca\xfb\x7c\x2c\x33\xc8\x3b\xbf\x4c\x46\xa3\x1d\xa9\x0c"
            "\xff\x3b\xfd\x4c\xcc\x6e\xd4\xb3\x10\x75\x84\x91\xee\xba\x60\x3a"
            "\x76",
        .message_len = 1160 / 8,
        .digest = {0xf15f82e5, 0xd570c0a3, 0xe7bb2fa5, 0x444a8511, 0x5f295405,
                   0x69797afb, 0xd10879a1, 0xbebf6301, 0xa6521d8f, 0x13a0e876,
                   0x1ca1567b, 0xb4fb0fdf, 0x9f89bc56, 0x4bd127c7, 0x322288d8,
                   0x4e919d54},
        .digest_len = DIGEST_LEN_SHA3_512,
};

/* ============================================================================
 * Benchmark implementation
 * ========================================================================= */

void initialize_edn()
{
    uint32_t *p;

    p = (uint32_t*)0xc1160024;
    *p = 0x00909099;
    p = (uint32_t*)0xc1160020;
    *p = 0x00000006;
    p = (uint32_t*)0xc1150014;
    *p = 0x00000666;
    p = (uint32_t*)0xc1170014;
    *p = 0x00009966;
}

void initialize_memory(
        uint8_t *src_data,
        size_t src_n,
        uint8_t *dst_data,
        size_t dst_n,
        uint8_t *key_data,
        size_t key_n,
        uint8_t *iv_data,
        size_t iv_n)
{
    titanssl_data_src.data = src_data;
    titanssl_data_src.n = src_n;
    for (size_t i=0; i<src_n; i++)
    {
        titanssl_data_src.data[i] = 0x0;
    }

    titanssl_data_dst.data = dst_data;
    titanssl_data_dst.n = dst_n;
    for (size_t i=0; i<dst_n; i++)
    {
        titanssl_data_dst.data[i] = 0x0;
    }

    titanssl_data_key.data = key_data;
    titanssl_data_key.n = key_n;
    for (size_t i=0; i<key_n; i++)
    {
        titanssl_data_key.data[i] = 0x0;
    }

    titanssl_data_iv.data = iv_data;
    titanssl_data_iv.n = iv_n;
    for (size_t i=0; i<iv_n; i++)
    {
        titanssl_data_iv.data[i] = 0x0;
    }
}

void titanssl_benchmark_hmac(
        titanssl_buffer_t *const src,
        titanssl_buffer_t *const dst,
        titanssl_buffer_t *const key,
        __attribute__((unused)) titanssl_buffer_t *const iv)
{
    mmio_region_t hmac;
    uint32_t reg;
    const uint8_t *dp;

    // Get the HMAC IP base address
    hmac = mmio_region_from_addr(TOP_EARLGREY_HMAC_BASE_ADDR);
    reg = mmio_region_read32(
        hmac,
        HMAC_CFG_REG_OFFSET
    );

    // Initialize HMAC IP with digest and message in little-endian mode
#if TITANSSL_BENCHMARK_SHA256
    reg = bitfield_bit32_write(reg, HMAC_CFG_ENDIAN_SWAP_BIT, false);
    reg = bitfield_bit32_write(reg, HMAC_CFG_DIGEST_SWAP_BIT, false);
    reg = bitfield_bit32_write(reg, HMAC_CFG_SHA_EN_BIT, true);
    reg = bitfield_bit32_write(reg, HMAC_CFG_HMAC_EN_BIT, false);
    mmio_region_write32(
        hmac,
        HMAC_CFG_REG_OFFSET,
        reg
    );
#elif TITANSSL_BENCHMARK_HMAC
    mmio_region_write32(hmac, HMAC_KEY_0_REG_OFFSET, key->data[0]);
    mmio_region_write32(hmac, HMAC_KEY_1_REG_OFFSET, key->data[1]);
    mmio_region_write32(hmac, HMAC_KEY_2_REG_OFFSET, key->data[2]);
    mmio_region_write32(hmac, HMAC_KEY_3_REG_OFFSET, key->data[3]);
    mmio_region_write32(hmac, HMAC_KEY_4_REG_OFFSET, key->data[4]);
    mmio_region_write32(hmac, HMAC_KEY_5_REG_OFFSET, key->data[5]);
    mmio_region_write32(hmac, HMAC_KEY_6_REG_OFFSET, key->data[6]);
    mmio_region_write32(hmac, HMAC_KEY_7_REG_OFFSET, key->data[7]);
    reg = bitfield_bit32_write(reg, HMAC_CFG_ENDIAN_SWAP_BIT, false);
    reg = bitfield_bit32_write(reg, HMAC_CFG_DIGEST_SWAP_BIT, false);
    reg = bitfield_bit32_write(reg, HMAC_CFG_SHA_EN_BIT, true);
    reg = bitfield_bit32_write(reg, HMAC_CFG_HMAC_EN_BIT, true);
    mmio_region_write32(
        hmac,
        HMAC_CFG_REG_OFFSET,
        reg
    );
#endif

    // Start operations
    mmio_region_nonatomic_set_bit32(
        hmac,
        HMAC_CMD_REG_OFFSET,
        HMAC_CMD_HASH_START_BIT
    );

    // Compute SHA256, assuming the payload address is 4-bytes aligned
    dp = src->data;
    while (dp < src->data + src->n) 
    {
        uint32_t n_bytes;
        uint32_t n_words;

        // Compute how many bytes need will be pushed into the accelerator FIFO.
        n_bytes = 16 * sizeof(uint32_t);
        if (n_bytes > src->data + src->n - dp)
        {
            n_bytes = src->data + src->n - dp;
        }
        n_words = n_bytes >> 2;
        n_bytes = n_bytes & 0x3;

        // Wait for the accelerator fifo to be empty.
        while(!mmio_region_get_bit32(
            hmac,
            HMAC_STATUS_REG_OFFSET,
            HMAC_STATUS_FIFO_EMPTY_BIT
        ));

        // Push data into the FIFO.
        for (size_t i=0; i<n_words; i++)
        {
            mmio_region_write32(
                hmac,
                HMAC_MSG_FIFO_REG_OFFSET,
                *(uint32_t*)dp
            );
            dp += sizeof(uint32_t);
        }
        for (size_t i=0; i<n_bytes; i++)
        {
            mmio_region_write8(
                hmac,
                HMAC_MSG_FIFO_REG_OFFSET,
                *dp
            );
            dp += 1;
        }
    }
    mmio_region_nonatomic_set_bit32(
        hmac,
        HMAC_CMD_REG_OFFSET,
        HMAC_CMD_HASH_PROCESS_BIT
    );
    while (!mmio_region_get_bit32(
        hmac,
        HMAC_INTR_STATE_REG_OFFSET,
        HMAC_INTR_STATE_HMAC_DONE_BIT
    ));

    // Wait for SHA-256 completion
    while (!mmio_region_get_bit32(
        hmac,
        HMAC_INTR_STATE_REG_OFFSET,
        HMAC_INTR_STATE_HMAC_DONE_BIT
    ));
    mmio_region_nonatomic_set_bit32(
        hmac,
        HMAC_INTR_STATE_REG_OFFSET,
        HMAC_INTR_STATE_HMAC_DONE_BIT
    );

    // Copy the digest
    ((uint32_t*)(dst->data))[0] = mmio_region_read32(hmac, HMAC_DIGEST_0_REG_OFFSET);
    ((uint32_t*)(dst->data))[1] = mmio_region_read32(hmac, HMAC_DIGEST_1_REG_OFFSET);
    ((uint32_t*)(dst->data))[2] = mmio_region_read32(hmac, HMAC_DIGEST_2_REG_OFFSET);
    ((uint32_t*)(dst->data))[3] = mmio_region_read32(hmac, HMAC_DIGEST_3_REG_OFFSET);
    ((uint32_t*)(dst->data))[4] = mmio_region_read32(hmac, HMAC_DIGEST_4_REG_OFFSET);
    ((uint32_t*)(dst->data))[5] = mmio_region_read32(hmac, HMAC_DIGEST_5_REG_OFFSET);
    ((uint32_t*)(dst->data))[6] = mmio_region_read32(hmac, HMAC_DIGEST_6_REG_OFFSET);
    ((uint32_t*)(dst->data))[7] = mmio_region_read32(hmac, HMAC_DIGEST_7_REG_OFFSET);

    // Disable HMAC IP
    reg = mmio_region_read32(hmac, HMAC_CFG_REG_OFFSET);
    reg = bitfield_bit32_write(reg, HMAC_CFG_SHA_EN_BIT, false);
    reg = bitfield_bit32_write(reg, HMAC_CFG_HMAC_EN_BIT, false);
    mmio_region_write32(hmac, HMAC_CFG_REG_OFFSET, reg);

    // Print the message digest, if we are in debug mode.
#if TITANSSL_BENCHMARK_DEBUG
	for (int i=0; i<HMAC_PARAM_NUM_WORDS; i++)
	{
		printf(
            "0x%08x\r\n",
            ((uint32_t*)(dst->data))[i]
        );
        uart_wait_tx_done();
	}
#endif
}

void titanssl_benchmark_aes(
        titanssl_buffer_t *const src,
        titanssl_buffer_t *const dst,
        titanssl_buffer_t *const key,
        titanssl_buffer_t *const iv)
{
    dif_aes_key_share_t round_key;
    dif_aes_iv_t round_iv;
    dif_aes_t aes;
    dif_aes_transaction_t cfg;
    dif_result_t res;

	// Initialize AES IP in CBC mode
    cfg.operation = kDifAesOperationEncrypt;
    cfg.mode = kDifAesModeCbc;
    cfg.key_len = kDifAesKey256;
    cfg.key_provider = kDifAesKeySoftwareProvided;
    cfg.mask_reseeding = kDifAesReseedPer64Block;
    cfg.manual_operation = kDifAesManualOperationAuto;
    cfg.reseed_on_key_change = false;
    cfg.ctrl_aux_lock = false;
    for (size_t i=0; i<sizeof(round_key.share0); i++)
    {
        round_key.share0[i] = key->data[i];
        round_key.share1[i] = key->data[i];
    }
    for (size_t i=0; i<sizeof(round_iv.iv); i++)
    {
        round_iv.iv[i] = iv->data[i];
    }
    res = dif_aes_init(
        mmio_region_from_addr(TOP_EARLGREY_AES_BASE_ADDR), 
        &aes
    );
    res = dif_aes_reset(&aes);
    res = dif_aes_start(
        &aes, 
        &cfg, 
        &round_key, 
        &round_iv
    );

    // Compute AES
    const uint8_t *kDataSrc = src->data;
    const uint8_t *kDataDst = dst->data;
    size_t kDataSize = src->n;
    uint8_t *dpSrc = src->data;
    uint8_t *dpDst = dst->data;

    mmio_region_write32(aes.base_addr, AES_DATA_IN_0_REG_OFFSET, ((uint32_t*)dpSrc)[0]);
    mmio_region_write32(aes.base_addr, AES_DATA_IN_1_REG_OFFSET, ((uint32_t*)dpSrc)[1]);
    mmio_region_write32(aes.base_addr, AES_DATA_IN_2_REG_OFFSET, ((uint32_t*)dpSrc)[2]);
    mmio_region_write32(aes.base_addr, AES_DATA_IN_3_REG_OFFSET, ((uint32_t*)dpSrc)[3]);
    while(!mmio_region_get_bit32(
        aes.base_addr, 
        AES_STATUS_REG_OFFSET,
        AES_STATUS_INPUT_READY_BIT
    ));
    dpSrc += 16;
    
    while (dpSrc - kDataSrc < kDataSize) {
        mmio_region_write32(aes.base_addr, AES_DATA_IN_0_REG_OFFSET, ((uint32_t*)dpSrc)[0]);
        mmio_region_write32(aes.base_addr, AES_DATA_IN_1_REG_OFFSET, ((uint32_t*)dpSrc)[1]);
        mmio_region_write32(aes.base_addr, AES_DATA_IN_2_REG_OFFSET, ((uint32_t*)dpSrc)[2]);
        mmio_region_write32(aes.base_addr, AES_DATA_IN_3_REG_OFFSET, ((uint32_t*)dpSrc)[3]);

        while(!mmio_region_get_bit32(
            aes.base_addr, 
            AES_STATUS_REG_OFFSET,
            AES_STATUS_OUTPUT_VALID_BIT
        ));
        *(uint32_t*)(dpDst+0x0) = mmio_region_read32(aes.base_addr, AES_DATA_OUT_0_REG_OFFSET);
        *(uint32_t*)(dpDst+0x4) = mmio_region_read32(aes.base_addr, AES_DATA_OUT_1_REG_OFFSET);
        *(uint32_t*)(dpDst+0x8) = mmio_region_read32(aes.base_addr, AES_DATA_OUT_2_REG_OFFSET);
        *(uint32_t*)(dpDst+0xc) = mmio_region_read32(aes.base_addr, AES_DATA_OUT_3_REG_OFFSET);
        dpDst += 16;
        dpSrc += 16;
    }
    while(!mmio_region_get_bit32(
        aes.base_addr, 
        AES_STATUS_REG_OFFSET,
        AES_STATUS_OUTPUT_VALID_BIT
    ));
    *(uint32_t*)(dpDst+0x0) = mmio_region_read32(aes.base_addr, AES_DATA_OUT_0_REG_OFFSET);
    *(uint32_t*)(dpDst+0x4) = mmio_region_read32(aes.base_addr, AES_DATA_OUT_1_REG_OFFSET);
    *(uint32_t*)(dpDst+0x8) = mmio_region_read32(aes.base_addr, AES_DATA_OUT_2_REG_OFFSET);
    *(uint32_t*)(dpDst+0xc) = mmio_region_read32(aes.base_addr, AES_DATA_OUT_3_REG_OFFSET);

    res = dif_aes_end(&aes);

    // Print the message digest, if we are in debug mode.
#if TITANSSL_BENCHMARK_DEBUG
	for (int i=0; i<dst->n; i++)
	{
		printf(
            "0x%08x\r\n",
            ((uint32_t*)(dst->data))[i]
        );
        uart_wait_tx_done();
	}
#endif
}

void titanssl_benchmark_sha3(
        titanssl_buffer_t *const src,
        titanssl_buffer_t *const dst,
        titanssl_buffer_t *const key,
        titanssl_buffer_t *const iv)
{
    mmio_region_t kmac = mmio_region_from_addr(TOP_EARLGREY_KMAC_BASE_ADDR);

    dif_kmac_config_t config = (dif_kmac_config_t){
      .entropy_mode = kDifKmacEntropyModeSoftware,
      .entropy_seed = {0xaa25b4bf, 0x48ce8fff, 0x5a78282a, 0x48465647,
                       0x70410fef},
      .entropy_fast_process = kDifToggleEnabled,
    };

    // Entropy mode.
    uint32_t entropy_mode_value;
    bool entropy_ready = false;
    entropy_mode_value = KMAC_CFG_SHADOWED_ENTROPY_MODE_VALUE_SW_MODE;
    entropy_ready = true;

    // Check that the hardware is in an idle state.
    if (!is_state_idle(kmac)) {
      return kDifLocked;
    }
    // Write entropy period register.
    uint32_t entropy_period_reg = 0;
    entropy_period_reg = bitfield_field32_write(
                                                entropy_period_reg, KMAC_ENTROPY_PERIOD_WAIT_TIMER_FIELD,
                                                config.entropy_wait_timer);
    entropy_period_reg = bitfield_field32_write(
                                                entropy_period_reg, KMAC_ENTROPY_PERIOD_PRESCALER_FIELD,
                                                config.entropy_prescaler);

    mmio_region_write32(kmac->base_addr, KMAC_ENTROPY_PERIOD_REG_OFFSET,
                        entropy_period_reg);

    // Write threshold register.
    uint32_t entropy_threshold_reg =
      KMAC_ENTROPY_REFRESH_THRESHOLD_SHADOWED_REG_RESVAL;
    entropy_threshold_reg = bitfield_field32_write(
                                                   entropy_threshold_reg,
                                                   KMAC_ENTROPY_REFRESH_THRESHOLD_SHADOWED_THRESHOLD_FIELD,
                                                   config.entropy_hash_threshold);

    mmio_region_write32_shadowed(
                                 kmac->base_addr, KMAC_ENTROPY_REFRESH_THRESHOLD_SHADOWED_REG_OFFSET,
                                 entropy_threshold_reg);

    // Write configuration register.
    uint32_t cfg_reg = 0;
    cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_MSG_ENDIANNESS_BIT, config.message_big_endian);
    cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_STATE_ENDIANNESS_BIT, config.output_big_endian);
    cfg_reg = bitfield_field32_write(cfg_reg, KMAC_CFG_SHADOWED_ENTROPY_MODE_FIELD, entropy_mode_value);
    cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_ENTROPY_FAST_PROCESS_BIT, onfig.entropy_fast_process);
    cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_SIDELOAD_BIT, config.sideload);
    cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_ENTROPY_READY_BIT, entropy_ready);
    cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_MSG_MASK_BIT, config.msg_mask);
    mmio_region_write32_shadowed(kmac->base_addr, KMAC_CFG_SHADOWED_REG_OFFSET, cfg_reg);
    // Write entropy seed registers.
    for (int i = 0; i < kDifKmacEntropySeedWords; ++i) {
      mmio_region_write32(kmac->base_addr,
                          KMAC_ENTROPY_SEED_0_REG_OFFSET + i * sizeof(uint32_t),
                          config.entropy_seed[i]);
    }

    dif_kmac_operation_state_t operation_state;
    sha3_test_t test = sha3_tests;
    uint32_t kstrength = KMAC_CFG_SHADOWED_KSTRENGTH_VALUE_L512;
    
    operation_state->offset = 0;
    operation_state->r = calculate_rate_bits(512) / 32;
    operation_state->d = 512 / 32;

    if (!is_state_idle(kmac)) {
      return kDifError;
    }

    operation_state->squeezing = false;
    operation_state->append_d = false;

    // Configure SHA-3 mode with the given strength.
    uint32_t cfg_reg = mmio_region_read32(kmac->base_addr, KMAC_CFG_SHADOWED_REG_OFFSET);
    cfg_reg = bitfield_field32_write(cfg_reg, KMAC_CFG_SHADOWED_KSTRENGTH_FIELD, kstrength);
    cfg_reg = bitfield_field32_write(cfg_reg, KMAC_CFG_SHADOWED_MODE_FIELD, KMAC_CFG_SHADOWED_MODE_VALUE_SHA3);
    mmio_region_write32(kmac->base_addr, KMAC_CFG_SHADOWED_REG_OFFSET, cfg_reg);
    mmio_region_write32(kmac->base_addr, KMAC_CFG_SHADOWED_REG_OFFSET, cfg_reg);

    // Issue start command.
    uint32_t cmd_reg = bitfield_field32_write(0, KMAC_CMD_CMD_FIELD, KMAC_CMD_CMD_VALUE_START);
    mmio_region_write32(kmac->base_addr, KMAC_CMD_REG_OFFSET, cmd_reg);

    // Poll until the status register is in the 'absorb' state.
    poll_state(kmac, KMAC_STATUS_SHA3_ABSORB_BIT);

    // Poll until the the status register is in the 'absorb' state.
    if (!is_state_absorb(kmac)) {
      return kDifError;
    }

    // Copy message using aligned word sized loads and stores where possible to
    // improve performance. Note: the parts of the message copied a byte at a time
    // will not be byte swapped in big-endian mode.
    const uint8_t *data = (const uint8_t *)msg;
    for (; len != 0 && ((uintptr_t)data) % sizeof(uint32_t); --len) {
      mmio_region_write8(kmac->base_addr, KMAC_MSG_FIFO_REG_OFFSET, *data++);
    }
    for (; len >= sizeof(uint32_t); len -= sizeof(uint32_t)) {
      mmio_region_write32(kmac->base_addr, KMAC_MSG_FIFO_REG_OFFSET, read_32(data));
      data += sizeof(uint32_t);
    }
    for (; len != 0; --len) {
      mmio_region_write8(kmac->base_addr, KMAC_MSG_FIFO_REG_OFFSET, *data++);
    }

    uint32_t out[DIGEST_LEN_SHA3_MAX];
    size_t len = test.digest_len;

    // Move into squeezing state (if not already in it).
    // Do this even if the length requested is 0 or too big.
    if (!operation_state->squeezing) {
        if (operation_state->append_d) {
          // The KMAC operation requires that the output length (d) in bits be right
          // encoded and appended to the end of the message.
          // Note: kDifKmacMaxOutputLenWords could be reduced to make this code
          // simpler. For example, a maximum of `(UINT16_MAX - 32) / 32` (just under
          // 8 KiB) would mean that d is guaranteed to be less than 0xFFFF.
          uint32_t d = operation_state->d * 32;
          int len = 1 + (d > 0xFF) + (d > 0xFFFF) + (d > 0xFFFFFF);
          int shift = (len - 1) * 8;
          while (shift >= 8) {
            mmio_region_write8(base, KMAC_MSG_FIFO_REG_OFFSET,(uint8_t)(d >> shift));
            shift -= 8;
          }
          mmio_region_write8(base, KMAC_MSG_FIFO_REG_OFFSET, (uint8_t)d);
          mmio_region_write8(base, KMAC_MSG_FIFO_REG_OFFSET, (uint8_t)len);
        }

        operation_state->squeezing = true;

        // Issue squeeze command.
        uint32_t cmd_reg = bitfield_field32_write(0, KMAC_CMD_CMD_FIELD, KMAC_CMD_CMD_VALUE_PROCESS);
        mmio_region_write32(base, KMAC_CMD_REG_OFFSET, cmd_reg);
    }

    if (len == 0) {
      return kDifOk;
    }

    while (len > 0) {
      size_t n = len;
      size_t remaining = operation_state->r - operation_state->offset;
      if (operation_state->d != 0 && operation_state->d < operation_state->r) {
        remaining = operation_state->d - operation_state->offset;
      }
      if (n > remaining) {
        n = remaining;
      }
      if (n == 0) {
        // Reduce the digest length to reflect consumed output state.
        if (operation_state->d != 0) {
          operation_state->d -= operation_state->r;
        }
        // Issue run command to generate more state.
        uint32_t cmd_reg = bitfield_field32_write(0, KMAC_CMD_CMD_FIELD, KMAC_CMD_CMD_VALUE_RUN);
        mmio_region_write32(base, KMAC_CMD_REG_OFFSET, cmd_reg);
        operation_state->offset = 0;
        continue;
      }
      // Poll the status register until in the 'squeeze' state.
      poll_state(kmac, KMAC_STATUS_SHA3_SQUEEZE_BIT);

      uint32_t offset = KMAC_STATE_REG_OFFSET + operation_state->offset * sizeof(uint32_t);
      for (size_t i = 0; i < n; ++i) {
        // Read both shares from state register and combine using XOR.
        uint32_t share0 = mmio_region_read32(base, offset);
        uint32_t share1 = mmio_region_read32(base, offset + kDifKmacStateShareOffset);
        *out++ = share0 ^ share1;
        offset += sizeof(uint32_t);
      }
      operation_state->offset += n;
      len -= n;
      if (processed != NULL) {
        *processed += n;
      }
    }

    uint32_t cmd_reg = bitfield_field32_write(0, KMAC_CMD_CMD_FIELD, KMAC_CMD_CMD_VALUE_DONE);
    mmio_region_write32(kmac->base_addr, KMAC_CMD_REG_OFFSET, cmd_reg);

    // Reset operation state.
    operation_state->squeezing = false;
    operation_state->append_d = false;
    operation_state->offset = 0;
    operation_state->r = 0;
    operation_state->d = 0;
 
    for (int j = 0; j < test.digest_len; ++j) {
      CHECK(out[j] == test.digest[j],
         "test %d: mismatch at %d got=0x%x want=0x%x", i, j, out[j],
         test.digest[j]);
       }
  }
}
int main(
        int argc, 
        char **argv)
{
#ifdef TARGET_SYNTHESIS
#define baud_rate 115200
#define test_freq 50000000
#else
#define baud_rate 115200
#define test_freq 100000000
#endif
	uart_set_cfg(
        0,
        (test_freq/baud_rate)>>4
    );

    initialize_edn();
    initialize_memory(
        (uint8_t*)TITANSSL_DATA_SRC,
        TITANSSL_PAYLOAD_SIZE,
        (uint8_t*)TITANSSL_DATA_DST,
        TITANSSL_OUTPUT_SIZE,
        (uint8_t*)TITANSSL_DATA_KEY,
        TITANSSL_KEY_SIZE,
        (uint8_t*)TITANSSL_DATA_IV,
        TITANSSL_IV_SIZE
    );
    titanssl_benchmark(
        &titanssl_data_src,
        &titanssl_data_dst,
        &titanssl_data_key,
        &titanssl_data_iv
    );

	return 0;
}
