// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/base/bitfield.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/silicon_creator/rom/uart.h"
#include "sw/device/silicon_creator/rom/string_lib.h"

#include "aes_regs.h"  // Generated.

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

#include "sw/tests/opentitan/titanssl/titanssl_lib/headers/titanssl_aes.h"

static titanssl_batch_t aes_key;
static titanssl_batch_t aes_iv;

void aes_run(titanssl_mbox_t* t_mbox) { 

    static titanssl_batch_t aes_dst, aes_src;
    aes_dst.page = (uint8_t*) TITANSSL_DST_BASE_L1;
    aes_src.page = (uint8_t*) TITANSSL_SRC_BASE_L1;

    if(t_mbox->bitfield==0) {
        _aes_key_init(); // to move in main
        utils_entropy_init();
    }
    if(PRF) utils_profile_analyses("aes variables init");

#if CFG_CVA6_STATUS > 0
    _aes_run(t_mbox, &aes_dst, &aes_src);
#elif
    _aes_run_ibex(t_mbox, &aes_dst, &aes_src);
#endif

    if(PRF) utils_profile_analyses("aes crypto");

    if(DEB) _aes_check(&aes_dst);

    if(PRF) utils_profile_analyses("check result");
}

void _aes_key_init() {
    aes_key.page = (uint8_t*)TITANSSL_KEY_BASE;
    for (size_t j=0; j<TITANSSL_KEY_SIZE; j++) aes_key.page[j] = 0x00;
    aes_iv.page = (uint8_t*)TITANSSL_IV_BASE;
    for (size_t j=0; j<TITANSSL_IV_SIZE; j++) aes_iv.page[j] = 0x00;
}

void _aes_check(titanssl_batch_t* t_dst) {
#if DEB
    for (int i=0; i<8; i++) {
        printf("[IBEX AES] 0x%08x vs 0x%08x\r\n", ExpectedAesDigest[i],
            ((uint32_t*)(t_dst->page))[i]);
        uart_wait_tx_done();
    }
#endif
}

