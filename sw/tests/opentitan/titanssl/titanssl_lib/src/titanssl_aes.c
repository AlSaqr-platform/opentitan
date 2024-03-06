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
static titanssl_batch_t titanssl_dst;

void aes_run(titanssl_mbox_t* titanssl_mbox, titanssl_batch_t* titanssl_scratch) {

    utils_dst_init(&titanssl_dst, TITANSSL_SCRATCHPAD_SIZE);
    _aes_key_init();
    utils_entropy_init();
    _aes_run(titanssl_mbox, titanssl_scratch);
    _aes_check(titanssl_scratch);
    // free(titanssl_dst.page);
}

void _aes_key_init() {
    aes_key.page = (uint8_t*)TITANSSL_KEY_BASE;
    for (size_t j=0; j<TITANSSL_KEY_SIZE; j++) aes_key.page[j] = 0x00;
    aes_iv.page = (uint8_t*)TITANSSL_IV_BASE;
    for (size_t j=0; j<TITANSSL_IV_SIZE; j++) aes_iv.page[j] = 0x00;
}

void _aes_wait_rtw(titanssl_mbox_t* titanssl_mbox) {
    // while(!(titanssl_mbox->rtw));
    while(!(flag));
    flag=0;
}

void _aes_set_rtw(titanssl_mbox_t* titanssl_mbox) {
    // titanssl_mbox->rtw = 0x1;
    utils_irq_reset_comp();
    utils_irq_trig_comp();
}

void _aes_check(titanssl_batch_t* titanssl_scratch) {
#if DEB
    for (int i=0; i<8; i++) {
        printf("[IBEX AES] 0x%08x vs 0x%08x\r\n", ExpectedAesDigest[i],
            ((uint32_t*)(titanssl_scratch->page))[i]);
        uart_wait_tx_done();
    }
#endif
}

