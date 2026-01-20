#include "sw/device/silicon_creator/rom/uart.h"
#include "sw/device/silicon_creator/rom/string_lib.h"
#include "sw/tests/common/utils.h"

#define IDMA_BASE      0xfef00000
#define TCDM_BASE      0xfff00000
#define L2_BASE        0xa0000000

#define SIZE           512*1024

#define IDMA_SRC_ADDR_OFFSET         0x000000d8
#define IDMA_DST_ADDR_OFFSET         0x000000d0
#define IDMA_LENGTH_OFFSET           0x000000e0
#define IDMA_NEXT_ID_OFFSET          0x0000000c
#define IDMA_DONE_ID_OFFSET          0x00000014
#define IDMA_REPS_2                  0x000000f8
#define IDMA_REPS_3                  0x00000110
#define IDMA_CONF                    0x00000000
#define EOC                          0xc11c0018

volatile int * p_reg1;
int err;

void mem_init(uint32_t base, uint32_t size, bool mod) {
    int* ptr = (int*) base;
    size_t num_words = size / sizeof(int);
    for (size_t i = 0; i < num_words; i++) {
        ptr[i] = mod ? i : 0;
    }
}

int main() {

  mem_init(L2_BASE, SIZE, 1);

  // Read L2
  p_reg1 = (int *) L2_BASE;
  err = 0;
  for(int i=0;i<SIZE/4;i++){
    p_reg1 = (int *)(L2_BASE + i*4);
    if( *p_reg1 != i){
      err++;
    }
  }

  return err;
}
