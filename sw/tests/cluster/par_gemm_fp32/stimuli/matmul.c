#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <limits.h> /* for CHAR_BIT */
#include <math.h>
#include "pulp.h"
#include "config.h"

void PULP_Gemm_fp32_fp32_fp32_fp32(const float *__restrict__ pSrcA,
                                   const float *__restrict__ pSrcB,
                                   const float *__restrict__ pDstC,
                                   float *__restrict__ pDstY, int M_dim,
                                   int N_dim, int O_dim, int transA,
                                   int transB) {

  int8_t cid = core_id();
  int8_t log2Core = log2(NUM_CORES);

  uint32_t M_chunk = (M_dim >> log2Core) + ((M_dim & (NUM_CORES - 1)) != 0);
  uint32_t M_start = MIN(cid * M_chunk, M_dim);
  uint32_t M_end = MIN(M_start + M_chunk, M_dim);
  uint32_t M_size = M_end - M_start;

  if (M_size == 0) {
    return;
  }

  for (uint32_t i = M_start; i < M_end; ++i) {
    for (uint32_t j = 0; j < O_dim; ++j) {
      float sum = 0.0f;
      for (uint32_t k = 0; k < N_dim; ++k) {
        uint32_t a_idx = transA ? (k * M_dim + i) : (i * N_dim + k);
        uint32_t b_idx = transB ? (j * N_dim + k) : (k * O_dim + j);
        sum += pSrcA[a_idx] * pSrcB[b_idx];
      }
      pDstY[i * O_dim + j] = sum + pDstC[i * O_dim + j];
    }
  }
}
