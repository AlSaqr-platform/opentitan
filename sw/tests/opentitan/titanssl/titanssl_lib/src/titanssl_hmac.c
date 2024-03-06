// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/base/bitfield.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/silicon_creator/rom/uart.h"
#include "sw/device/silicon_creator/rom/string_lib.h"

#include "hmac_regs.h"  // Generated.

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

#include "sw/tests/opentitan/titanssl/titanssl_lib/headers/titanssl_hmac.h"

static titanssl_batch_t hmac_key;

void hmac_run(titanssl_mbox_t* titanssl_mbox, titanssl_batch_t* titanssl_scratch) {    
    _hmac_key_init();
    utils_entropy_init();
    _hmac_run(titanssl_mbox, titanssl_scratch);
    _hmac_check(titanssl_scratch);
}

void _hmac_key_init() {
    hmac_key.page = (uint8_t*)TITANSSL_KEY_BASE;
    for (size_t j=0; j<TITANSSL_KEY_SIZE; j++) hmac_key.page[j] = 0x00;
}

void _hmac_check(titanssl_batch_t* titanssl_scratch) {
#if DEB
    for (int i=0; i<TITANSSL_OUTPUT_SIZE/4; i++) {
        printf("[IBEX HMAC] 0x%08x vs 0x%08x\r\n", ExpectedHmacDigest[i],
            ((uint32_t*)(titanssl_scratch->page))[i]);
        uart_wait_tx_done();
    }
#endif
}

