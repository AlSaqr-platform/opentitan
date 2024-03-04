// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/base/bitfield.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/silicon_creator/rom/uart.h"
#include "sw/device/silicon_creator/rom/string_lib.h"

#include "hmac_regs.h"  // Generated.


#define TARGET_SYNTHESIS

#define IDMA_BASE 		 0xfef00000
#define TCDM_BASE      0xfff01000
#define L2_BASE        0x1C001000
#define L3_BASE        0x80000000

#define IDMA_SRC_ADDR_OFFSET         0x00
#define IDMA_DST_ADDR_OFFSET         0x04
#define IDMA_LENGTH_OFFSET           0x08
#define IDMA_NEXT_ID_OFFSET          0x20
#define IDMA_DONE_ID_OFFSET          0x24

typedef struct
{
    uint8_t *data;
    size_t n;
} titanssl_buffer_t;


int next_id, new_next_id;

static titanssl_buffer_t buffer_payload_idma;
static titanssl_buffer_t buffer_digest_idma;
static titanssl_buffer_t buffer_payload;
static titanssl_buffer_t buffer_digest;
static titanssl_buffer_t buffer_key;


/* ============================================================================
 * Benchmark setup
 * ========================================================================= */

// Configure debug mode.
#define TITANSSL_CFG_DEBUG     0
#define TITANSSL_CFG_MEM_L3    1
#define TITANSSL_CFG_MEM_L1    0
#ifndef TITANSSL_CFG_PAYLOAD
  #define TITANSSL_CFG_PAYLOAD 1024
#endif

#define TITANSSL_CFG_OP_SHA256 1
#define TITANSSL_CFG_OP_HMAC   0

/* ============================================================================
 * Benchmark automatic configuration
 * ========================================================================= */

#if TITANSSL_CFG_MEM_L3
#define TITANSSL_ADDR_PAYLOAD_IDMA  0xfff00000
#define TITANSSL_ADDR_DIGEST_IDMA   0xfff04000
#define TITANSSL_ADDR_PAYLOAD 0x80720000
#define TITANSSL_ADDR_DIGEST  0x80740000
#define TITANSSL_ADDR_KEY     0xe0006000
#elif TITANSSL_CFG_MEM_L1
#define TITANSSL_ADDR_PAYLOAD 0xe0002000
#define TITANSSL_ADDR_DIGEST  0xe0004000
#define TITANSSL_ADDR_KEY     0xe0006000
#else
#error "Wrong benchmark memory configuration"
#endif

#define TITANSSL_SIZE_PAYLOAD TITANSSL_CFG_PAYLOAD
#define TITANSSL_SIZE_DIGEST  32
#define TITANSSL_SIZE_KEY     32

/* ============================================================================
 * Benchmark implementation
 * ========================================================================= */

void wait_for_idma_eot(int next_id){
    volatile uint32_t *ptr;
    ptr = (uint32_t *) 0xfef00024 ;
    while(*ptr!=next_id)  //IDMA_WAIT
      asm volatile("nop");  //IDMA_WAIT
}

int issue_idma_transaction(uint32_t src_addr, uint32_t dst_addr, uint32_t num_bytes){
    volatile uint32_t * ptr32;
    uint8_t buff = 0;
    mmio_region_t aes; //CONF
    ptr32 = (uint32_t *) (IDMA_BASE + IDMA_SRC_ADDR_OFFSET);
    *ptr32 = src_addr; // IDMA
    ptr32 = (uint32_t *) (IDMA_BASE + IDMA_DST_ADDR_OFFSET);
    *ptr32 = dst_addr; // IDMA
    ptr32 = (uint32_t *) (IDMA_BASE + IDMA_LENGTH_OFFSET);
    *ptr32 = num_bytes; // IDMA
    ptr32 = (uint32_t *) (IDMA_BASE + IDMA_NEXT_ID_OFFSET);
    buff = *ptr32; // IDMA
    return *ptr32; // IDMA
}
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

void initialize_memory()
{

#if TITANSSL_CFG_MEM_L3
    buffer_payload_idma.data = (uint8_t*)TITANSSL_ADDR_PAYLOAD_IDMA;
    buffer_payload_idma.n = TITANSSL_CFG_PAYLOAD;

    buffer_digest_idma.data = (uint8_t*)TITANSSL_ADDR_DIGEST_IDMA;
    buffer_digest_idma.n = TITANSSL_CFG_PAYLOAD;
#endif

    buffer_payload.data = (uint8_t*)TITANSSL_ADDR_PAYLOAD;
    buffer_payload.n = TITANSSL_SIZE_PAYLOAD;
    //for (size_t i=0; i<TITANSSL_SIZE_PAYLOAD; i++) buffer_payload.data[i] = 0x0;

    buffer_digest.data = (uint8_t*)TITANSSL_ADDR_DIGEST;
    buffer_digest.n = TITANSSL_SIZE_DIGEST;
    //for (size_t i=0; i<TITANSSL_SIZE_DIGEST; i++) buffer_digest.data[i] = 0x0;

    buffer_key.data = (uint8_t*)TITANSSL_ADDR_KEY;
    buffer_key.n = TITANSSL_SIZE_KEY;
    for (size_t i=0; i<TITANSSL_SIZE_KEY; i++) buffer_key.data[i] = 0x0;
}

