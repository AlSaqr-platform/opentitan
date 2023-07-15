// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package boot_manager_regs_reg_pkg;

  // Address widths within the block
  parameter int BlockAw = 5;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {
    logic [31:0] q;
  } boot_manager_regs_reg2hw_payload_1_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } boot_manager_regs_reg2hw_payload_2_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } boot_manager_regs_reg2hw_payload_3_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } boot_manager_regs_reg2hw_address_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } start;
    struct packed {
      logic [30:0] q;
    } field1;
  } boot_manager_regs_reg2hw_start_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } datapath;
    struct packed {
      logic [30:0] q;
    } field1;
  } boot_manager_regs_reg2hw_datapath_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } start;
    struct packed {
      logic [30:0] d;
      logic        de;
    } field1;
  } boot_manager_regs_hw2reg_start_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } pad_bootmode;
    struct packed {
      logic [30:0] d;
      logic        de;
    } field1;
  } boot_manager_regs_hw2reg_pad_bootmode_reg_t;

  // Register -> HW type
  typedef struct packed {
    boot_manager_regs_reg2hw_payload_1_reg_t payload_1; // [191:160]
    boot_manager_regs_reg2hw_payload_2_reg_t payload_2; // [159:128]
    boot_manager_regs_reg2hw_payload_3_reg_t payload_3; // [127:96]
    boot_manager_regs_reg2hw_address_reg_t address; // [95:64]
    boot_manager_regs_reg2hw_start_reg_t start; // [63:32]
    boot_manager_regs_reg2hw_datapath_reg_t datapath; // [31:0]
  } boot_manager_regs_reg2hw_t;

  // HW -> register type
  typedef struct packed {
    boot_manager_regs_hw2reg_start_reg_t start; // [67:34]
    boot_manager_regs_hw2reg_pad_bootmode_reg_t pad_bootmode; // [33:0]
  } boot_manager_regs_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] BOOT_MANAGER_REGS_PAYLOAD_1_OFFSET = 5'h 0;
  parameter logic [BlockAw-1:0] BOOT_MANAGER_REGS_PAYLOAD_2_OFFSET = 5'h 4;
  parameter logic [BlockAw-1:0] BOOT_MANAGER_REGS_PAYLOAD_3_OFFSET = 5'h 8;
  parameter logic [BlockAw-1:0] BOOT_MANAGER_REGS_ADDRESS_OFFSET = 5'h c;
  parameter logic [BlockAw-1:0] BOOT_MANAGER_REGS_START_OFFSET = 5'h 10;
  parameter logic [BlockAw-1:0] BOOT_MANAGER_REGS_PAD_BOOTMODE_OFFSET = 5'h 14;
  parameter logic [BlockAw-1:0] BOOT_MANAGER_REGS_SW_BOOTMODE_OFFSET = 5'h 18;
  parameter logic [BlockAw-1:0] BOOT_MANAGER_REGS_DATAPATH_OFFSET = 5'h 1c;

  // Register index
  typedef enum int {
    BOOT_MANAGER_REGS_PAYLOAD_1,
    BOOT_MANAGER_REGS_PAYLOAD_2,
    BOOT_MANAGER_REGS_PAYLOAD_3,
    BOOT_MANAGER_REGS_ADDRESS,
    BOOT_MANAGER_REGS_START,
    BOOT_MANAGER_REGS_PAD_BOOTMODE,
    BOOT_MANAGER_REGS_SW_BOOTMODE,
    BOOT_MANAGER_REGS_DATAPATH
  } boot_manager_regs_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] BOOT_MANAGER_REGS_PERMIT [8] = '{
    4'b 1111, // index[0] BOOT_MANAGER_REGS_PAYLOAD_1
    4'b 1111, // index[1] BOOT_MANAGER_REGS_PAYLOAD_2
    4'b 1111, // index[2] BOOT_MANAGER_REGS_PAYLOAD_3
    4'b 1111, // index[3] BOOT_MANAGER_REGS_ADDRESS
    4'b 1111, // index[4] BOOT_MANAGER_REGS_START
    4'b 1111, // index[5] BOOT_MANAGER_REGS_PAD_BOOTMODE
    4'b 1111, // index[6] BOOT_MANAGER_REGS_SW_BOOTMODE
    4'b 1111  // index[7] BOOT_MANAGER_REGS_DATAPATH
  };

endpackage
