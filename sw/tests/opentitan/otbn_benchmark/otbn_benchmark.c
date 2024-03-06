// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/dif/dif_otbn.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/runtime/otbn.h"
#include "sw/device/lib/testing/entropy_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

#include "sw/device/silicon_creator/rom/uart.h"
#include "sw/device/silicon_creator/rom/string_lib.h"
#include "sw/device/lib/dif/dif_uart.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

#define FPGA_EMULATION
#define TITANSSL_TEST_SRC_SIZE  1500 
#define TITANSSL_TEST_DST_SIZE  TITANSSL_TEST_SRC_SIZE
#define TITANSSL_PAGE_SIZE      4096
#define TITANSSL_MBOX_BASE      0x10404000
#define TITANSSL_BATCH_SRC_BASE 0x80700000
#define TITANSSL_BATCH_DST_BASE 0x80701000
#define TITANSSL_DATA_SRC_BASE  0x80720000
#define TITANSSL_DATA_DST_BASE  0x80740000

dif_result_t app;

typedef struct
{
    uint8_t  *data;
    uint32_t n;
} titanssl_batch_t;

typedef struct __attribute__((packed))
{
    titanssl_batch_t *src;
    titanssl_batch_t *dst;
    uint32_t         n_src;
    uint32_t         n_dst;
} titanssl_mbox_t;

static titanssl_mbox_t* const titanssl_mbox = (titanssl_mbox_t*)TITANSSL_MBOX_BASE;

bool initialize_entropy(void) {
  int volatile * edn_enable, * csrng_enable, * entropy_src_enable;
  entropy_src_enable = (int *) 0xc1160024;
  *entropy_src_enable = 0x00909099;
  entropy_src_enable = (int *) 0xc1160020;
  *entropy_src_enable = 0x6;
  csrng_enable = (int *) 0xc1150014;
  *csrng_enable = 0x666;
  edn_enable = (int *) 0xc1170014;
  *edn_enable = 0x9966;
  return true;
}

void initialize_printf(void) {
  int * tmp;
  #ifndef FPGA_EMULATION
    tmp = (int *) 0x1a104004;
    *tmp = 3;
    tmp = (int *) 0x1a10400C;
    *tmp = 3;
    int baud_rate = 115200;
    int test_freq = 100000000;
  #else
    tmp = (int *) 0x1a104074;
    *tmp = 1;
    tmp = (int *) 0x1a10407C;
    *tmp = 1;
    int baud_rate = 115200;
    int test_freq = 40000000;
  #endif
  uart_set_cfg(0,(test_freq/baud_rate)>>4);
}

void initialize_memory()
{
    uint32_t n = 0;
    uint8_t *p = 0;
    // Initialize mailbox content
    titanssl_mbox->src = (titanssl_batch_t*)TITANSSL_BATCH_SRC_BASE;
    titanssl_mbox->dst = (titanssl_batch_t*)TITANSSL_BATCH_DST_BASE;
    titanssl_mbox->n_src = 1 + (TITANSSL_TEST_SRC_SIZE-1) / TITANSSL_PAGE_SIZE;
    titanssl_mbox->n_dst = 1 + (TITANSSL_TEST_DST_SIZE-1) / TITANSSL_PAGE_SIZE;
    // Initialize batch content
    for (size_t i=0; i<titanssl_mbox->n_src; i++)
    {
        n = TITANSSL_TEST_SRC_SIZE - i*TITANSSL_PAGE_SIZE;
        p = (uint8_t*)(TITANSSL_DATA_SRC_BASE + i*TITANSSL_PAGE_SIZE);

        titanssl_mbox->src[i].data = p;
        if (n > TITANSSL_PAGE_SIZE)
        {
            for (size_t j=0; j<TITANSSL_PAGE_SIZE; j++) p[j] = 0x0;
            titanssl_mbox->src[i].n = TITANSSL_PAGE_SIZE;
        } else {
            for (size_t j=0; j<n; j++) p[j] = 0x0;
            titanssl_mbox->src[i].n = n;
        }
    }
    for (size_t i=0; i<titanssl_mbox->n_dst; i++)
    {
        n = TITANSSL_TEST_DST_SIZE - i*TITANSSL_PAGE_SIZE;
        p = (uint8_t*)(TITANSSL_DATA_DST_BASE + i*TITANSSL_PAGE_SIZE);

        titanssl_mbox->dst[i].data = p;
        if (n > TITANSSL_PAGE_SIZE)
        {
            for (size_t j=0; j<TITANSSL_PAGE_SIZE; j++) p[j] = 0x0;
            titanssl_mbox->dst[i].n = TITANSSL_PAGE_SIZE;
        } else {
            for (size_t j=0; j<n; j++) p[j] = 0x0;
            titanssl_mbox->dst[i].n = n;
        }
    }
}

// ---------------------------------- BARRETT384 -----------------------------------