void titanssl_benchmark_hmac(
        titanssl_buffer_t *const payload_idma,
        titanssl_buffer_t *const digest_idma,
        titanssl_buffer_t *const payload,
        titanssl_buffer_t *const digest,
        titanssl_buffer_t *const key)
{ //CONF
    mmio_region_t hmac; //CONF
    uint32_t reg; //CONF
    const uint8_t *dp; //CONF

#if TITANSSL_CFG_MEM_L3
    uint32_t src_addr_int = (uint32_t)(uintptr_t)payload->data;//CONF
    uint32_t dst_addr_int = (uint32_t)(uintptr_t)payload_idma->data;//CONF
    next_id = issue_idma_transaction(src_addr_int, dst_addr_int, payload->n);//CONF
#endif

    // Get the HMAC IP base address
    hmac = mmio_region_from_addr(TOP_EARLGREY_HMAC_BASE_ADDR); //CONF

    // Initialize HMAC IP with digest and message in little-endian mode
    reg = mmio_region_read32(hmac, HMAC_CFG_REG_OFFSET); //CONF
#if TITANSSL_CFG_OP_SHA256
    reg = bitfield_bit32_write(reg, HMAC_CFG_ENDIAN_SWAP_BIT, false); //CONF
    reg = bitfield_bit32_write(reg, HMAC_CFG_DIGEST_SWAP_BIT, false); //CONF
    reg = bitfield_bit32_write(reg, HMAC_CFG_SHA_EN_BIT, true); //CONF
    reg = bitfield_bit32_write(reg, HMAC_CFG_HMAC_EN_BIT, false); //CONF
    mmio_region_write32(hmac, HMAC_CFG_REG_OFFSET, reg); //CONF
#elif TITANSSL_CFG_OP_HMAC
    mmio_region_write32(hmac, HMAC_KEY_0_REG_OFFSET, ((uint32_t*)key->data)[0]); //CONF
    mmio_region_write32(hmac, HMAC_KEY_1_REG_OFFSET, ((uint32_t*)key->data)[1]); //CONF
    mmio_region_write32(hmac, HMAC_KEY_2_REG_OFFSET, ((uint32_t*)key->data)[2]); //CONF
    mmio_region_write32(hmac, HMAC_KEY_3_REG_OFFSET, ((uint32_t*)key->data)[3]); //CONF
    mmio_region_write32(hmac, HMAC_KEY_4_REG_OFFSET, ((uint32_t*)key->data)[4]); //CONF
    mmio_region_write32(hmac, HMAC_KEY_5_REG_OFFSET, ((uint32_t*)key->data)[5]); //CONF
    mmio_region_write32(hmac, HMAC_KEY_6_REG_OFFSET, ((uint32_t*)key->data)[6]); //CONF
    mmio_region_write32(hmac, HMAC_KEY_7_REG_OFFSET, ((uint32_t*)key->data)[7]); //CONF
    reg = bitfield_bit32_write(reg, HMAC_CFG_ENDIAN_SWAP_BIT, false); //CONF
    reg = bitfield_bit32_write(reg, HMAC_CFG_DIGEST_SWAP_BIT, false); //CONF
    reg = bitfield_bit32_write(reg, HMAC_CFG_SHA_EN_BIT, true); //CONF
    reg = bitfield_bit32_write(reg, HMAC_CFG_HMAC_EN_BIT, true); //CONF
    mmio_region_write32(hmac, HMAC_CFG_REG_OFFSET, reg); //CONF
#endif

#if TITANSSL_CFG_MEM_L3
    wait_for_idma_eot(next_id); //CONF
#endif

    // Start operations
    mmio_region_nonatomic_set_bit32(hmac, HMAC_CMD_REG_OFFSET, HMAC_CMD_HASH_START_BIT); //CONF

    // Compute SHA256, assuming the payload address is 4-bytes aligned
#if TITANSSL_CFG_MEM_L3
    dp = payload_idma->data; //DIGEST
    while (dp < payload_idma->data + payload->n)  //DIGEST
#elif TITANSSL_CFG_MEM_L1
    dp = payload->data; //DIGEST
    while (dp < payload->data + payload->n)  //DIGEST
#endif
    {
        uint32_t n_bytes; //DIGEST
        uint32_t n_words; //DIGEST

        // Wait for the accelerator fifo to be empty
        while(!mmio_region_get_bit32(hmac, HMAC_STATUS_REG_OFFSET, HMAC_STATUS_FIFO_EMPTY_BIT)); //DIGEST

        // Process next 512 bits block
        n_bytes = 16 * sizeof(uint32_t); //DIGEST
        if (payload_idma->data + payload->n - dp > n_bytes) //DIGEST
        {
            // Push data into the FIFO
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[0]); //DIGEST
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[1]); //DIGEST
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[2]); //DIGEST
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[3]); //DIGEST
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[4]); //DIGEST
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[5]); //DIGEST
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[6]); //DIGEST
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[7]); //DIGEST
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[8]); //DIGEST
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[9]); //DIGEST
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[10]); //DIGEST
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[11]); //DIGEST
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[12]); //DIGEST
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[13]); //DIGEST
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[14]); //DIGEST
            mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, ((uint32_t*)dp)[15]); //DIGEST
            dp += 16 * sizeof(uint32_t); //DIGEST
        }
        else
        {
        #if TITANSSL_CFG_MEM_L3
          n_bytes = payload_idma->data + payload_idma->n - dp; //DIGEST
        #elif TITANSSL_CFG_MEM_L1
          n_bytes = payload->data + payload->n - dp; //DIGEST
        #endif
            n_words = n_bytes >> 2; //DIGEST
            n_bytes = n_bytes & 0x3; //DIGEST

            // Push data into the FIFO
            for (size_t i=0; i<n_words; i++) //DIGEST
            {
                mmio_region_write32(hmac, HMAC_MSG_FIFO_REG_OFFSET, *(uint32_t*)dp); //DIGEST
                dp += sizeof(uint32_t); //DIGEST
            }
            for (size_t i=0; i<n_bytes; i++) //DIGEST
            {
                mmio_region_write8(hmac, HMAC_MSG_FIFO_REG_OFFSET, *dp); //DIGEST
                dp += 1; //DIGEST
            }
        }
    }
    mmio_region_nonatomic_set_bit32(hmac, HMAC_CMD_REG_OFFSET, HMAC_CMD_HASH_PROCESS_BIT);  //FINAL

    // Wait for SHA-256 completion
    while (!mmio_region_get_bit32(hmac, HMAC_INTR_STATE_REG_OFFSET, HMAC_INTR_STATE_HMAC_DONE_BIT));  //FINAL
    mmio_region_nonatomic_set_bit32(hmac, HMAC_INTR_STATE_REG_OFFSET, HMAC_INTR_STATE_HMAC_DONE_BIT);  //FINAL

    // Copy the digest
    ((uint32_t*)(digest->data))[0] = mmio_region_read32(hmac, HMAC_DIGEST_0_REG_OFFSET); //FINAL
    ((uint32_t*)(digest->data))[1] = mmio_region_read32(hmac, HMAC_DIGEST_1_REG_OFFSET); //FINAL
    ((uint32_t*)(digest->data))[2] = mmio_region_read32(hmac, HMAC_DIGEST_2_REG_OFFSET); //FINAL
    ((uint32_t*)(digest->data))[3] = mmio_region_read32(hmac, HMAC_DIGEST_3_REG_OFFSET); //FINAL
    ((uint32_t*)(digest->data))[4] = mmio_region_read32(hmac, HMAC_DIGEST_4_REG_OFFSET); //FINAL
    ((uint32_t*)(digest->data))[5] = mmio_region_read32(hmac, HMAC_DIGEST_5_REG_OFFSET); //FINAL
    ((uint32_t*)(digest->data))[6] = mmio_region_read32(hmac, HMAC_DIGEST_6_REG_OFFSET); //FINAL
    ((uint32_t*)(digest->data))[7] = mmio_region_read32(hmac, HMAC_DIGEST_7_REG_OFFSET); //CONF

