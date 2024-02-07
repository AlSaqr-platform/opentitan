// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/silicon_creator/rom/uart.h"
#include "sw/device/silicon_creator/rom/string_lib.h"
#include "sw/device/lib/dif/dif_uart.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

#define FPGA_EMULATION

int main(int argc, char **argv) {

  int * tmp;
  /* Set UART MUX with hardcoded write */
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
  printf("HELLO OPENTITAN!\r\n");

  return true;
}