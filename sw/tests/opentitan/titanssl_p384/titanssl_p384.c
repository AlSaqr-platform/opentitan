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

// ----------------------------------  -----------------------------------

OTTF_DEFINE_TEST_CONFIG();

uint8_t ecc384_private_key_d[48] = {
    0x6B, 0x9D, 0x3D, 0xAD, 0x2E, 0x1B, 0x8C, 0x1C, 0x05, 0xB1, 0x98, 0x75,
    0xB6, 0x65, 0x9F, 0x4D, 0xE2, 0x3C, 0x3B, 0x66, 0x7B, 0xF2, 0x97, 0xBA,
    0x9A, 0xA4, 0x77, 0x40, 0x78, 0x71, 0x37, 0xD8, 0x96, 0xD5, 0x72, 0x4E,
    0x4C, 0x70, 0xA8, 0x25, 0xF8, 0x72, 0xC9, 0xEA, 0x60, 0xD2, 0xED, 0xF5};

uint8_t ecc384_secret_k[48] = {
    0x94, 0xED, 0x91, 0x0D, 0x1A, 0x09, 0x9D, 0xAD, 0x32, 0x54, 0xE9, 0x24,
    0x2A, 0xE8, 0x5A, 0xBD, 0xE4, 0xBA, 0x15, 0x16, 0x8E, 0xAF, 0x0C, 0xA8,
    0x7A, 0x55, 0x5F, 0xD5, 0x6D, 0x10, 0xFB, 0xCA, 0x29, 0x07, 0xE3, 0xE8,
    0x3B, 0xA9, 0x53, 0x68, 0x62, 0x3B, 0x8C, 0x46, 0x86, 0x91, 0x5C, 0xF9};

uint8_t ecc384_msg[48] = {"sample"};

OTBN_DECLARE_APP_SYMBOLS(p384_ecdsa_sca);

OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca, dptr_msg);
OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca, dptr_r);
OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca, dptr_s);
OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca, dptr_x);
OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca, dptr_y);
OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca, dptr_d);
OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca,
                         dptr_rnd);  // x_r not used in p384 verify .s
OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca, dptr_k);

OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca, mode);
OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca, msg);
OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca, r);
OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca, s);
OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca, x);
OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca, y);
OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca, d);
OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca, k);
OTBN_DECLARE_SYMBOL_ADDR(p384_ecdsa_sca,
                         rnd);  // x_r not used in p384 verify .s file

static const otbn_app_t kOtbnAppP384Ecdsa = OTBN_APP_T_INIT(p384_ecdsa_sca);

static const otbn_addr_t kOtbnVarDptrMsg =
    OTBN_ADDR_T_INIT(p384_ecdsa_sca, dptr_msg);
static const otbn_addr_t kOtbnVarDptrR =
    OTBN_ADDR_T_INIT(p384_ecdsa_sca, dptr_r);
static const otbn_addr_t kOtbnVarDptrS =
    OTBN_ADDR_T_INIT(p384_ecdsa_sca, dptr_s);
static const otbn_addr_t kOtbnVarDptrX =
    OTBN_ADDR_T_INIT(p384_ecdsa_sca, dptr_x);
static const otbn_addr_t kOtbnVarDptrY =
    OTBN_ADDR_T_INIT(p384_ecdsa_sca, dptr_y);
static const otbn_addr_t kOtbnVarDptrD =
    OTBN_ADDR_T_INIT(p384_ecdsa_sca, dptr_d);
static const otbn_addr_t kOtbnVarDptrRnd =
    OTBN_ADDR_T_INIT(p384_ecdsa_sca, dptr_rnd);
static const otbn_addr_t kOtbnVarDptrK =
    OTBN_ADDR_T_INIT(p384_ecdsa_sca, dptr_k);

static const otbn_addr_t kOtbnVarMode = OTBN_ADDR_T_INIT(p384_ecdsa_sca, mode);
static const otbn_addr_t kOtbnVarMsg = OTBN_ADDR_T_INIT(p384_ecdsa_sca, msg);
static const otbn_addr_t kOtbnVarR = OTBN_ADDR_T_INIT(p384_ecdsa_sca, r);
static const otbn_addr_t kOtbnVarS = OTBN_ADDR_T_INIT(p384_ecdsa_sca, s);
static const otbn_addr_t kOtbnVarX = OTBN_ADDR_T_INIT(p384_ecdsa_sca, x);
static const otbn_addr_t kOtbnVarY = OTBN_ADDR_T_INIT(p384_ecdsa_sca, y);
static const otbn_addr_t kOtbnVarD = OTBN_ADDR_T_INIT(p384_ecdsa_sca, d);
static const otbn_addr_t kOtbnVarRnd = OTBN_ADDR_T_INIT(p384_ecdsa_sca, rnd);
static const otbn_addr_t kOtbnVarK = OTBN_ADDR_T_INIT(p384_ecdsa_sca, k);

