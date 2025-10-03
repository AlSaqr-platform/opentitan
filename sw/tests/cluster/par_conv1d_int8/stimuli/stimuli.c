#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include "pulp.h"
#include "config.h"
#include "data.h"       // <-- your new 1D data header
#include "pmsis.h"
#include "pulp_nn_utils.h"
#include "pulp_nn_kernels.h"
#include "implem.h"

#define DMA_CL_WRITE(value, offset) pulp_write32(DMA_DEMUX_ADDR + (offset), (value))
#define DMA_CL_READ(offset) pulp_read32(DMA_DEMUX_ADDR + (offset))
#define FPGA_EMULATION

#ifdef FPGA_EMULATION
  int baud_rate = 9600;
  int test_freq = 25000000;
#else
  int baud_rate = 115200;
  int test_freq = 100000000;
#endif

#define STACK_SIZE 2048

// Allocate buffers aligned
// input: dim_in_x × ch_in
DATA_LOCATION int8_t matA[DIM_IN_X * CH_IN] __attribute__((aligned(4)));
// output: dim_out_x × ch_out
DATA_LOCATION int8_t matC[DIM_OUT_X * CH_OUT] __attribute__((aligned(4)));

// im2col buffer: needs size 2 * NUM_CORES * PACK_INT8_SIZE(ch_in) * dim_kernel_x
#define IM2COL_SIZE (2 * NUM_CORES * PACK_INT8_SIZE(CH_IN) * KERN_X)
DATA_LOCATION int8_t im2col_buf[IM2COL_SIZE] __attribute__((aligned(4)));

#ifdef BATCH_NORM
DATA_LOCATION int32_t kappa[CH_OUT] __attribute__((aligned(4)));
DATA_LOCATION int32_t lambda[CH_OUT] __attribute__((aligned(4)));
#endif

int retval = -1;

void matrix_init(void) {
  // load input data from generated arrays
  for (int i = 0; i < DIM_IN_X * CH_IN; i++) {
    matA[i] = pIn[i];
  }
  // clear output
  for (int i = 0; i < DIM_OUT_X * CH_OUT; i++) {
    matC[i] = 0;
  }
#ifdef BATCH_NORM
  // load kappa/lambda if present in data_conv1d.h
  for (int i = 0; i < CH_OUT; i++) {
    kappa[i]  = pKappa[i];
    lambda[i] = pLambda[i];
  }
#endif
}

int check_result(int8_t *result) {
  int err = 0;
  for (int i = 0; i < DIM_OUT_X * CH_OUT; i++) {
    int diff = abs((int)result[i] - (int)ref[i]);
    if (diff > THR) err++;
  }
  return err;
}

void main_fn(int *retval) {
  if (core_id() == 0) {
    matrix_init();
  }
#ifndef FPGA_EMULATION
  synch_barrier();
#endif

  // call the 1D convolution kernel
  xpulp_nn_conv1d_i8_i8_i8(
    matA,              // pIn
    im2col_buf,        // pIm2ColBuffer
    pBias,             // pBias
    matC,              // pOut
    pWeight,           // pWeight
#ifdef BATCH_NORM
    kappa,             // pKappa
    lambda,            // pLambda
#else
    NULL,              // pKappa
    NULL,              // pLambda
#endif
    OUT_MULT,          // out_mult
    OUT_SHIFT,         // out_shift
    DIM_IN_X,          // dim_in_x
    CH_IN,             // ch_in
    DIM_OUT_X,         // dim_out_x
    CH_OUT,            // ch_out
    KERN_X,            // dim_kernel_x
    PAD_LEFT,          // padding_x_left
    PAD_RIGHT,         // padding_x_right
    STRIDE,          // stride_x
    DILATION,        // dilation_x
    FLAG_RELU,         // flag_relu
    FLAG_BATCH_NORM    // flag_batch_norm
  );

#ifdef CHECK
  if (core_id() == 0) {
    *retval = check_result(matC);
  }
#endif
}

int main() {
  synch_barrier();
  main_fn(&retval);
  synch_barrier();
  if (core_id() == 0) {
    // write back result for the testbench
    pulp_write32(0x10404008, retval);
    pulp_write32(0x10404020, 0x1);
  }
  while (1) __asm__ volatile("wfi;");
  return 0;
}
