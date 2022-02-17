// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// tl_main package generated by `tlgen.py` tool

package tl_main_pkg;

  localparam logic [31:0] ADDR_SPACE_DATA_MEM      = 32'h 00100000;
  localparam logic [31:0] ADDR_SPACE_SIM_CTRL      = 32'h 00020000;
  localparam logic [31:0] ADDR_SPACE_ROM_CTRL      = 32'h 411e0000;
  localparam logic [31:0] ADDR_SPACE_KMAC          = 32'h 41120000;
  localparam logic [31:0] ADDR_SPACE_KEYMGR        = 32'h 41130000;
  localparam logic [31:0] ADDR_SPACE_OTP_CTRL      = 32'h 40130000;
  localparam logic [31:0] ADDR_SPACE_HMAC          = 32'h 41110000;
  localparam logic [31:0] ADDR_SPACE_LC_CTRL       = 32'h 40140000;
  localparam logic [31:0] ADDR_SPACE_SRAM_CTRL     = 32'h 411c0000;
  localparam logic [31:0] ADDR_SPACE_FLASH_CTRL    = 32'h 41000000;
  localparam logic [31:0] ADDR_SPACE_UART          = 32'h 40000000;
  localparam logic [31:0] ADDR_SPACE_CLKMGR        = 32'h 40420000;
  localparam logic [31:0] ADDR_SPACE_SYSRST_CTRL   = 32'h 40430000;
  localparam logic [31:0] ADDR_SPACE_RSTMGR        = 32'h 40410000;
  localparam logic [31:0] ADDR_SPACE_PWRMGR        = 32'h 40400000;
  localparam logic [31:0] ADDR_SPACE_ALERT_HANDLER = 32'h 40150000;
  localparam logic [31:0] ADDR_SPACE_RV_DM         = 32'h 41200000;
  localparam logic [31:0] ADDR_SPACE_RV_PLIC       = 32'h 41010000;
  localparam logic [31:0] ADDR_SPACE_EDN           = 32'h 41170000;
  localparam logic [31:0] ADDR_SPACE_OTBN          = 32'h 411d0000;
  localparam logic [31:0] ADDR_SPACE_AES           = 32'h 41100000;
  localparam logic [31:0] ADDR_SPACE_CSRNG         = 32'h 41150000;
  localparam logic [31:0] ADDR_SPACE_ENTROPY_SRC   = 32'h 41160000;
  localparam logic [31:0] ADDR_SPACE_GPIO          = 32'h 40040000;
  localparam logic [31:0] ADDR_SPACE_SPI_DEVICE    = 32'h 40050000;
  localparam logic [31:0] ADDR_SPACE_SPI_HOST      = 32'h 40060000;
  localparam logic [31:0] ADDR_SPACE_TESTRST       = 32'h 50000000;
  localparam logic [31:0] ADDR_SPACE_INSTR_MEM     = 32'h 30120000;

  localparam logic [31:0] ADDR_MASK_DATA_MEM      = 32'h 000fffff;
  localparam logic [31:0] ADDR_MASK_SIM_CTRL      = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_ROM_CTRL      = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_KMAC          = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_KEYMGR        = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_OTP_CTRL      = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_HMAC          = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_LC_CTRL       = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_SRAM_CTRL     = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_FLASH_CTRL    = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_UART          = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_CLKMGR        = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_SYSRST_CTRL   = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_RSTMGR        = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_PWRMGR        = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_ALERT_HANDLER = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_RV_DM         = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_RV_PLIC       = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_EDN           = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_OTBN          = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_AES           = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_CSRNG         = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_ENTROPY_SRC   = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_GPIO          = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_SPI_DEVICE    = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_SPI_HOST      = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_TESTRST       = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_INSTR_MEM     = 32'h 00000fff;

  localparam int N_HOST   = 2;
  localparam int N_DEVICE = 28;

  typedef enum int {
    TlDataMem = 0,
    TlSimCtrl = 1,
    TlRomCtrl = 2,
    TlKmac = 3,
    TlKeymgr = 4,
    TlOtpCtrl = 5,
    TlHmac = 6,
    TlLcCtrl = 7,
    TlSramCtrl = 8,
    TlFlashCtrl = 9,
    TlUart = 10,
    TlClkmgr = 11,
    TlSysrstCtrl = 12,
    TlRstmgr = 13,
    TlPwrmgr = 14,
    TlAlertHandler = 15,
    TlRvDm = 16,
    TlRvPlic = 17,
    TlEdn = 18,
    TlOtbn = 19,
    TlAes = 20,
    TlCsrng = 21,
    TlEntropySrc = 22,
    TlGpio = 23,
    TlSpiDevice = 24,
    TlSpiHost = 25,
    TlTestrst = 26,
    TlInstrMem = 27
  } tl_device_e;

  typedef enum int {
    TlCoreInstr = 0,
    TlCoreData = 1
  } tl_host_e;

endpackage