// ------------------------------------ MAIN -------------------------------------

int main(int argc, char **argv) {

  initialize_printf();

  printf("TEST START\r\n");

// ----------------------------------------------------------------

  entropy_testutils_auto_mode_init();

  printf("SSECDSA starting...\r\n");

  otbn_t otbn_ctx;
  otbn_init(&otbn_ctx, mmio_region_from_addr(TOP_EARLGREY_OTBN_BASE_ADDR));

  otbn_zero_data_memory(&otbn_ctx);
  otbn_load_app(&otbn_ctx, kOtbnAppP384Ecdsa);

  uint8_t ecc384_signature_r[48] = {0};
  uint8_t ecc384_signature_s[48] = {0};

   for (int i = 0; i < 48; ++i)
    printf("result at byte %d: 0x%02x (ecc384_signature_r) - 0x%02x (ecc384_signature_s)\r\n", i, ecc384_signature_r[i], ecc384_signature_s[i]);


  printf("Signing\r\n");

  // sca_set_trigger_high();
  
  // p384_ecdsa_sign(&otbn_ctx, ecc384_msg, ecc384_private_key_d, ecc384_signature_r, ecc384_signature_s, ecc384_secret_k);
  
  printf("Setup data pointers\r\n");
  otbn_copy_data_to_otbn(&otbn_ctx, sizeof(kOtbnVarMsg), &kOtbnVarMsg, kOtbnVarDptrMsg);
  otbn_copy_data_to_otbn(&otbn_ctx, sizeof(kOtbnVarR), &kOtbnVarR, kOtbnVarDptrR);
  otbn_copy_data_to_otbn(&otbn_ctx, sizeof(kOtbnVarS), &kOtbnVarS, kOtbnVarDptrS);
  otbn_copy_data_to_otbn(&otbn_ctx, sizeof(kOtbnVarX), &kOtbnVarX, kOtbnVarDptrX);
  otbn_copy_data_to_otbn(&otbn_ctx, sizeof(kOtbnVarY), &kOtbnVarY, kOtbnVarDptrY);
  otbn_copy_data_to_otbn(&otbn_ctx, sizeof(kOtbnVarD), &kOtbnVarD, kOtbnVarDptrD);
  otbn_copy_data_to_otbn(&otbn_ctx, sizeof(kOtbnVarRnd), &kOtbnVarRnd, kOtbnVarDptrRnd);
  otbn_copy_data_to_otbn(&otbn_ctx, sizeof(kOtbnVarK), &kOtbnVarK, kOtbnVarDptrK);

  uint32_t mode = 1;  // mode 1 => sign
  printf("Copy data\r\n");
  otbn_copy_data_to_otbn(&otbn_ctx, sizeof(mode), &mode, kOtbnVarMode);
  otbn_copy_data_to_otbn(&otbn_ctx, 48, ecc384_msg, kOtbnVarMsg);
  otbn_copy_data_to_otbn(&otbn_ctx, 48, ecc384_private_key_d, kOtbnVarD);
  otbn_copy_data_to_otbn(&otbn_ctx, 48, ecc384_secret_k, kOtbnVarK);

  printf("Execute\r\n");
  otbn_execute(&otbn_ctx);
  printf("Wait for done\r\n");
  otbn_busy_wait_for_done(&otbn_ctx);

  printf("Get results\r\n");
  otbn_copy_data_from_otbn(&otbn_ctx, 48, kOtbnVarR, ecc384_signature_r);
  otbn_copy_data_from_otbn(&otbn_ctx, 48, kOtbnVarS, ecc384_signature_s);
  
  // sca_set_trigger_low();

  printf("Clearing OTBN memory\r\n");
  otbn_zero_data_memory(&otbn_ctx);

  for (int i = 0; i < 48; ++i)
    printf("result at byte %d: 0x%02x (ecc384_signature_r) - 0x%02x (ecc384_signature_s)\r\n", i, ecc384_signature_r[i], ecc384_signature_s[i]);

  // otbn_execute(&otbn_ctx);
  // otbn_busy_wait_for_done(&otbn_ctx);
  // // otbn_copy_data_from_otbn(otbn_ctx, sizeof(c), kOupC, &c);

// ----------------------------------------------------------------

  printf("TEST END\r\n");

  return true;
}