void _hmac_run(titanssl_mbox_t* titanssl_mbox, titanssl_batch_t* titanssl_scratch) {    
    mmio_region_t hmac;
    uint32_t reg;
    const uint8_t *dp;

    // Get the HMAC IP base address
    hmac = mmio_region_from_addr(TOP_EARLGREY_HMAC_BASE_ADDR);

    // Initialize HMAC IP with digest and message in little-endian mode
    reg = mmio_region_read32(hmac, HMAC_CFG_REG_OFFSET);
    if(titanssl_mbox->code == SHA256_ENCRYPT) {    
        reg = bitfield_bit32_write(reg, HMAC_CFG_ENDIAN_SWAP_BIT, false);
        reg = bitfield_bit32_write(reg, HMAC_CFG_DIGEST_SWAP_BIT, false);
        reg = bitfield_bit32_write(reg, HMAC_CFG_SHA_EN_BIT, true);
        reg = bitfield_bit32_write(reg, HMAC_CFG_HMAC_EN_BIT, false);
        mmio_region_write32(hmac, HMAC_CFG_REG_OFFSET, reg);
    } else {
        mmio_region_write32(hmac, HMAC_KEY_0_REG_OFFSET, ((uint32_t*)(hmac_key.page))[0]);
        mmio_region_write32(hmac, HMAC_KEY_1_REG_OFFSET, ((uint32_t*)(hmac_key.page))[1]);
        mmio_region_write32(hmac, HMAC_KEY_2_REG_OFFSET, ((uint32_t*)(hmac_key.page))[2]);
        mmio_region_write32(hmac, HMAC_KEY_3_REG_OFFSET, ((uint32_t*)(hmac_key.page))[3]);
        mmio_region_write32(hmac, HMAC_KEY_4_REG_OFFSET, ((uint32_t*)(hmac_key.page))[4]);
        mmio_region_write32(hmac, HMAC_KEY_5_REG_OFFSET, ((uint32_t*)(hmac_key.page))[5]);
        mmio_region_write32(hmac, HMAC_KEY_6_REG_OFFSET, ((uint32_t*)(hmac_key.page))[6]);
        mmio_region_write32(hmac, HMAC_KEY_7_REG_OFFSET, ((uint32_t*)(hmac_key.page))[7]);
        reg = bitfield_bit32_write(reg, HMAC_CFG_ENDIAN_SWAP_BIT, false);
        reg = bitfield_bit32_write(reg, HMAC_CFG_DIGEST_SWAP_BIT, false);
        reg = bitfield_bit32_write(reg, HMAC_CFG_SHA_EN_BIT, true);
        reg = bitfield_bit32_write(reg, HMAC_CFG_HMAC_EN_BIT, true);
        mmio_region_write32(hmac, HMAC_CFG_REG_OFFSET, reg);
    }

    // Start operations
    mmio_region_nonatomic_set_bit32(hmac, HMAC_CMD_REG_OFFSET, HMAC_CMD_HASH_START_BIT);

    // Compute SHA256, assuming the payload address is 4-bytes aligned
    uint64_t n_bytes = 0;
    uint32_t th = (titanssl_mbox->in_size - TITANSSL_PAGE_SIZE +1) / TITANSSL_PAGE_SIZE;
    dp = titanssl_mbox->p_index[0].page;
    while (n_bytes < titanssl_mbox->in_size) 
    {
        uint32_t nw, nb;
        
        // Wait for the accelerator fifo to be empty
        while(!mmio_region_get_bit32(hmac, HMAC_STATUS_REG_OFFSET, HMAC_STATUS_FIFO_EMPTY_BIT));

        // Process next 512 bits block
        if(titanssl_mbox->in_size - n_bytes >= 16 * sizeof(uint32_t))
        {
            // Push data into the FIFO
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[0]);
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[1]);
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[2]);
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[3]);
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[4]);
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[5]);
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[6]);
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[7]);
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[8]);
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[9]);
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[10]);
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[11]);
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[12]);
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[13]);
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[14]);
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[15]);
            n_bytes += 16 * sizeof(uint32_t);
            if (n_bytes % TITANSSL_PAGE_SIZE == 0 && 
                n_bytes/TITANSSL_PAGE_SIZE >= 1 && n_bytes/TITANSSL_PAGE_SIZE < th)
                dp = titanssl_mbox->p_index[n_bytes/TITANSSL_PAGE_SIZE].page;
            else if (n_bytes != titanssl_mbox->in_size)
                dp += 16 * sizeof(uint32_t);
            
        } else {
            n_bytes += (titanssl_mbox->in_size - n_bytes);
            nw = (titanssl_mbox->in_size - n_bytes) >> 2;
            nb = (titanssl_mbox->in_size - n_bytes) & 0x3;

            // Push data into the FIFO
            for (size_t i=0; i<nw; i++)
            {
                mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, *(uint32_t*)dp);
                dp += sizeof(uint32_t);
            }
            for (size_t i=0; i<nb; i++)
            {
                mmio_region_write8(hmac, HMAC_MSG_FIFO_REG_OFFSET, *dp);
                dp += 1;
            }
        }
    }

    mmio_region_nonatomic_set_bit32(hmac, HMAC_CMD_REG_OFFSET, HMAC_CMD_HASH_PROCESS_BIT);

    // Wait for SHA-256 completion
    while (!mmio_region_get_bit32(hmac, HMAC_INTR_STATE_REG_OFFSET, HMAC_INTR_STATE_HMAC_DONE_BIT));
    mmio_region_nonatomic_set_bit32(hmac, HMAC_INTR_STATE_REG_OFFSET, HMAC_INTR_STATE_HMAC_DONE_BIT);

    // Copy the digest
    ((uint32_t*)(titanssl_scratch->page))[0] = mmio_region_read32(hmac, HMAC_DIGEST_0_REG_OFFSET);
    ((uint32_t*)(titanssl_scratch->page))[1] = mmio_region_read32(hmac, HMAC_DIGEST_1_REG_OFFSET);
    ((uint32_t*)(titanssl_scratch->page))[2] = mmio_region_read32(hmac, HMAC_DIGEST_2_REG_OFFSET);
    ((uint32_t*)(titanssl_scratch->page))[3] = mmio_region_read32(hmac, HMAC_DIGEST_3_REG_OFFSET);
    ((uint32_t*)(titanssl_scratch->page))[4] = mmio_region_read32(hmac, HMAC_DIGEST_4_REG_OFFSET);
    ((uint32_t*)(titanssl_scratch->page))[5] = mmio_region_read32(hmac, HMAC_DIGEST_5_REG_OFFSET);
    ((uint32_t*)(titanssl_scratch->page))[6] = mmio_region_read32(hmac, HMAC_DIGEST_6_REG_OFFSET);
    ((uint32_t*)(titanssl_scratch->page))[7] = mmio_region_read32(hmac, HMAC_DIGEST_7_REG_OFFSET);

    // Disable HMAC IP
    reg = mmio_region_read32(hmac, HMAC_CFG_REG_OFFSET);
    reg = bitfield_bit32_write(reg, HMAC_CFG_SHA_EN_BIT, false);
    reg = bitfield_bit32_write(reg, HMAC_CFG_HMAC_EN_BIT, false);
    mmio_region_write32(hmac, HMAC_CFG_REG_OFFSET, reg);
}