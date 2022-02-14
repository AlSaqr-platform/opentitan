// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package rom_ctrl_reg_pkg;

  // Param list
  parameter int NumAlerts = 1;

  // Address widths within the block
  parameter int RegsAw = 7;
  parameter int RomAw = 14;

  ///////////////////////////////////////////////
  // Typedefs for registers for regs interface //
  ///////////////////////////////////////////////

  typedef struct packed {
    logic        q;
    logic        qe;
  } rom_ctrl_reg2hw_alert_test_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } rom_ctrl_reg2hw_digest_mreg_t;

  typedef struct packed {
    logic [31:0] q;
  } rom_ctrl_reg2hw_exp_digest_mreg_t;

  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } checker_error;
    struct packed {
      logic        d;
      logic        de;
    } integrity_error;
  } rom_ctrl_hw2reg_fatal_alert_cause_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } rom_ctrl_hw2reg_digest_mreg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } rom_ctrl_hw2reg_exp_digest_mreg_t;

  // Register -> HW type for regs interface
  typedef struct packed {
    rom_ctrl_reg2hw_alert_test_reg_t alert_test; // [513:512]
    rom_ctrl_reg2hw_digest_mreg_t [7:0] digest; // [511:256]
    rom_ctrl_reg2hw_exp_digest_mreg_t [7:0] exp_digest; // [255:0]
  } rom_ctrl_regs_reg2hw_t;

  // HW -> register type for regs interface
  typedef struct packed {
    rom_ctrl_hw2reg_fatal_alert_cause_reg_t fatal_alert_cause; // [531:528]
    rom_ctrl_hw2reg_digest_mreg_t [7:0] digest; // [527:264]
    rom_ctrl_hw2reg_exp_digest_mreg_t [7:0] exp_digest; // [263:0]
  } rom_ctrl_regs_hw2reg_t;

  // Register offsets for regs interface
  parameter logic [RegsAw-1:0] ROM_CTRL_ALERT_TEST_OFFSET = 7'h 0;
  parameter logic [RegsAw-1:0] ROM_CTRL_FATAL_ALERT_CAUSE_OFFSET = 7'h 4;
  parameter logic [RegsAw-1:0] ROM_CTRL_DIGEST_0_OFFSET = 7'h 8;
  parameter logic [RegsAw-1:0] ROM_CTRL_DIGEST_1_OFFSET = 7'h c;
  parameter logic [RegsAw-1:0] ROM_CTRL_DIGEST_2_OFFSET = 7'h 10;
  parameter logic [RegsAw-1:0] ROM_CTRL_DIGEST_3_OFFSET = 7'h 14;
  parameter logic [RegsAw-1:0] ROM_CTRL_DIGEST_4_OFFSET = 7'h 18;
  parameter logic [RegsAw-1:0] ROM_CTRL_DIGEST_5_OFFSET = 7'h 1c;
  parameter logic [RegsAw-1:0] ROM_CTRL_DIGEST_6_OFFSET = 7'h 20;
  parameter logic [RegsAw-1:0] ROM_CTRL_DIGEST_7_OFFSET = 7'h 24;
  parameter logic [RegsAw-1:0] ROM_CTRL_EXP_DIGEST_0_OFFSET = 7'h 28;
  parameter logic [RegsAw-1:0] ROM_CTRL_EXP_DIGEST_1_OFFSET = 7'h 2c;
  parameter logic [RegsAw-1:0] ROM_CTRL_EXP_DIGEST_2_OFFSET = 7'h 30;
  parameter logic [RegsAw-1:0] ROM_CTRL_EXP_DIGEST_3_OFFSET = 7'h 34;
  parameter logic [RegsAw-1:0] ROM_CTRL_EXP_DIGEST_4_OFFSET = 7'h 38;
  parameter logic [RegsAw-1:0] ROM_CTRL_EXP_DIGEST_5_OFFSET = 7'h 3c;
  parameter logic [RegsAw-1:0] ROM_CTRL_EXP_DIGEST_6_OFFSET = 7'h 40;
  parameter logic [RegsAw-1:0] ROM_CTRL_EXP_DIGEST_7_OFFSET = 7'h 44;

  // Reset values for hwext registers and their fields for regs interface
  parameter logic [0:0] ROM_CTRL_ALERT_TEST_RESVAL = 1'h 0;
  parameter logic [0:0] ROM_CTRL_ALERT_TEST_FATAL_RESVAL = 1'h 0;

  // Register index for regs interface
  typedef enum int {
    ROM_CTRL_ALERT_TEST,
    ROM_CTRL_FATAL_ALERT_CAUSE,
    ROM_CTRL_DIGEST_0,
    ROM_CTRL_DIGEST_1,
    ROM_CTRL_DIGEST_2,
    ROM_CTRL_DIGEST_3,
    ROM_CTRL_DIGEST_4,
    ROM_CTRL_DIGEST_5,
    ROM_CTRL_DIGEST_6,
    ROM_CTRL_DIGEST_7,
    ROM_CTRL_EXP_DIGEST_0,
    ROM_CTRL_EXP_DIGEST_1,
    ROM_CTRL_EXP_DIGEST_2,
    ROM_CTRL_EXP_DIGEST_3,
    ROM_CTRL_EXP_DIGEST_4,
    ROM_CTRL_EXP_DIGEST_5,
    ROM_CTRL_EXP_DIGEST_6,
    ROM_CTRL_EXP_DIGEST_7
  } rom_ctrl_regs_id_e;

  // Register width information to check illegal writes for regs interface
  parameter logic [3:0] ROM_CTRL_REGS_PERMIT [18] = '{
    4'b 0001, // index[ 0] ROM_CTRL_ALERT_TEST
    4'b 0001, // index[ 1] ROM_CTRL_FATAL_ALERT_CAUSE
    4'b 0001, // index[ 2] ROM_CTRL_DIGEST_0   modified, must be 1111
    4'b 1111, // index[ 3] ROM_CTRL_DIGEST_1
    4'b 1111, // index[ 4] ROM_CTRL_DIGEST_2
    4'b 1111, // index[ 5] ROM_CTRL_DIGEST_3
    4'b 1111, // index[ 6] ROM_CTRL_DIGEST_4
    4'b 1111, // index[ 7] ROM_CTRL_DIGEST_5
    4'b 1111, // index[ 8] ROM_CTRL_DIGEST_6
    4'b 1111, // index[ 9] ROM_CTRL_DIGEST_7
    4'b 1111, // index[10] ROM_CTRL_EXP_DIGEST_0
    4'b 1111, // index[11] ROM_CTRL_EXP_DIGEST_1
    4'b 1111, // index[12] ROM_CTRL_EXP_DIGEST_2
    4'b 1111, // index[13] ROM_CTRL_EXP_DIGEST_3
    4'b 1111, // index[14] ROM_CTRL_EXP_DIGEST_4
    4'b 1111, // index[15] ROM_CTRL_EXP_DIGEST_5
    4'b 1111, // index[16] ROM_CTRL_EXP_DIGEST_6
    4'b 1111  // index[17] ROM_CTRL_EXP_DIGEST_7
  };

  // Window parameters for rom interface
  parameter logic [RomAw-1:0] ROM_CTRL_ROM_OFFSET = 14'h 0;
  parameter int unsigned      ROM_CTRL_ROM_SIZE   = 'h 4000;

endpackage