void _aes_run(titanssl_mbox_t* t_mbox, titanssl_batch_t* t_dst, titanssl_batch_t* t_src) {
    uint32_t *nb = (uint32_t*) TITANSSL_OP_L1;
    mmio_region_t *aes = (mmio_region_t*) TITANSSL_OP_L1 + 10; 
    uint32_t reg, n_bytes;
    uint8_t *dp_src, *dp_dst;    

    n_bytes = *nb;
    utils_dram_readp(t_mbox, t_src, n_bytes);
    dp_src = t_src->page;
    dp_dst = t_dst->page;  

    if(t_mbox->bitfield==0) {
        // Get the AES IP base address 
        *aes = mmio_region_from_addr(TOP_EARLGREY_AES_BASE_ADDR);
        // Reset the IP
        while(!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
        reg = bitfield_bit32_write(0, AES_CTRL_SHADOWED_MANUAL_OPERATION_BIT, true);
        mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
        mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
        reg = bitfield_bit32_write(0, AES_TRIGGER_KEY_IV_DATA_IN_CLEAR_BIT, true);
        reg = bitfield_bit32_write(reg, AES_TRIGGER_DATA_OUT_CLEAR_BIT, true);
        mmio_region_write32(*aes, AES_TRIGGER_REG_OFFSET, reg);
        while (!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
        reg = bitfield_field32_write(0, AES_CTRL_SHADOWED_OPERATION_FIELD, AES_CTRL_SHADOWED_OPERATION_MASK);
        reg = bitfield_field32_write(reg, AES_CTRL_SHADOWED_MODE_FIELD, AES_CTRL_SHADOWED_MODE_VALUE_AES_NONE);
        reg = bitfield_field32_write(reg, AES_CTRL_SHADOWED_KEY_LEN_FIELD, AES_CTRL_SHADOWED_KEY_LEN_MASK);
        mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
        mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);

        // Initialize AES IP configurations
        while(!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
        reg = bitfield_field32_write(0, AES_CTRL_SHADOWED_OPERATION_FIELD, AES_CTRL_SHADOWED_OPERATION_VALUE_AES_ENC);
        reg = bitfield_field32_write(reg, AES_CTRL_SHADOWED_MODE_FIELD, AES_CTRL_SHADOWED_MODE_VALUE_AES_CBC);
        reg = bitfield_field32_write(reg, AES_CTRL_SHADOWED_KEY_LEN_FIELD, AES_CTRL_SHADOWED_KEY_LEN_VALUE_AES_256);
        reg = bitfield_field32_write(reg, AES_CTRL_SHADOWED_PRNG_RESEED_RATE_FIELD, AES_CTRL_SHADOWED_PRNG_RESEED_RATE_VALUE_PER_64);
        reg = bitfield_bit32_write(reg, AES_CTRL_SHADOWED_MANUAL_OPERATION_BIT, false);
        reg = bitfield_bit32_write(reg, AES_CTRL_SHADOWED_SIDELOAD_BIT, false);
        mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
        mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);

        // Initialize AES IP auxiliary configurations
        reg = bitfield_bit32_write(0, AES_CTRL_AUX_SHADOWED_KEY_TOUCH_FORCES_RESEED_BIT, false);
        reg = bitfield_bit32_write(reg, AES_CTRL_AUX_SHADOWED_FORCE_MASKS_BIT, false);
        mmio_region_write32(*aes, AES_CTRL_AUX_SHADOWED_REG_OFFSET, reg);
        mmio_region_write32(*aes, AES_CTRL_AUX_SHADOWED_REG_OFFSET, reg);
        mmio_region_write32(*aes, AES_CTRL_AUX_REGWEN_REG_OFFSET, true);

        // Initialize key shares
        mmio_region_write32(*aes, AES_KEY_SHARE0_0_REG_OFFSET,  ((uint32_t*)(aes_key.page))[0]);
        mmio_region_write32(*aes, AES_KEY_SHARE0_1_REG_OFFSET,  ((uint32_t*)(aes_key.page))[1]);
        mmio_region_write32(*aes, AES_KEY_SHARE0_2_REG_OFFSET,  ((uint32_t*)(aes_key.page))[2]);
        mmio_region_write32(*aes, AES_KEY_SHARE0_3_REG_OFFSET,  ((uint32_t*)(aes_key.page))[3]);
        mmio_region_write32(*aes, AES_KEY_SHARE0_4_REG_OFFSET,  ((uint32_t*)(aes_key.page))[4]);
        mmio_region_write32(*aes, AES_KEY_SHARE0_5_REG_OFFSET,  ((uint32_t*)(aes_key.page))[5]);
        mmio_region_write32(*aes, AES_KEY_SHARE0_6_REG_OFFSET,  ((uint32_t*)(aes_key.page))[6]);
        mmio_region_write32(*aes, AES_KEY_SHARE0_7_REG_OFFSET,  ((uint32_t*)(aes_key.page))[7]);
        mmio_region_write32(*aes, AES_KEY_SHARE1_0_REG_OFFSET,  ((uint32_t*)(aes_key.page))[0]);
        mmio_region_write32(*aes, AES_KEY_SHARE1_1_REG_OFFSET,  ((uint32_t*)(aes_key.page))[1]);
        mmio_region_write32(*aes, AES_KEY_SHARE1_2_REG_OFFSET,  ((uint32_t*)(aes_key.page))[2]);
        mmio_region_write32(*aes, AES_KEY_SHARE1_3_REG_OFFSET,  ((uint32_t*)(aes_key.page))[3]);
        mmio_region_write32(*aes, AES_KEY_SHARE1_4_REG_OFFSET,  ((uint32_t*)(aes_key.page))[4]);
        mmio_region_write32(*aes, AES_KEY_SHARE1_5_REG_OFFSET,  ((uint32_t*)(aes_key.page))[5]);
        mmio_region_write32(*aes, AES_KEY_SHARE1_6_REG_OFFSET,  ((uint32_t*)(aes_key.page))[6]);
        mmio_region_write32(*aes, AES_KEY_SHARE1_7_REG_OFFSET,  ((uint32_t*)(aes_key.page))[7]);

        // Initialize IV
        reg = mmio_region_read32(*aes, AES_CTRL_SHADOWED_REG_OFFSET);
        reg = bitfield_field32_read(reg, AES_CTRL_SHADOWED_MODE_FIELD);
        if (reg != AES_CTRL_SHADOWED_MODE_VALUE_AES_ECB)
        {
            while(!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
            mmio_region_write32(*aes, AES_IV_0_REG_OFFSET, ((uint32_t*)(aes_iv.page))[0]);
            mmio_region_write32(*aes, AES_IV_1_REG_OFFSET, ((uint32_t*)(aes_iv.page))[1]);
            mmio_region_write32(*aes, AES_IV_2_REG_OFFSET, ((uint32_t*)(aes_iv.page))[2]);
            mmio_region_write32(*aes, AES_IV_3_REG_OFFSET, ((uint32_t*)(aes_iv.page))[3]);
        }
        
        mmio_region_write32(*aes, AES_DATA_IN_0_REG_OFFSET, ((uint32_t*)dp_src)[0]);
        mmio_region_write32(*aes, AES_DATA_IN_1_REG_OFFSET, ((uint32_t*)dp_src)[1]);
        mmio_region_write32(*aes, AES_DATA_IN_2_REG_OFFSET, ((uint32_t*)dp_src)[2]);
        mmio_region_write32(*aes, AES_DATA_IN_3_REG_OFFSET, ((uint32_t*)dp_src)[3]);
        while(!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_INPUT_READY_BIT));
        dp_src += 16;
        n_bytes += 16;
    } 

    while (n_bytes < t_mbox->in_size && n_bytes-(*nb) <= TITANSSL_SCRATCHPAD_SIZE) {
        mmio_region_write32(*aes, AES_DATA_IN_0_REG_OFFSET, ((uint32_t*)dp_src)[0]);
        mmio_region_write32(*aes, AES_DATA_IN_1_REG_OFFSET, ((uint32_t*)dp_src)[1]);
        mmio_region_write32(*aes, AES_DATA_IN_2_REG_OFFSET, ((uint32_t*)dp_src)[2]);
        mmio_region_write32(*aes, AES_DATA_IN_3_REG_OFFSET, ((uint32_t*)dp_src)[3]);
        while(!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_OUTPUT_VALID_BIT));
        ((uint32_t*)(dp_dst))[0] = mmio_region_read32(*aes, AES_DATA_OUT_0_REG_OFFSET);
        ((uint32_t*)(dp_dst))[1] = mmio_region_read32(*aes, AES_DATA_OUT_1_REG_OFFSET);
        ((uint32_t*)(dp_dst))[2] = mmio_region_read32(*aes, AES_DATA_OUT_2_REG_OFFSET);
        ((uint32_t*)(dp_dst))[3] = mmio_region_read32(*aes, AES_DATA_OUT_3_REG_OFFSET);

        if ((n_bytes+16) % TITANSSL_PAGE_SIZE == 0 && n_bytes+16!=t_mbox->in_size) {
            utils_dram_readp(t_mbox, t_src, n_bytes+16);
            dp_src = t_src->page;
            dp_dst += 16;
        } else if (n_bytes % TITANSSL_PAGE_SIZE == 0) {
            utils_scratch_write(t_dst,
                (((n_bytes-1) / TITANSSL_PAGE_SIZE) % (TITANSSL_SCRATCHPAD_SIZE / TITANSSL_PAGE_SIZE)),
                TITANSSL_PAGE_SIZE);
            dp_dst = t_dst->page;
            dp_src += 16;
        } else {
            dp_dst += 16;
            if (n_bytes+16!=t_mbox->in_size) dp_src += 16;
        }

        n_bytes += 16;

    }

    if(n_bytes >= t_mbox->in_size) {
        while(!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_OUTPUT_VALID_BIT));
        ((uint32_t*)(dp_dst))[0] = mmio_region_read32(*aes, AES_DATA_OUT_0_REG_OFFSET);
        ((uint32_t*)(dp_dst))[1] = mmio_region_read32(*aes, AES_DATA_OUT_1_REG_OFFSET);
        ((uint32_t*)(dp_dst))[2] = mmio_region_read32(*aes, AES_DATA_OUT_2_REG_OFFSET);
        ((uint32_t*)(dp_dst))[3] = mmio_region_read32(*aes, AES_DATA_OUT_3_REG_OFFSET);

        utils_scratch_write(t_dst,
        (((n_bytes-1) / TITANSSL_PAGE_SIZE) % (TITANSSL_SCRATCHPAD_SIZE / TITANSSL_PAGE_SIZE)),
        n_bytes % TITANSSL_PAGE_SIZE); 
        *nb = 0;

        // DA FARE!!! utils_write_mbox()

        // Reset operation mode, key, iv, and data registers
        while(!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
        reg = bitfield_bit32_write(0, AES_CTRL_SHADOWED_MANUAL_OPERATION_BIT, true);
        mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
        mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
        reg = bitfield_bit32_write(0, AES_TRIGGER_KEY_IV_DATA_IN_CLEAR_BIT, true);
        reg = bitfield_bit32_write(reg, AES_TRIGGER_DATA_OUT_CLEAR_BIT, true);
        mmio_region_write32(*aes, AES_TRIGGER_REG_OFFSET, reg);
        while (!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
    } else {
        *nb = n_bytes;
    }

}

void _aes_run_ibex(titanssl_mbox_t* t_mbox, titanssl_batch_t* t_dst, titanssl_batch_t* t_src) {
    mmio_region_t *aes = (mmio_region_t*) TITANSSL_OP_L1 + 10; 
    uint32_t reg, n_bytes;
    uint8_t *dp_src, *dp_dst;    

    utils_dram_readp(t_mbox, t_src, n_bytes);
    dp_src = t_src->page;
    dp_dst = t_dst->page;  

    // Get the AES IP base address 
    *aes = mmio_region_from_addr(TOP_EARLGREY_AES_BASE_ADDR);
    // Reset the IP
    while(!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
    reg = bitfield_bit32_write(0, AES_CTRL_SHADOWED_MANUAL_OPERATION_BIT, true);
    mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
    mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
    reg = bitfield_bit32_write(0, AES_TRIGGER_KEY_IV_DATA_IN_CLEAR_BIT, true);
    reg = bitfield_bit32_write(reg, AES_TRIGGER_DATA_OUT_CLEAR_BIT, true);
    mmio_region_write32(*aes, AES_TRIGGER_REG_OFFSET, reg);
    while (!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
    reg = bitfield_field32_write(0, AES_CTRL_SHADOWED_OPERATION_FIELD, AES_CTRL_SHADOWED_OPERATION_MASK);
    reg = bitfield_field32_write(reg, AES_CTRL_SHADOWED_MODE_FIELD, AES_CTRL_SHADOWED_MODE_VALUE_AES_NONE);
    reg = bitfield_field32_write(reg, AES_CTRL_SHADOWED_KEY_LEN_FIELD, AES_CTRL_SHADOWED_KEY_LEN_MASK);
    mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
    mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);

    // Initialize AES IP configurations
    while(!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
    reg = bitfield_field32_write(0, AES_CTRL_SHADOWED_OPERATION_FIELD, AES_CTRL_SHADOWED_OPERATION_VALUE_AES_ENC);
    reg = bitfield_field32_write(reg, AES_CTRL_SHADOWED_MODE_FIELD, AES_CTRL_SHADOWED_MODE_VALUE_AES_CBC);
    reg = bitfield_field32_write(reg, AES_CTRL_SHADOWED_KEY_LEN_FIELD, AES_CTRL_SHADOWED_KEY_LEN_VALUE_AES_256);
    reg = bitfield_field32_write(reg, AES_CTRL_SHADOWED_PRNG_RESEED_RATE_FIELD, AES_CTRL_SHADOWED_PRNG_RESEED_RATE_VALUE_PER_64);
    reg = bitfield_bit32_write(reg, AES_CTRL_SHADOWED_MANUAL_OPERATION_BIT, false);
    reg = bitfield_bit32_write(reg, AES_CTRL_SHADOWED_SIDELOAD_BIT, false);
    mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
    mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);

    // Initialize AES IP auxiliary configurations
    reg = bitfield_bit32_write(0, AES_CTRL_AUX_SHADOWED_KEY_TOUCH_FORCES_RESEED_BIT, false);
    reg = bitfield_bit32_write(reg, AES_CTRL_AUX_SHADOWED_FORCE_MASKS_BIT, false);
    mmio_region_write32(*aes, AES_CTRL_AUX_SHADOWED_REG_OFFSET, reg);
    mmio_region_write32(*aes, AES_CTRL_AUX_SHADOWED_REG_OFFSET, reg);
    mmio_region_write32(*aes, AES_CTRL_AUX_REGWEN_REG_OFFSET, true);

    // Initialize key shares
    mmio_region_write32(*aes, AES_KEY_SHARE0_0_REG_OFFSET,  ((uint32_t*)(aes_key.page))[0]);
    mmio_region_write32(*aes, AES_KEY_SHARE0_1_REG_OFFSET,  ((uint32_t*)(aes_key.page))[1]);
    mmio_region_write32(*aes, AES_KEY_SHARE0_2_REG_OFFSET,  ((uint32_t*)(aes_key.page))[2]);
    mmio_region_write32(*aes, AES_KEY_SHARE0_3_REG_OFFSET,  ((uint32_t*)(aes_key.page))[3]);
    mmio_region_write32(*aes, AES_KEY_SHARE0_4_REG_OFFSET,  ((uint32_t*)(aes_key.page))[4]);
    mmio_region_write32(*aes, AES_KEY_SHARE0_5_REG_OFFSET,  ((uint32_t*)(aes_key.page))[5]);
    mmio_region_write32(*aes, AES_KEY_SHARE0_6_REG_OFFSET,  ((uint32_t*)(aes_key.page))[6]);
    mmio_region_write32(*aes, AES_KEY_SHARE0_7_REG_OFFSET,  ((uint32_t*)(aes_key.page))[7]);
    mmio_region_write32(*aes, AES_KEY_SHARE1_0_REG_OFFSET,  ((uint32_t*)(aes_key.page))[0]);
    mmio_region_write32(*aes, AES_KEY_SHARE1_1_REG_OFFSET,  ((uint32_t*)(aes_key.page))[1]);
    mmio_region_write32(*aes, AES_KEY_SHARE1_2_REG_OFFSET,  ((uint32_t*)(aes_key.page))[2]);
    mmio_region_write32(*aes, AES_KEY_SHARE1_3_REG_OFFSET,  ((uint32_t*)(aes_key.page))[3]);
    mmio_region_write32(*aes, AES_KEY_SHARE1_4_REG_OFFSET,  ((uint32_t*)(aes_key.page))[4]);
    mmio_region_write32(*aes, AES_KEY_SHARE1_5_REG_OFFSET,  ((uint32_t*)(aes_key.page))[5]);
    mmio_region_write32(*aes, AES_KEY_SHARE1_6_REG_OFFSET,  ((uint32_t*)(aes_key.page))[6]);
    mmio_region_write32(*aes, AES_KEY_SHARE1_7_REG_OFFSET,  ((uint32_t*)(aes_key.page))[7]);

    // Initialize IV
    reg = mmio_region_read32(*aes, AES_CTRL_SHADOWED_REG_OFFSET);
    reg = bitfield_field32_read(reg, AES_CTRL_SHADOWED_MODE_FIELD);
    if (reg != AES_CTRL_SHADOWED_MODE_VALUE_AES_ECB)
    {
        while(!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
        mmio_region_write32(*aes, AES_IV_0_REG_OFFSET, ((uint32_t*)(aes_iv.page))[0]);
        mmio_region_write32(*aes, AES_IV_1_REG_OFFSET, ((uint32_t*)(aes_iv.page))[1]);
        mmio_region_write32(*aes, AES_IV_2_REG_OFFSET, ((uint32_t*)(aes_iv.page))[2]);
        mmio_region_write32(*aes, AES_IV_3_REG_OFFSET, ((uint32_t*)(aes_iv.page))[3]);
    }
        
    mmio_region_write32(*aes, AES_DATA_IN_0_REG_OFFSET, ((uint32_t*)dp_src)[0]);
    mmio_region_write32(*aes, AES_DATA_IN_1_REG_OFFSET, ((uint32_t*)dp_src)[1]);
    mmio_region_write32(*aes, AES_DATA_IN_2_REG_OFFSET, ((uint32_t*)dp_src)[2]);
    mmio_region_write32(*aes, AES_DATA_IN_3_REG_OFFSET, ((uint32_t*)dp_src)[3]);
    while(!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_INPUT_READY_BIT));
    dp_src += 16;
    n_bytes += 16;

    while (n_bytes < t_mbox->in_size) {
        mmio_region_write32(*aes, AES_DATA_IN_0_REG_OFFSET, ((uint32_t*)dp_src)[0]);
        mmio_region_write32(*aes, AES_DATA_IN_1_REG_OFFSET, ((uint32_t*)dp_src)[1]);
        mmio_region_write32(*aes, AES_DATA_IN_2_REG_OFFSET, ((uint32_t*)dp_src)[2]);
        mmio_region_write32(*aes, AES_DATA_IN_3_REG_OFFSET, ((uint32_t*)dp_src)[3]);
        while(!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_OUTPUT_VALID_BIT));
        ((uint32_t*)(dp_dst))[0] = mmio_region_read32(*aes, AES_DATA_OUT_0_REG_OFFSET);
        ((uint32_t*)(dp_dst))[1] = mmio_region_read32(*aes, AES_DATA_OUT_1_REG_OFFSET);
        ((uint32_t*)(dp_dst))[2] = mmio_region_read32(*aes, AES_DATA_OUT_2_REG_OFFSET);
        ((uint32_t*)(dp_dst))[3] = mmio_region_read32(*aes, AES_DATA_OUT_3_REG_OFFSET);

        if ((n_bytes+16) % TITANSSL_PAGE_SIZE == 0 && n_bytes+16!=t_mbox->in_size) {
            utils_dram_readp(t_mbox, t_src, n_bytes+16);
            dp_src = t_src->page;
            dp_dst += 16;
        } else if (n_bytes % TITANSSL_PAGE_SIZE == 0) {
            utils_scratch_write(t_dst,
                (((n_bytes-1) / TITANSSL_PAGE_SIZE) % (TITANSSL_SCRATCHPAD_SIZE / TITANSSL_PAGE_SIZE)),
                TITANSSL_PAGE_SIZE);
            dp_dst = t_dst->page;
            dp_src += 16;
        } else {
            dp_dst += 16;
            if (n_bytes+16!=t_mbox->in_size) dp_src += 16;
        }

        n_bytes += 16;

    }

    while(!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_OUTPUT_VALID_BIT));
    ((uint32_t*)(dp_dst))[0] = mmio_region_read32(*aes, AES_DATA_OUT_0_REG_OFFSET);
    ((uint32_t*)(dp_dst))[1] = mmio_region_read32(*aes, AES_DATA_OUT_1_REG_OFFSET);
    ((uint32_t*)(dp_dst))[2] = mmio_region_read32(*aes, AES_DATA_OUT_2_REG_OFFSET);
    ((uint32_t*)(dp_dst))[3] = mmio_region_read32(*aes, AES_DATA_OUT_3_REG_OFFSET);

    utils_scratch_write(t_dst,
        (((n_bytes-1) / TITANSSL_PAGE_SIZE) % (TITANSSL_SCRATCHPAD_SIZE / TITANSSL_PAGE_SIZE)),
        n_bytes % TITANSSL_PAGE_SIZE); 

        // DA FARE!!! utils_write_mbox()

    // Reset operation mode, key, iv, and data registers
    while(!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
    reg = bitfield_bit32_write(0, AES_CTRL_SHADOWED_MANUAL_OPERATION_BIT, true);
    mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
    mmio_region_write32(*aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
    reg = bitfield_bit32_write(0, AES_TRIGGER_KEY_IV_DATA_IN_CLEAR_BIT, true);
    reg = bitfield_bit32_write(reg, AES_TRIGGER_DATA_OUT_CLEAR_BIT, true);
    mmio_region_write32(*aes, AES_TRIGGER_REG_OFFSET, reg);
    while (!mmio_region_get_bit32(*aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));

}