void _aes_run(titanssl_mbox_t* titanssl_mbox, titanssl_batch_t* titanssl_scratch) {
    mmio_region_t aes;
    uint32_t reg;
    uint8_t *dp_src;
    uint8_t *dp_dst;

    // Get the AES IP base address
    aes = mmio_region_from_addr(TOP_EARLGREY_AES_BASE_ADDR);
    // Reset the IP
    // printf("[IBEX MBOX] before \r\n");
    /* uint32_t pppp = 0;
    while(!pppp)
    {
        pppp = mmio_region_get_bit32(aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT);
        printf("stampa %08x \r\n", pppp);
    } */
    while(!mmio_region_get_bit32(aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
    // printf("[IBEX MBOX] later \r\n");
    reg = bitfield_bit32_write(0, AES_CTRL_SHADOWED_MANUAL_OPERATION_BIT, true);
    mmio_region_write32(aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
    mmio_region_write32(aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
    reg = bitfield_bit32_write(0, AES_TRIGGER_KEY_IV_DATA_IN_CLEAR_BIT, true);
    reg = bitfield_bit32_write(reg, AES_TRIGGER_DATA_OUT_CLEAR_BIT, true);
    mmio_region_write32(aes, AES_TRIGGER_REG_OFFSET, reg);
    while (!mmio_region_get_bit32(aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
    reg = bitfield_field32_write(0, AES_CTRL_SHADOWED_OPERATION_FIELD, AES_CTRL_SHADOWED_OPERATION_MASK);
    reg = bitfield_field32_write(reg, AES_CTRL_SHADOWED_MODE_FIELD, AES_CTRL_SHADOWED_MODE_VALUE_AES_NONE);
    reg = bitfield_field32_write(reg, AES_CTRL_SHADOWED_KEY_LEN_FIELD, AES_CTRL_SHADOWED_KEY_LEN_MASK);
    mmio_region_write32(aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
    mmio_region_write32(aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);

    // Initialize AES IP configurations
    while(!mmio_region_get_bit32(aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
    reg = bitfield_field32_write(0, AES_CTRL_SHADOWED_OPERATION_FIELD, AES_CTRL_SHADOWED_OPERATION_VALUE_AES_ENC);
    reg = bitfield_field32_write(reg, AES_CTRL_SHADOWED_MODE_FIELD, AES_CTRL_SHADOWED_MODE_VALUE_AES_CBC);
    reg = bitfield_field32_write(reg, AES_CTRL_SHADOWED_KEY_LEN_FIELD, AES_CTRL_SHADOWED_KEY_LEN_VALUE_AES_256);
    reg = bitfield_field32_write(reg, AES_CTRL_SHADOWED_PRNG_RESEED_RATE_FIELD, AES_CTRL_SHADOWED_PRNG_RESEED_RATE_VALUE_PER_64);
    reg = bitfield_bit32_write(reg, AES_CTRL_SHADOWED_MANUAL_OPERATION_BIT, false);
    reg = bitfield_bit32_write(reg, AES_CTRL_SHADOWED_SIDELOAD_BIT, false);
    mmio_region_write32(aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
    mmio_region_write32(aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);

    // Initialize AES IP auxiliary configurations
    reg = bitfield_bit32_write(0, AES_CTRL_AUX_SHADOWED_KEY_TOUCH_FORCES_RESEED_BIT, false);
    reg = bitfield_bit32_write(reg, AES_CTRL_AUX_SHADOWED_FORCE_MASKS_BIT, false);
    mmio_region_write32(aes, AES_CTRL_AUX_SHADOWED_REG_OFFSET, reg);
    mmio_region_write32(aes, AES_CTRL_AUX_SHADOWED_REG_OFFSET, reg);
    mmio_region_write32(aes, AES_CTRL_AUX_REGWEN_REG_OFFSET, true);

    // Initialize key shares
    mmio_region_write32(aes, AES_KEY_SHARE0_0_REG_OFFSET,  ((uint32_t*)(aes_key.page))[0]);
    mmio_region_write32(aes, AES_KEY_SHARE0_1_REG_OFFSET,  ((uint32_t*)(aes_key.page))[1]);
    mmio_region_write32(aes, AES_KEY_SHARE0_2_REG_OFFSET,  ((uint32_t*)(aes_key.page))[2]);
    mmio_region_write32(aes, AES_KEY_SHARE0_3_REG_OFFSET,  ((uint32_t*)(aes_key.page))[3]);
    mmio_region_write32(aes, AES_KEY_SHARE0_4_REG_OFFSET,  ((uint32_t*)(aes_key.page))[4]);
    mmio_region_write32(aes, AES_KEY_SHARE0_5_REG_OFFSET,  ((uint32_t*)(aes_key.page))[5]);
    mmio_region_write32(aes, AES_KEY_SHARE0_6_REG_OFFSET,  ((uint32_t*)(aes_key.page))[6]);
    mmio_region_write32(aes, AES_KEY_SHARE0_7_REG_OFFSET,  ((uint32_t*)(aes_key.page))[7]);
    mmio_region_write32(aes, AES_KEY_SHARE1_0_REG_OFFSET,  ((uint32_t*)(aes_key.page))[0]);
    mmio_region_write32(aes, AES_KEY_SHARE1_1_REG_OFFSET,  ((uint32_t*)(aes_key.page))[1]);
    mmio_region_write32(aes, AES_KEY_SHARE1_2_REG_OFFSET,  ((uint32_t*)(aes_key.page))[2]);
    mmio_region_write32(aes, AES_KEY_SHARE1_3_REG_OFFSET,  ((uint32_t*)(aes_key.page))[3]);
    mmio_region_write32(aes, AES_KEY_SHARE1_4_REG_OFFSET,  ((uint32_t*)(aes_key.page))[4]);
    mmio_region_write32(aes, AES_KEY_SHARE1_5_REG_OFFSET,  ((uint32_t*)(aes_key.page))[5]);
    mmio_region_write32(aes, AES_KEY_SHARE1_6_REG_OFFSET,  ((uint32_t*)(aes_key.page))[6]);
    mmio_region_write32(aes, AES_KEY_SHARE1_7_REG_OFFSET,  ((uint32_t*)(aes_key.page))[7]);

    // Initialize IV
    reg = mmio_region_read32(aes, AES_CTRL_SHADOWED_REG_OFFSET);
    reg = bitfield_field32_read(reg, AES_CTRL_SHADOWED_MODE_FIELD);
    if (reg != AES_CTRL_SHADOWED_MODE_VALUE_AES_ECB)
    {
        while(!mmio_region_get_bit32(aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
        mmio_region_write32(aes, AES_IV_0_REG_OFFSET, ((uint32_t*)(aes_iv.page))[0]);
        mmio_region_write32(aes, AES_IV_1_REG_OFFSET, ((uint32_t*)(aes_iv.page))[1]);
        mmio_region_write32(aes, AES_IV_2_REG_OFFSET, ((uint32_t*)(aes_iv.page))[2]);
        mmio_region_write32(aes, AES_IV_3_REG_OFFSET, ((uint32_t*)(aes_iv.page))[3]);
    }

    // Compute AES
    dp_src = titanssl_mbox->p_index[0].page;
    dp_dst = titanssl_dst.page;
    mmio_region_write32(aes, AES_DATA_IN_0_REG_OFFSET, ((uint32_t*)dp_src)[0]);
    mmio_region_write32(aes, AES_DATA_IN_1_REG_OFFSET, ((uint32_t*)dp_src)[1]);
    mmio_region_write32(aes, AES_DATA_IN_2_REG_OFFSET, ((uint32_t*)dp_src)[2]);
    mmio_region_write32(aes, AES_DATA_IN_3_REG_OFFSET, ((uint32_t*)dp_src)[3]);
    while(!mmio_region_get_bit32(aes, AES_STATUS_REG_OFFSET, AES_STATUS_INPUT_READY_BIT));
    uint64_t n_bytes = 16;
    uint32_t thp = (titanssl_mbox->in_size - TITANSSL_PAGE_SIZE +1) / TITANSSL_PAGE_SIZE;
    uint32_t ths = (titanssl_mbox->in_size - TITANSSL_SCRATCHPAD_SIZE +1) / TITANSSL_SCRATCHPAD_SIZE;
    dp_src += 16;

    while (n_bytes < titanssl_mbox->in_size) { // (dp_src - plain->data < plain->n) {
        mmio_region_write32(aes, AES_DATA_IN_0_REG_OFFSET, ((uint32_t*)dp_src)[0]);
        mmio_region_write32(aes, AES_DATA_IN_1_REG_OFFSET, ((uint32_t*)dp_src)[1]);
        mmio_region_write32(aes, AES_DATA_IN_2_REG_OFFSET, ((uint32_t*)dp_src)[2]);
        mmio_region_write32(aes, AES_DATA_IN_3_REG_OFFSET, ((uint32_t*)dp_src)[3]);

        while(!mmio_region_get_bit32(aes, AES_STATUS_REG_OFFSET, AES_STATUS_OUTPUT_VALID_BIT));
        ((uint32_t*)(dp_dst))[0] = mmio_region_read32(aes, AES_DATA_OUT_0_REG_OFFSET);
        ((uint32_t*)(dp_dst))[1] = mmio_region_read32(aes, AES_DATA_OUT_1_REG_OFFSET);
        ((uint32_t*)(dp_dst))[2] = mmio_region_read32(aes, AES_DATA_OUT_2_REG_OFFSET);
        ((uint32_t*)(dp_dst))[3] = mmio_region_read32(aes, AES_DATA_OUT_3_REG_OFFSET);

        if (n_bytes % TITANSSL_SCRATCHPAD_SIZE == 0 && 
            n_bytes/TITANSSL_SCRATCHPAD_SIZE >= 1 && n_bytes/TITANSSL_SCRATCHPAD_SIZE < ths) {
#if CVA6_STATUS < 2
            if (n_bytes/TITANSSL_SCRATCHPAD_SIZE != 1) _aes_wait_rtw(titanssl_mbox);
            memcpy(titanssl_scratch->page, titanssl_dst.page, TITANSSL_SCRATCHPAD_SIZE);
            _aes_set_rtw(titanssl_mbox);
#endif
            dp_dst = titanssl_dst.page;
        }else
            dp_dst += 16;
        n_bytes += 16;

        if (n_bytes % TITANSSL_PAGE_SIZE == 0 && 
            n_bytes/TITANSSL_PAGE_SIZE >= 1 && n_bytes/TITANSSL_PAGE_SIZE < thp)
            dp_src = titanssl_mbox->p_index[n_bytes/TITANSSL_PAGE_SIZE].page;
        else if (n_bytes != titanssl_mbox->in_size)
            dp_src += 16 * sizeof(uint32_t);
    
    }
    while(!mmio_region_get_bit32(aes, AES_STATUS_REG_OFFSET, AES_STATUS_OUTPUT_VALID_BIT));
    ((uint32_t*)(dp_dst))[0] = mmio_region_read32(aes, AES_DATA_OUT_0_REG_OFFSET);
    ((uint32_t*)(dp_dst))[1] = mmio_region_read32(aes, AES_DATA_OUT_1_REG_OFFSET);
    ((uint32_t*)(dp_dst))[2] = mmio_region_read32(aes, AES_DATA_OUT_2_REG_OFFSET);
    ((uint32_t*)(dp_dst))[3] = mmio_region_read32(aes, AES_DATA_OUT_3_REG_OFFSET);

    memcpy(titanssl_scratch->page, titanssl_dst.page,
    TITANSSL_SCRATCHPAD_SIZE - titanssl_mbox->in_size + (thp-1)*TITANSSL_PAGE_SIZE);

    // Reset operation mode, key, iv, and data registers
    while(!mmio_region_get_bit32(aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
    reg = bitfield_bit32_write(0, AES_CTRL_SHADOWED_MANUAL_OPERATION_BIT, true);
    mmio_region_write32(aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
    mmio_region_write32(aes, AES_CTRL_SHADOWED_REG_OFFSET, reg);
    reg = bitfield_bit32_write(0, AES_TRIGGER_KEY_IV_DATA_IN_CLEAR_BIT, true);
    reg = bitfield_bit32_write(reg, AES_TRIGGER_DATA_OUT_CLEAR_BIT, true);
    mmio_region_write32(aes, AES_TRIGGER_REG_OFFSET, reg);
    while (!mmio_region_get_bit32(aes, AES_STATUS_REG_OFFSET, AES_STATUS_IDLE_BIT));
}