#if TITANSSL_CFG_MEM_L3
    uint32_t src_addr_int_digest = (uint32_t)(uintptr_t)digest_idma->data; //CONF
    uint32_t dst_addr_int_digest = (uint32_t)(uintptr_t)digest->data; //CONF
    new_next_id = issue_idma_transaction(src_addr_int_digest, dst_addr_int_digest, digest->n);//CONF
#endif
    // Disable HMAC IP
    reg = mmio_region_read32(hmac, HMAC_CFG_REG_OFFSET);//CONF
    reg = bitfield_bit32_write(reg, HMAC_CFG_SHA_EN_BIT, false);//CONF
    reg = bitfield_bit32_write(reg, HMAC_CFG_HMAC_EN_BIT, false);//CONF
    mmio_region_write32(hmac, HMAC_CFG_REG_OFFSET, reg);//CONF
#if TITANSSL_CFG_MEM_L3
    wait_for_idma_eot(new_next_id); //IDMA_WAIT
#endif
}//CONF

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
    initialize_memory();
    titanssl_benchmark_hmac(
        &buffer_payload_idma,
        &buffer_digest_idma,
        &buffer_payload,
        &buffer_digest,
        &buffer_key
    );

#if TITANSSL_CFG_DEBUG
  printf("payload size: %d Bytes\r\n",buffer_payload.n);
  uart_wait_tx_done();
  printf("input: 0x");
  uart_wait_tx_done();
	for (int i=0; i<buffer_payload.n; i++)
	{
		printf("%02x", buffer_payload.data[i]);
        uart_wait_tx_done();
	}
  printf("\r\n");
  uart_wait_tx_done();

  printf("Output: 0x");
	for (int i=0; i<buffer_digest.n; i++)
	{
		printf("%02x", buffer_digest.data[i]);
        uart_wait_tx_done();
	}
  printf("\r\n");
  uart_wait_tx_done();
#endif

	return 0;
}