OTBN_DECLARE_APP_SYMBOLS(barrett384);
OTBN_DECLARE_SYMBOL_ADDR(barrett384, inp_a);
OTBN_DECLARE_SYMBOL_ADDR(barrett384, inp_b);
OTBN_DECLARE_SYMBOL_ADDR(barrett384, inp_m);
OTBN_DECLARE_SYMBOL_ADDR(barrett384, inp_u);
OTBN_DECLARE_SYMBOL_ADDR(barrett384, oup_c);

static const otbn_app_t kAppBarrett = OTBN_APP_T_INIT(barrett384);
static const otbn_addr_t kInpA = OTBN_ADDR_T_INIT(barrett384, inp_a);
static const otbn_addr_t kInpB = OTBN_ADDR_T_INIT(barrett384, inp_b);
static const otbn_addr_t kInpM = OTBN_ADDR_T_INIT(barrett384, inp_m);
static const otbn_addr_t kInpU = OTBN_ADDR_T_INIT(barrett384, inp_u);
static const otbn_addr_t kOupC = OTBN_ADDR_T_INIT(barrett384, oup_c);
OTTF_DEFINE_TEST_CONFIG();

/**
 * Run a 384-bit Barrett Multiplication on OTBN and check its result.
 *
 * This test is not aiming to exhaustively test the Barrett multiplication
 * itself, but test the interaction between device software and OTBN. As such,
 * only trivial parameters are used.
 *
 * The code executed on OTBN can be found in sw/otbn/code-snippets/barrett384.s.
 * The entry point wrap_barrett384() is called according to the calling
 * convention described in the OTBN assembly code file.
 */
static void test_barrett384(otbn_t *otbn_ctx) {
  enum { kDataSizeBytes = 48 };

  otbn_load_app(otbn_ctx, kAppBarrett);

  // a, first operand
  static const uint8_t a[kDataSizeBytes] = {10};

  // b, second operand
  static uint8_t b[kDataSizeBytes] = {20};

  // m, modulus, max. length 384 bit with 2^384 > m > 2^383
  // We choose the modulus of P-384: m = 2**384 - 2**128 - 2**96 + 2**32 - 1
  static const uint8_t m[kDataSizeBytes] = {
      0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
      0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
      0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xff,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff};

  // u, pre-computed Barrett constant (without u[384]/MSb of u which is always 1
  // for the allowed range but has to be set to 0 here).
  // u has to be pre-calculated as u = floor(2^768/m).
  static const uint8_t u[kDataSizeBytes] = {
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,
      0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x01};

  // c, result, max. length 384 bit.
  uint8_t c[kDataSizeBytes] = {0};

  // c = (a * b) % m = (10 * 20) % m = 200
  static const uint8_t c_expected[kDataSizeBytes] = {200};

  otbn_copy_data_to_otbn(otbn_ctx, sizeof(a), &a, kInpA);
  otbn_copy_data_to_otbn(otbn_ctx, sizeof(b), &b, kInpB);
  otbn_copy_data_to_otbn(otbn_ctx, sizeof(m), &m, kInpM);
  otbn_copy_data_to_otbn(otbn_ctx, sizeof(u), &u, kInpU);

  printf("AAA\r\n");

  // CHECK(dif_otbn_set_ctrl_software_errs_fatal(&otbn_ctx->dif, true) == kDifOk);
  printf("BBB\r\n");
  otbn_execute(otbn_ctx);
  printf("CCC\r\n");
  // CHECK(dif_otbn_set_ctrl_software_errs_fatal(&otbn_ctx->dif, false) ==
  //      kDifUnavailable);
  printf("DDD\r\n");
  otbn_busy_wait_for_done(otbn_ctx);
  printf("EEE\r\n");

  // Reading back result (c).
  otbn_copy_data_from_otbn(otbn_ctx, sizeof(c), kOupC, &c);

  for (int i = 0; i < sizeof(c); ++i)
    printf("result c at byte %d: 0x%x (actual) vs 0x%x (expected)\r\n", i, c[i], c_expected[i]);

  check_otbn_insn_cnt(otbn_ctx, 171);
}

// ------------------------------------ MAIN -------------------------------------

int main(int argc, char **argv) {

  initialize_printf();
  initialize_memory();

  titanssl_batch_t* const src = titanssl_mbox->src;
  titanssl_batch_t* const dst = titanssl_mbox->dst;
  const uint32_t n_src = titanssl_mbox->n_src;
  const uint32_t n_dst = titanssl_mbox->n_dst;

  printf("TEST START\r\n");

// ----------------------------------------------------------------

  entropy_testutils_auto_mode_init();

  otbn_t otbn_ctx;
  otbn_init(&otbn_ctx, mmio_region_from_addr(TOP_EARLGREY_OTBN_BASE_ADDR));

  test_barrett384(&otbn_ctx);

// ----------------------------------------------------------------

  printf("TEST END\r\n");

  return true;
}
