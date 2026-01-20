#include "sw/device/silicon_creator/rom/uart.h"
#include "sw/device/silicon_creator/rom/string_lib.h"
#include "sw/tests/common/utils.h"

#define IDMA_BASE      0xfef00000
#define TCDM_BASE      0xfff00000
#define L2_BASE        0xA0000000

#define SIZE           1024
#define OFFSET         32

#define IDMA_SRC_ADDR_OFFSET         0x000000d8
#define IDMA_DST_ADDR_OFFSET         0x000000d0
#define IDMA_LENGTH_OFFSET           0x000000e0
#define IDMA_NEXT_ID_OFFSET          0x0000000c
#define IDMA_DONE_ID_OFFSET          0x00000014
#define IDMA_REPS_2                  0x000000f8
#define IDMA_REPS_3                  0x00000110
#define IDMA_CONF                    0x00000000
#define EOC                          0xc11c0018


void wait_for_idma_eot(int next_id){
    volatile uint32_t *ptr;
    ptr = (uint32_t *) (IDMA_BASE + IDMA_DONE_ID_OFFSET) ;
    while(*ptr!=next_id)
      asm volatile("nop");
}

int issue_idma_transaction(uint32_t src_addr, uint32_t dst_addr, uint32_t num_bytes){
    volatile uint32_t * ptr;
    ptr = (uint32_t *) (IDMA_BASE + IDMA_SRC_ADDR_OFFSET);
    *ptr = src_addr;
    ptr = (uint32_t *) (IDMA_BASE + IDMA_DST_ADDR_OFFSET);
    *ptr = dst_addr;
    ptr = (uint32_t *) (IDMA_BASE + IDMA_LENGTH_OFFSET);
    *ptr = num_bytes;
    ptr = (uint32_t *) (IDMA_BASE + IDMA_CONF);
    *ptr = 0x3<<10;
    ptr = (uint32_t *) (IDMA_BASE + IDMA_REPS_2);
    *ptr = 0x00000001;
    ptr = (uint32_t *) (IDMA_BASE + IDMA_NEXT_ID_OFFSET);
    return *ptr;
}

void mem_init(uint32_t base, uint32_t size, bool mod) {
    int* ptr = (int*) base;
    size_t num_words = size / sizeof(int);
    for (size_t i = 0; i < num_words; ++i) {
        ptr[i] = mod ? i : 0;
    }
}

bool compare_mem(uint32_t b1, uint32_t b2, uint32_t size) {
  uint32_t* ptr1 = (uint32_t*) b1;
  uint32_t* ptr2 = (uint32_t*) b2;
  int err=0;
  for (uint32_t i = 0; i < size/4; ++i) {
    if(ptr1[i] != ptr2[i]){
      err++;
    }
  }
  return err;
}

bool dma_test(uint32_t b1, uint32_t b2, uint32_t size) {
  int next_id;
  mem_init(b1, size, 1);
  mem_init(b2, size, 0);
  next_id = issue_idma_transaction(b1, b2, size);
  wait_for_idma_eot(next_id);
  return compare_mem(b1, b2, size);
}

int main(int argc, char **argv) {
  bool b=0;

  b = b || dma_test(L2_BASE, TCDM_BASE, SIZE);

  return b;
}
