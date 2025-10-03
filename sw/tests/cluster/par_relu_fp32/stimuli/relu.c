#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <limits.h> /* for CHAR_BIT */
#include <math.h>
#include "pulp.h"
#include "config.h"

void PULP_relu_fp32_fp32(float *input, float *output, uint32_t size) {

  int8_t core_id = pi_core_id();
  int8_t log2Core = log2(NUM_CORES);

  int32_t chunk = (size >> log2Core) + ((size & (NUM_CORES - 1)) != 0);
  int32_t start = MIN(chunk * core_id, size);
  int32_t end = MIN(start + chunk, size);
  int32_t local_size = end - start;

  float *local_input = input + start;
  float *local_output = output + start;

  for (int32_t i = 0; i < local_size; i++) {
    local_output[i] = MAX(local_input[i], 0.0f);
  }
}
