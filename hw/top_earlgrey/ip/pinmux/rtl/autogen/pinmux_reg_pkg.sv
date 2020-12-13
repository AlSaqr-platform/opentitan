// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package pinmux_reg_pkg;

  // Param list
  parameter int NMioPeriphIn = 34;
  parameter int NMioPeriphOut = 38;
  parameter int NMioPads = 32;
  parameter int NDioPads = 15;
  parameter int NWkupDetect = 8;
  parameter int WkupCntWidth = 8;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////
  typedef struct packed {
    logic [5:0]  q;
  } pinmux_reg2hw_periph_insel_mreg_t;

  typedef struct packed {
    logic [5:0]  q;
  } pinmux_reg2hw_mio_outsel_mreg_t;

  typedef struct packed {
    logic [1:0]  q;
  } pinmux_reg2hw_mio_out_sleep_val_mreg_t;

  typedef struct packed {
    logic [1:0]  q;
    logic        qe;
  } pinmux_reg2hw_dio_out_sleep_val_mreg_t;

  typedef struct packed {
    logic        q;
  } pinmux_reg2hw_wkup_detector_en_mreg_t;

  typedef struct packed {
    struct packed {
      logic [2:0]  q;
    } mode;
    struct packed {
      logic        q;
    } filter;
    struct packed {
      logic        q;
    } miodio;
  } pinmux_reg2hw_wkup_detector_mreg_t;

  typedef struct packed {
    logic [7:0]  q;
  } pinmux_reg2hw_wkup_detector_cnt_th_mreg_t;

  typedef struct packed {
    logic [4:0]  q;
  } pinmux_reg2hw_wkup_detector_padsel_mreg_t;

  typedef struct packed {
    logic        q;
    logic        qe;
  } pinmux_reg2hw_wkup_cause_mreg_t;


  typedef struct packed {
    logic [1:0]  d;
  } pinmux_hw2reg_dio_out_sleep_val_mreg_t;

  typedef struct packed {
    logic        d;
  } pinmux_hw2reg_wkup_cause_mreg_t;


  ///////////////////////////////////////
  // Register to internal design logic //
  ///////////////////////////////////////
  typedef struct packed {
    pinmux_reg2hw_periph_insel_mreg_t [33:0] periph_insel; // [672:469]
    pinmux_reg2hw_mio_outsel_mreg_t [31:0] mio_outsel; // [468:277]
    pinmux_reg2hw_mio_out_sleep_val_mreg_t [31:0] mio_out_sleep_val; // [276:213]
    pinmux_reg2hw_dio_out_sleep_val_mreg_t [14:0] dio_out_sleep_val; // [212:168]
    pinmux_reg2hw_wkup_detector_en_mreg_t [7:0] wkup_detector_en; // [167:160]
    pinmux_reg2hw_wkup_detector_mreg_t [7:0] wkup_detector; // [159:120]
    pinmux_reg2hw_wkup_detector_cnt_th_mreg_t [7:0] wkup_detector_cnt_th; // [119:56]
    pinmux_reg2hw_wkup_detector_padsel_mreg_t [7:0] wkup_detector_padsel; // [55:16]
    pinmux_reg2hw_wkup_cause_mreg_t [7:0] wkup_cause; // [15:0]
  } pinmux_reg2hw_t;

  ///////////////////////////////////////
  // Internal design logic to register //
  ///////////////////////////////////////
  typedef struct packed {
    pinmux_hw2reg_dio_out_sleep_val_mreg_t [14:0] dio_out_sleep_val; // [37:8]
    pinmux_hw2reg_wkup_cause_mreg_t [7:0] wkup_cause; // [7:0]
  } pinmux_hw2reg_t;

  // Register Address
  parameter logic [6:0] PINMUX_REGEN_OFFSET = 7'h 0;
  parameter logic [6:0] PINMUX_PERIPH_INSEL_0_OFFSET = 7'h 4;
  parameter logic [6:0] PINMUX_PERIPH_INSEL_1_OFFSET = 7'h 8;
  parameter logic [6:0] PINMUX_PERIPH_INSEL_2_OFFSET = 7'h c;
  parameter logic [6:0] PINMUX_PERIPH_INSEL_3_OFFSET = 7'h 10;
  parameter logic [6:0] PINMUX_PERIPH_INSEL_4_OFFSET = 7'h 14;
  parameter logic [6:0] PINMUX_PERIPH_INSEL_5_OFFSET = 7'h 18;
  parameter logic [6:0] PINMUX_PERIPH_INSEL_6_OFFSET = 7'h 1c;
  parameter logic [6:0] PINMUX_MIO_OUTSEL_0_OFFSET = 7'h 20;
  parameter logic [6:0] PINMUX_MIO_OUTSEL_1_OFFSET = 7'h 24;
  parameter logic [6:0] PINMUX_MIO_OUTSEL_2_OFFSET = 7'h 28;
  parameter logic [6:0] PINMUX_MIO_OUTSEL_3_OFFSET = 7'h 2c;
  parameter logic [6:0] PINMUX_MIO_OUTSEL_4_OFFSET = 7'h 30;
  parameter logic [6:0] PINMUX_MIO_OUTSEL_5_OFFSET = 7'h 34;
  parameter logic [6:0] PINMUX_MIO_OUTSEL_6_OFFSET = 7'h 38;
  parameter logic [6:0] PINMUX_MIO_OUT_SLEEP_VAL_0_OFFSET = 7'h 3c;
  parameter logic [6:0] PINMUX_MIO_OUT_SLEEP_VAL_1_OFFSET = 7'h 40;
  parameter logic [6:0] PINMUX_DIO_OUT_SLEEP_VAL_OFFSET = 7'h 44;
  parameter logic [6:0] PINMUX_WKUP_DETECTOR_EN_OFFSET = 7'h 48;
  parameter logic [6:0] PINMUX_WKUP_DETECTOR_0_OFFSET = 7'h 4c;
  parameter logic [6:0] PINMUX_WKUP_DETECTOR_1_OFFSET = 7'h 50;
  parameter logic [6:0] PINMUX_WKUP_DETECTOR_2_OFFSET = 7'h 54;
  parameter logic [6:0] PINMUX_WKUP_DETECTOR_3_OFFSET = 7'h 58;
  parameter logic [6:0] PINMUX_WKUP_DETECTOR_4_OFFSET = 7'h 5c;
  parameter logic [6:0] PINMUX_WKUP_DETECTOR_5_OFFSET = 7'h 60;
  parameter logic [6:0] PINMUX_WKUP_DETECTOR_6_OFFSET = 7'h 64;
  parameter logic [6:0] PINMUX_WKUP_DETECTOR_7_OFFSET = 7'h 68;
  parameter logic [6:0] PINMUX_WKUP_DETECTOR_CNT_TH_0_OFFSET = 7'h 6c;
  parameter logic [6:0] PINMUX_WKUP_DETECTOR_CNT_TH_1_OFFSET = 7'h 70;
  parameter logic [6:0] PINMUX_WKUP_DETECTOR_PADSEL_0_OFFSET = 7'h 74;
  parameter logic [6:0] PINMUX_WKUP_DETECTOR_PADSEL_1_OFFSET = 7'h 78;
  parameter logic [6:0] PINMUX_WKUP_CAUSE_OFFSET = 7'h 7c;


  // Register Index
  typedef enum int {
    PINMUX_REGEN,
    PINMUX_PERIPH_INSEL_0,
    PINMUX_PERIPH_INSEL_1,
    PINMUX_PERIPH_INSEL_2,
    PINMUX_PERIPH_INSEL_3,
    PINMUX_PERIPH_INSEL_4,
    PINMUX_PERIPH_INSEL_5,
    PINMUX_PERIPH_INSEL_6,
    PINMUX_MIO_OUTSEL_0,
    PINMUX_MIO_OUTSEL_1,
    PINMUX_MIO_OUTSEL_2,
    PINMUX_MIO_OUTSEL_3,
    PINMUX_MIO_OUTSEL_4,
    PINMUX_MIO_OUTSEL_5,
    PINMUX_MIO_OUTSEL_6,
    PINMUX_MIO_OUT_SLEEP_VAL_0,
    PINMUX_MIO_OUT_SLEEP_VAL_1,
    PINMUX_DIO_OUT_SLEEP_VAL,
    PINMUX_WKUP_DETECTOR_EN,
    PINMUX_WKUP_DETECTOR_0,
    PINMUX_WKUP_DETECTOR_1,
    PINMUX_WKUP_DETECTOR_2,
    PINMUX_WKUP_DETECTOR_3,
    PINMUX_WKUP_DETECTOR_4,
    PINMUX_WKUP_DETECTOR_5,
    PINMUX_WKUP_DETECTOR_6,
    PINMUX_WKUP_DETECTOR_7,
    PINMUX_WKUP_DETECTOR_CNT_TH_0,
    PINMUX_WKUP_DETECTOR_CNT_TH_1,
    PINMUX_WKUP_DETECTOR_PADSEL_0,
    PINMUX_WKUP_DETECTOR_PADSEL_1,
    PINMUX_WKUP_CAUSE
  } pinmux_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] PINMUX_PERMIT [32] = '{
    4'b 0001, // index[ 0] PINMUX_REGEN
    4'b 1111, // index[ 1] PINMUX_PERIPH_INSEL_0
    4'b 1111, // index[ 2] PINMUX_PERIPH_INSEL_1
    4'b 1111, // index[ 3] PINMUX_PERIPH_INSEL_2
    4'b 1111, // index[ 4] PINMUX_PERIPH_INSEL_3
    4'b 1111, // index[ 5] PINMUX_PERIPH_INSEL_4
    4'b 1111, // index[ 6] PINMUX_PERIPH_INSEL_5
    4'b 0111, // index[ 7] PINMUX_PERIPH_INSEL_6
    4'b 1111, // index[ 8] PINMUX_MIO_OUTSEL_0
    4'b 1111, // index[ 9] PINMUX_MIO_OUTSEL_1
    4'b 1111, // index[10] PINMUX_MIO_OUTSEL_2
    4'b 1111, // index[11] PINMUX_MIO_OUTSEL_3
    4'b 1111, // index[12] PINMUX_MIO_OUTSEL_4
    4'b 1111, // index[13] PINMUX_MIO_OUTSEL_5
    4'b 0011, // index[14] PINMUX_MIO_OUTSEL_6
    4'b 1111, // index[15] PINMUX_MIO_OUT_SLEEP_VAL_0
    4'b 1111, // index[16] PINMUX_MIO_OUT_SLEEP_VAL_1
    4'b 1111, // index[17] PINMUX_DIO_OUT_SLEEP_VAL
    4'b 0001, // index[18] PINMUX_WKUP_DETECTOR_EN
    4'b 0001, // index[19] PINMUX_WKUP_DETECTOR_0
    4'b 0001, // index[20] PINMUX_WKUP_DETECTOR_1
    4'b 0001, // index[21] PINMUX_WKUP_DETECTOR_2
    4'b 0001, // index[22] PINMUX_WKUP_DETECTOR_3
    4'b 0001, // index[23] PINMUX_WKUP_DETECTOR_4
    4'b 0001, // index[24] PINMUX_WKUP_DETECTOR_5
    4'b 0001, // index[25] PINMUX_WKUP_DETECTOR_6
    4'b 0001, // index[26] PINMUX_WKUP_DETECTOR_7
    4'b 1111, // index[27] PINMUX_WKUP_DETECTOR_CNT_TH_0
    4'b 1111, // index[28] PINMUX_WKUP_DETECTOR_CNT_TH_1
    4'b 1111, // index[29] PINMUX_WKUP_DETECTOR_PADSEL_0
    4'b 0011, // index[30] PINMUX_WKUP_DETECTOR_PADSEL_1
    4'b 0001  // index[31] PINMUX_WKUP_CAUSE
  };
endpackage

