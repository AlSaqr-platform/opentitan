// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdbool.h>
#include <stdint.h>

#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/runtime/print.h"
#include "sw/device/silicon_creator/lib/drivers/uart.h"
#include "sw/device/silicon_creator/lib/error.h"
#include "sw/device/silicon_creator/lib/test_main.h"

#include "hw/top_earlgrey/sw/top_earlgrey.h"

OTTF_DEFINE_TEST_CONFIG(.can_clobber_uart = true, );

rom_error_t uart_test(void) {
  // Configure UART0 as stdout.
  #ifdef TARGET_SYNTHESIS                
  int baud_rate = 115200;
  int test_freq = 40000000;
  #else
  //set_flls();
  int baud_rate = 115200;
  int test_freq = 100000000;
  #endif
  
  uart_set_cfg(0,(test_freq/baud_rate)>>4);

  base_set_stdout((buffer_sink_t){
      .data = NULL,
      //.sink = uart_sink,
  });

  base_printf("uart functional test!\r\n");
  return kErrorOk;
}

bool test_main(void) {
  rom_error_t result = kErrorOk;
  EXECUTE_TEST(result, uart_test);
  return result == kErrorOk;
}
