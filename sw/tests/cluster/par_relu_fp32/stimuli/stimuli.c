#include <stdio.h>
#include <stdlib.h>
#include "pulp.h"
#include "config.h"
#include <stdio.h>
#include <stdint.h>
#include <limits.h> /* for CHAR_BIT */
#include <math.h>
#include "data.h"

#define FPGA_EMULATION

#ifdef FPGA_EMULATION
  int baud_rate = 9600;
  int test_freq = 25000000;
#else
  int baud_rate = 115200;
  int test_freq = 100000000;
#endif

#define STACK_SIZE 2048
DATA_LOCATION MA_TYPE matA[M*N] __attribute__ ((aligned (4)));
DATA_LOCATION MB_TYPE matB[M*N] __attribute__ ((aligned (4)));
DATA_LOCATION OUT_TYPE matC[M*N] __attribute__ ((aligned (4)));

void main_fn(int*);

int retval = -1;

int main () {

  synch_barrier();

  //////////
  // TEST //
  //////////

  main_fn(&retval);

  synch_barrier();

  if(core_id() == 0){
    // Write msg to mailbox
    pulp_write32(0x10404008, retval);
    pulp_write32(0x10404020, 0x1);
  }

  while (1) {
          __asm__ volatile("wfi;");
  }

  return 0;
}

void __attribute__ ((noinline)) matrix_init(MA_TYPE * __restrict__ A, MB_TYPE * __restrict__ B, OUT_TYPE * __restrict__ C) {
  for (int i = 0; i < M; i++)
    for (int j = 0; j < N; j++)
      A[i*N+j] = A_mat[i*N+j];

  for (int i = 0; i < M; i++)
    for (int j = 0; j < N; j++)
      B[i*N+j] = B_mat[i*N+j];

  for (int i = 0; i < M; i++)
    for (int j = 0; j < N; j++)
      C[i*N+j] = 0;
}

int __attribute ((noinline)) check_result(OUT_TYPE * __restrict__ result) {
    float diff;
    int err = 0;

    for (int i = 0; i < (N*M); i++) {
      diff = fabs(result[i] - ref[i]);
      if(diff > THR) {
        err++;
      }
    }
    return err;
}

void main_fn(int *retval){

  if (get_core_id() == 0)
    matrix_init(matA, matB, matC);

  #ifndef FABRIC
  synch_barrier();
  #endif

  RELU_relu_fp32_fp32(matA, matB, matC, N*M);

  #ifdef CHECK
  if (get_core_id() == 0)
    *retval = check_result(matC);
  #endif
}
