// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// tl_main package generated by `tlgen.py` tool

package tl_main_pkg;

  localparam logic [31:0] ADDR_SPACE_RV_DM__REGS          = 32'h c1200000;
  localparam logic [31:0] ADDR_SPACE_RV_DM__ROM           = 32'h 00000000;
  localparam logic [31:0] ADDR_SPACE_ALSAQR               = 32'h 00010000;
  localparam logic [31:0] ADDR_SPACE_ROM_CTRL__ROM        = 32'h d0008000;
  localparam logic [31:0] ADDR_SPACE_ROM_CTRL__REGS       = 32'h c11e0000;
  localparam logic [31:0] ADDR_SPACE_PERI                 = 32'h b0000000;
  localparam logic [31:0] ADDR_SPACE_SPI_HOST0            = 32'h c0300000;
  localparam logic [31:0] ADDR_SPACE_FLASH_CTRL__CORE     = 32'h c1000000;
  localparam logic [31:0] ADDR_SPACE_FLASH_CTRL__PRIM     = 32'h c1008000;
  localparam logic [31:0] ADDR_SPACE_FLASH_CTRL__MEM      = 32'h f0000000;
  localparam logic [31:0] ADDR_SPACE_HMAC                 = 32'h c1110000;
  localparam logic [31:0] ADDR_SPACE_KMAC                 = 32'h c1120000;
  localparam logic [31:0] ADDR_SPACE_AES                  = 32'h c1100000;
  localparam logic [31:0] ADDR_SPACE_ENTROPY_SRC          = 32'h c1160000;
  localparam logic [31:0] ADDR_SPACE_CSRNG                = 32'h c1150000;
  localparam logic [31:0] ADDR_SPACE_EDN0                 = 32'h c1170000;
  localparam logic [31:0] ADDR_SPACE_EDN1                 = 32'h c1180000;
  localparam logic [31:0] ADDR_SPACE_RV_PLIC              = 32'h c8000000;
  localparam logic [31:0] ADDR_SPACE_OTBN                 = 32'h c1130000;
  localparam logic [31:0] ADDR_SPACE_KEYMGR               = 32'h c1140000;
  localparam logic [31:0] ADDR_SPACE_RV_CORE_IBEX__CFG    = 32'h c11f0000;
  localparam logic [31:0] ADDR_SPACE_SRAM_CTRL_MAIN__REGS = 32'h c11c0000;
  localparam logic [31:0] ADDR_SPACE_SRAM_CTRL_MAIN__RAM  = 32'h e0000000;

  localparam logic [31:0] ADDR_MASK_RV_DM__REGS          = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_RV_DM__ROM           = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_ALSAQR               = 32'h 9fffffff;
  localparam logic [31:0] ADDR_MASK_ROM_CTRL__ROM        = 32'h 00007fff;
  localparam logic [31:0] ADDR_MASK_ROM_CTRL__REGS       = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_PERI                 = 32'h 00ffffff;
  localparam logic [31:0] ADDR_MASK_SPI_HOST0            = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_FLASH_CTRL__CORE     = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_FLASH_CTRL__PRIM     = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_FLASH_CTRL__MEM      = 32'h 000fffff;
  localparam logic [31:0] ADDR_MASK_HMAC                 = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_KMAC                 = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_AES                  = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_ENTROPY_SRC          = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_CSRNG                = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_EDN0                 = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_EDN1                 = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_RV_PLIC              = 32'h 07ffffff;
  localparam logic [31:0] ADDR_MASK_OTBN                 = 32'h 0000ffff;
  localparam logic [31:0] ADDR_MASK_KEYMGR               = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_RV_CORE_IBEX__CFG    = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_SRAM_CTRL_MAIN__REGS = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_SRAM_CTRL_MAIN__RAM  = 32'h 0001ffff;

  localparam int N_HOST   = 3;
  localparam int N_DEVICE = 23;

  typedef enum int {
    TlRvDmRegs = 0,
    TlRvDmRom = 1,
    TlAlsaqr = 2,
    TlRomCtrlRom = 3,
    TlRomCtrlRegs = 4,
    TlPeri = 5,
    TlSpiHost0 = 6,
    TlFlashCtrlCore = 7,
    TlFlashCtrlPrim = 8,
    TlFlashCtrlMem = 9,
    TlHmac = 10,
    TlKmac = 11,
    TlAes = 12,
    TlEntropySrc = 13,
    TlCsrng = 14,
    TlEdn0 = 15,
    TlEdn1 = 16,
    TlRvPlic = 17,
    TlOtbn = 18,
    TlKeymgr = 19,
    TlRvCoreIbexCfg = 20,
    TlSramCtrlMainRegs = 21,
    TlSramCtrlMainRam = 22
  } tl_device_e;

  typedef enum int {
    TlRvCoreIbexCorei = 0,
    TlRvCoreIbexCored = 1,
    TlRvDmSba = 2
  } tl_host_e;

endpackage
