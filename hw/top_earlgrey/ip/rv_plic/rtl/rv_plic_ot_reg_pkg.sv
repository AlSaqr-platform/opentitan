// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package rv_plic_ot_reg_pkg;

  // Param list
  parameter int NumSrc = 89;
  parameter int NumTarget = 1;
  parameter int PrioWidth = 2;
  parameter int NumAlerts = 1;

  // Address widths within the block
  parameter int BlockAw = 27;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio0_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio1_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio2_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio3_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio4_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio5_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio6_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio7_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio8_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio9_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio10_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio11_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio12_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio13_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio14_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio15_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio16_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio17_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio18_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio19_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio20_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio21_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio22_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio23_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio24_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio25_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio26_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio27_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio28_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio29_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio30_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio31_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio32_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio33_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio34_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio35_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio36_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio37_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio38_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio39_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio40_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio41_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio42_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio43_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio44_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio45_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio46_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio47_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio48_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio49_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio50_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio51_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio52_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio53_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio54_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio55_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio56_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio57_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio58_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio59_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio60_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio61_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio62_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio63_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio64_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio65_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio66_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio67_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio68_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio69_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio70_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio71_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio72_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio73_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio74_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio75_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio76_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio77_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio78_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio79_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio80_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio81_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio82_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio83_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio84_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio85_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio86_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio87_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio88_reg_t;

  typedef struct packed {
    logic        q;
  } rv_plic_reg2hw_ie0_mreg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_threshold0_reg_t;

  typedef struct packed {
    logic [6:0]  q;
    logic        qe;
    logic        re;
  } rv_plic_reg2hw_cc0_reg_t;

  typedef struct packed {
    logic        q;
  } rv_plic_reg2hw_msip0_reg_t;

  typedef struct packed {
    logic        q;
    logic        qe;
  } rv_plic_reg2hw_alert_test_reg_t;

  typedef struct packed {
    logic        d;
    logic        de;
  } rv_plic_hw2reg_ip_mreg_t;

  typedef struct packed {
    logic [6:0]  d;
  } rv_plic_hw2reg_cc0_reg_t;

  // Register -> HW type
  typedef struct packed {
    rv_plic_reg2hw_prio0_reg_t prio0; // [280:279]
    rv_plic_reg2hw_prio1_reg_t prio1; // [278:277]
    rv_plic_reg2hw_prio2_reg_t prio2; // [276:275]
    rv_plic_reg2hw_prio3_reg_t prio3; // [274:273]
    rv_plic_reg2hw_prio4_reg_t prio4; // [272:271]
    rv_plic_reg2hw_prio5_reg_t prio5; // [270:269]
    rv_plic_reg2hw_prio6_reg_t prio6; // [268:267]
    rv_plic_reg2hw_prio7_reg_t prio7; // [266:265]
    rv_plic_reg2hw_prio8_reg_t prio8; // [264:263]
    rv_plic_reg2hw_prio9_reg_t prio9; // [262:261]
    rv_plic_reg2hw_prio10_reg_t prio10; // [260:259]
    rv_plic_reg2hw_prio11_reg_t prio11; // [258:257]
    rv_plic_reg2hw_prio12_reg_t prio12; // [256:255]
    rv_plic_reg2hw_prio13_reg_t prio13; // [254:253]
    rv_plic_reg2hw_prio14_reg_t prio14; // [252:251]
    rv_plic_reg2hw_prio15_reg_t prio15; // [250:249]
    rv_plic_reg2hw_prio16_reg_t prio16; // [248:247]
    rv_plic_reg2hw_prio17_reg_t prio17; // [246:245]
    rv_plic_reg2hw_prio18_reg_t prio18; // [244:243]
    rv_plic_reg2hw_prio19_reg_t prio19; // [242:241]
    rv_plic_reg2hw_prio20_reg_t prio20; // [240:239]
    rv_plic_reg2hw_prio21_reg_t prio21; // [238:237]
    rv_plic_reg2hw_prio22_reg_t prio22; // [236:235]
    rv_plic_reg2hw_prio23_reg_t prio23; // [234:233]
    rv_plic_reg2hw_prio24_reg_t prio24; // [232:231]
    rv_plic_reg2hw_prio25_reg_t prio25; // [230:229]
    rv_plic_reg2hw_prio26_reg_t prio26; // [228:227]
    rv_plic_reg2hw_prio27_reg_t prio27; // [226:225]
    rv_plic_reg2hw_prio28_reg_t prio28; // [224:223]
    rv_plic_reg2hw_prio29_reg_t prio29; // [222:221]
    rv_plic_reg2hw_prio30_reg_t prio30; // [220:219]
    rv_plic_reg2hw_prio31_reg_t prio31; // [218:217]
    rv_plic_reg2hw_prio32_reg_t prio32; // [216:215]
    rv_plic_reg2hw_prio33_reg_t prio33; // [214:213]
    rv_plic_reg2hw_prio34_reg_t prio34; // [212:211]
    rv_plic_reg2hw_prio35_reg_t prio35; // [210:209]
    rv_plic_reg2hw_prio36_reg_t prio36; // [208:207]
    rv_plic_reg2hw_prio37_reg_t prio37; // [206:205]
    rv_plic_reg2hw_prio38_reg_t prio38; // [204:203]
    rv_plic_reg2hw_prio39_reg_t prio39; // [202:201]
    rv_plic_reg2hw_prio40_reg_t prio40; // [200:199]
    rv_plic_reg2hw_prio41_reg_t prio41; // [198:197]
    rv_plic_reg2hw_prio42_reg_t prio42; // [196:195]
    rv_plic_reg2hw_prio43_reg_t prio43; // [194:193]
    rv_plic_reg2hw_prio44_reg_t prio44; // [192:191]
    rv_plic_reg2hw_prio45_reg_t prio45; // [190:189]
    rv_plic_reg2hw_prio46_reg_t prio46; // [188:187]
    rv_plic_reg2hw_prio47_reg_t prio47; // [186:185]
    rv_plic_reg2hw_prio48_reg_t prio48; // [184:183]
    rv_plic_reg2hw_prio49_reg_t prio49; // [182:181]
    rv_plic_reg2hw_prio50_reg_t prio50; // [180:179]
    rv_plic_reg2hw_prio51_reg_t prio51; // [178:177]
    rv_plic_reg2hw_prio52_reg_t prio52; // [176:175]
    rv_plic_reg2hw_prio53_reg_t prio53; // [174:173]
    rv_plic_reg2hw_prio54_reg_t prio54; // [172:171]
    rv_plic_reg2hw_prio55_reg_t prio55; // [170:169]
    rv_plic_reg2hw_prio56_reg_t prio56; // [168:167]
    rv_plic_reg2hw_prio57_reg_t prio57; // [166:165]
    rv_plic_reg2hw_prio58_reg_t prio58; // [164:163]
    rv_plic_reg2hw_prio59_reg_t prio59; // [162:161]
    rv_plic_reg2hw_prio60_reg_t prio60; // [160:159]
    rv_plic_reg2hw_prio61_reg_t prio61; // [158:157]
    rv_plic_reg2hw_prio62_reg_t prio62; // [156:155]
    rv_plic_reg2hw_prio63_reg_t prio63; // [154:153]
    rv_plic_reg2hw_prio64_reg_t prio64; // [152:151]
    rv_plic_reg2hw_prio65_reg_t prio65; // [150:149]
    rv_plic_reg2hw_prio66_reg_t prio66; // [148:147]
    rv_plic_reg2hw_prio67_reg_t prio67; // [146:145]
    rv_plic_reg2hw_prio68_reg_t prio68; // [144:143]
    rv_plic_reg2hw_prio69_reg_t prio69; // [142:141]
    rv_plic_reg2hw_prio70_reg_t prio70; // [140:139]
    rv_plic_reg2hw_prio71_reg_t prio71; // [138:137]
    rv_plic_reg2hw_prio72_reg_t prio72; // [136:135]
    rv_plic_reg2hw_prio73_reg_t prio73; // [134:133]
    rv_plic_reg2hw_prio74_reg_t prio74; // [132:131]
    rv_plic_reg2hw_prio75_reg_t prio75; // [130:129]
    rv_plic_reg2hw_prio76_reg_t prio76; // [128:127]
    rv_plic_reg2hw_prio77_reg_t prio77; // [126:125]
    rv_plic_reg2hw_prio78_reg_t prio78; // [124:123]
    rv_plic_reg2hw_prio79_reg_t prio79; // [122:121]
    rv_plic_reg2hw_prio80_reg_t prio80; // [120:119]
    rv_plic_reg2hw_prio81_reg_t prio81; // [118:117]
    rv_plic_reg2hw_prio82_reg_t prio82; // [116:115]
    rv_plic_reg2hw_prio83_reg_t prio83; // [114:113]
    rv_plic_reg2hw_prio84_reg_t prio84; // [112:111]
    rv_plic_reg2hw_prio85_reg_t prio85; // [110:109]
    rv_plic_reg2hw_prio86_reg_t prio86; // [108:107]
    rv_plic_reg2hw_prio87_reg_t prio87; // [106:105]
    rv_plic_reg2hw_prio88_reg_t prio88; // [104:103]
    rv_plic_reg2hw_ie0_mreg_t [88:0] ie0; // [102:14]
    rv_plic_reg2hw_threshold0_reg_t threshold0; // [13:12]
    rv_plic_reg2hw_cc0_reg_t cc0; // [11:3]
    rv_plic_reg2hw_msip0_reg_t msip0; // [2:2]
    rv_plic_reg2hw_alert_test_reg_t alert_test; // [1:0]
  } rv_plic_reg2hw_t;

  // HW -> register type
  typedef struct packed {
    rv_plic_hw2reg_ip_mreg_t [88:0] ip; // [184:7]
    rv_plic_hw2reg_cc0_reg_t cc0; // [6:0]
  } rv_plic_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO0_OFFSET = 27'h 0;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO1_OFFSET = 27'h 4;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO2_OFFSET = 27'h 8;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO3_OFFSET = 27'h c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO4_OFFSET = 27'h 10;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO5_OFFSET = 27'h 14;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO6_OFFSET = 27'h 18;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO7_OFFSET = 27'h 1c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO8_OFFSET = 27'h 20;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO9_OFFSET = 27'h 24;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO10_OFFSET = 27'h 28;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO11_OFFSET = 27'h 2c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO12_OFFSET = 27'h 30;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO13_OFFSET = 27'h 34;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO14_OFFSET = 27'h 38;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO15_OFFSET = 27'h 3c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO16_OFFSET = 27'h 40;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO17_OFFSET = 27'h 44;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO18_OFFSET = 27'h 48;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO19_OFFSET = 27'h 4c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO20_OFFSET = 27'h 50;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO21_OFFSET = 27'h 54;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO22_OFFSET = 27'h 58;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO23_OFFSET = 27'h 5c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO24_OFFSET = 27'h 60;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO25_OFFSET = 27'h 64;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO26_OFFSET = 27'h 68;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO27_OFFSET = 27'h 6c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO28_OFFSET = 27'h 70;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO29_OFFSET = 27'h 74;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO30_OFFSET = 27'h 78;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO31_OFFSET = 27'h 7c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO32_OFFSET = 27'h 80;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO33_OFFSET = 27'h 84;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO34_OFFSET = 27'h 88;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO35_OFFSET = 27'h 8c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO36_OFFSET = 27'h 90;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO37_OFFSET = 27'h 94;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO38_OFFSET = 27'h 98;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO39_OFFSET = 27'h 9c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO40_OFFSET = 27'h a0;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO41_OFFSET = 27'h a4;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO42_OFFSET = 27'h a8;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO43_OFFSET = 27'h ac;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO44_OFFSET = 27'h b0;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO45_OFFSET = 27'h b4;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO46_OFFSET = 27'h b8;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO47_OFFSET = 27'h bc;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO48_OFFSET = 27'h c0;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO49_OFFSET = 27'h c4;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO50_OFFSET = 27'h c8;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO51_OFFSET = 27'h cc;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO52_OFFSET = 27'h d0;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO53_OFFSET = 27'h d4;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO54_OFFSET = 27'h d8;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO55_OFFSET = 27'h dc;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO56_OFFSET = 27'h e0;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO57_OFFSET = 27'h e4;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO58_OFFSET = 27'h e8;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO59_OFFSET = 27'h ec;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO60_OFFSET = 27'h f0;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO61_OFFSET = 27'h f4;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO62_OFFSET = 27'h f8;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO63_OFFSET = 27'h fc;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO64_OFFSET = 27'h 100;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO65_OFFSET = 27'h 104;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO66_OFFSET = 27'h 108;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO67_OFFSET = 27'h 10c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO68_OFFSET = 27'h 110;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO69_OFFSET = 27'h 114;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO70_OFFSET = 27'h 118;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO71_OFFSET = 27'h 11c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO72_OFFSET = 27'h 120;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO73_OFFSET = 27'h 124;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO74_OFFSET = 27'h 128;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO75_OFFSET = 27'h 12c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO76_OFFSET = 27'h 130;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO77_OFFSET = 27'h 134;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO78_OFFSET = 27'h 138;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO79_OFFSET = 27'h 13c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO80_OFFSET = 27'h 140;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO81_OFFSET = 27'h 144;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO82_OFFSET = 27'h 148;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO83_OFFSET = 27'h 14c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO84_OFFSET = 27'h 150;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO85_OFFSET = 27'h 154;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO86_OFFSET = 27'h 158;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO87_OFFSET = 27'h 15c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO88_OFFSET = 27'h 160;
  parameter logic [BlockAw-1:0] RV_PLIC_IP_0_OFFSET = 27'h 1000;
  parameter logic [BlockAw-1:0] RV_PLIC_IP_1_OFFSET = 27'h 1004;
  parameter logic [BlockAw-1:0] RV_PLIC_IP_2_OFFSET = 27'h 1008;
  parameter logic [BlockAw-1:0] RV_PLIC_IE0_0_OFFSET = 27'h 2000;
  parameter logic [BlockAw-1:0] RV_PLIC_IE0_1_OFFSET = 27'h 2004;
  parameter logic [BlockAw-1:0] RV_PLIC_IE0_2_OFFSET = 27'h 2008;
  parameter logic [BlockAw-1:0] RV_PLIC_THRESHOLD0_OFFSET = 27'h 200000;
  parameter logic [BlockAw-1:0] RV_PLIC_CC0_OFFSET = 27'h 200004;
  parameter logic [BlockAw-1:0] RV_PLIC_MSIP0_OFFSET = 27'h 4000000;
  parameter logic [BlockAw-1:0] RV_PLIC_ALERT_TEST_OFFSET = 27'h 4004000;

  // Reset values for hwext registers and their fields
  parameter logic [6:0] RV_PLIC_CC0_RESVAL = 7'h 0;
  parameter logic [0:0] RV_PLIC_ALERT_TEST_RESVAL = 1'h 0;

  // Register index
  typedef enum int {
    RV_PLIC_PRIO0,
    RV_PLIC_PRIO1,
    RV_PLIC_PRIO2,
    RV_PLIC_PRIO3,
    RV_PLIC_PRIO4,
    RV_PLIC_PRIO5,
    RV_PLIC_PRIO6,
    RV_PLIC_PRIO7,
    RV_PLIC_PRIO8,
    RV_PLIC_PRIO9,
    RV_PLIC_PRIO10,
    RV_PLIC_PRIO11,
    RV_PLIC_PRIO12,
    RV_PLIC_PRIO13,
    RV_PLIC_PRIO14,
    RV_PLIC_PRIO15,
    RV_PLIC_PRIO16,
    RV_PLIC_PRIO17,
    RV_PLIC_PRIO18,
    RV_PLIC_PRIO19,
    RV_PLIC_PRIO20,
    RV_PLIC_PRIO21,
    RV_PLIC_PRIO22,
    RV_PLIC_PRIO23,
    RV_PLIC_PRIO24,
    RV_PLIC_PRIO25,
    RV_PLIC_PRIO26,
    RV_PLIC_PRIO27,
    RV_PLIC_PRIO28,
    RV_PLIC_PRIO29,
    RV_PLIC_PRIO30,
    RV_PLIC_PRIO31,
    RV_PLIC_PRIO32,
    RV_PLIC_PRIO33,
    RV_PLIC_PRIO34,
    RV_PLIC_PRIO35,
    RV_PLIC_PRIO36,
    RV_PLIC_PRIO37,
    RV_PLIC_PRIO38,
    RV_PLIC_PRIO39,
    RV_PLIC_PRIO40,
    RV_PLIC_PRIO41,
    RV_PLIC_PRIO42,
    RV_PLIC_PRIO43,
    RV_PLIC_PRIO44,
    RV_PLIC_PRIO45,
    RV_PLIC_PRIO46,
    RV_PLIC_PRIO47,
    RV_PLIC_PRIO48,
    RV_PLIC_PRIO49,
    RV_PLIC_PRIO50,
    RV_PLIC_PRIO51,
    RV_PLIC_PRIO52,
    RV_PLIC_PRIO53,
    RV_PLIC_PRIO54,
    RV_PLIC_PRIO55,
    RV_PLIC_PRIO56,
    RV_PLIC_PRIO57,
    RV_PLIC_PRIO58,
    RV_PLIC_PRIO59,
    RV_PLIC_PRIO60,
    RV_PLIC_PRIO61,
    RV_PLIC_PRIO62,
    RV_PLIC_PRIO63,
    RV_PLIC_PRIO64,
    RV_PLIC_PRIO65,
    RV_PLIC_PRIO66,
    RV_PLIC_PRIO67,
    RV_PLIC_PRIO68,
    RV_PLIC_PRIO69,
    RV_PLIC_PRIO70,
    RV_PLIC_PRIO71,
    RV_PLIC_PRIO72,
    RV_PLIC_PRIO73,
    RV_PLIC_PRIO74,
    RV_PLIC_PRIO75,
    RV_PLIC_PRIO76,
    RV_PLIC_PRIO77,
    RV_PLIC_PRIO78,
    RV_PLIC_PRIO79,
    RV_PLIC_PRIO80,
    RV_PLIC_PRIO81,
    RV_PLIC_PRIO82,
    RV_PLIC_PRIO83,
    RV_PLIC_PRIO84,
    RV_PLIC_PRIO85,
    RV_PLIC_PRIO86,
    RV_PLIC_PRIO87,
    RV_PLIC_PRIO88,
    RV_PLIC_IP_0,
    RV_PLIC_IP_1,
    RV_PLIC_IP_2,
    RV_PLIC_IE0_0,
    RV_PLIC_IE0_1,
    RV_PLIC_IE0_2,
    RV_PLIC_THRESHOLD0,
    RV_PLIC_CC0,
    RV_PLIC_MSIP0,
    RV_PLIC_ALERT_TEST
  } rv_plic_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] RV_PLIC_PERMIT [99] = '{
    4'b 0001, // index[ 0] RV_PLIC_PRIO0
    4'b 0001, // index[ 1] RV_PLIC_PRIO1
    4'b 0001, // index[ 2] RV_PLIC_PRIO2
    4'b 0001, // index[ 3] RV_PLIC_PRIO3
    4'b 0001, // index[ 4] RV_PLIC_PRIO4
    4'b 0001, // index[ 5] RV_PLIC_PRIO5
    4'b 0001, // index[ 6] RV_PLIC_PRIO6
    4'b 0001, // index[ 7] RV_PLIC_PRIO7
    4'b 0001, // index[ 8] RV_PLIC_PRIO8
    4'b 0001, // index[ 9] RV_PLIC_PRIO9
    4'b 0001, // index[10] RV_PLIC_PRIO10
    4'b 0001, // index[11] RV_PLIC_PRIO11
    4'b 0001, // index[12] RV_PLIC_PRIO12
    4'b 0001, // index[13] RV_PLIC_PRIO13
    4'b 0001, // index[14] RV_PLIC_PRIO14
    4'b 0001, // index[15] RV_PLIC_PRIO15
    4'b 0001, // index[16] RV_PLIC_PRIO16
    4'b 0001, // index[17] RV_PLIC_PRIO17
    4'b 0001, // index[18] RV_PLIC_PRIO18
    4'b 0001, // index[19] RV_PLIC_PRIO19
    4'b 0001, // index[20] RV_PLIC_PRIO20
    4'b 0001, // index[21] RV_PLIC_PRIO21
    4'b 0001, // index[22] RV_PLIC_PRIO22
    4'b 0001, // index[23] RV_PLIC_PRIO23
    4'b 0001, // index[24] RV_PLIC_PRIO24
    4'b 0001, // index[25] RV_PLIC_PRIO25
    4'b 0001, // index[26] RV_PLIC_PRIO26
    4'b 0001, // index[27] RV_PLIC_PRIO27
    4'b 0001, // index[28] RV_PLIC_PRIO28
    4'b 0001, // index[29] RV_PLIC_PRIO29
    4'b 0001, // index[30] RV_PLIC_PRIO30
    4'b 0001, // index[31] RV_PLIC_PRIO31
    4'b 0001, // index[32] RV_PLIC_PRIO32
    4'b 0001, // index[33] RV_PLIC_PRIO33
    4'b 0001, // index[34] RV_PLIC_PRIO34
    4'b 0001, // index[35] RV_PLIC_PRIO35
    4'b 0001, // index[36] RV_PLIC_PRIO36
    4'b 0001, // index[37] RV_PLIC_PRIO37
    4'b 0001, // index[38] RV_PLIC_PRIO38
    4'b 0001, // index[39] RV_PLIC_PRIO39
    4'b 0001, // index[40] RV_PLIC_PRIO40
    4'b 0001, // index[41] RV_PLIC_PRIO41
    4'b 0001, // index[42] RV_PLIC_PRIO42
    4'b 0001, // index[43] RV_PLIC_PRIO43
    4'b 0001, // index[44] RV_PLIC_PRIO44
    4'b 0001, // index[45] RV_PLIC_PRIO45
    4'b 0001, // index[46] RV_PLIC_PRIO46
    4'b 0001, // index[47] RV_PLIC_PRIO47
    4'b 0001, // index[48] RV_PLIC_PRIO48
    4'b 0001, // index[49] RV_PLIC_PRIO49
    4'b 0001, // index[50] RV_PLIC_PRIO50
    4'b 0001, // index[51] RV_PLIC_PRIO51
    4'b 0001, // index[52] RV_PLIC_PRIO52
    4'b 0001, // index[53] RV_PLIC_PRIO53
    4'b 0001, // index[54] RV_PLIC_PRIO54
    4'b 0001, // index[55] RV_PLIC_PRIO55
    4'b 0001, // index[56] RV_PLIC_PRIO56
    4'b 0001, // index[57] RV_PLIC_PRIO57
    4'b 0001, // index[58] RV_PLIC_PRIO58
    4'b 0001, // index[59] RV_PLIC_PRIO59
    4'b 0001, // index[60] RV_PLIC_PRIO60
    4'b 0001, // index[61] RV_PLIC_PRIO61
    4'b 0001, // index[62] RV_PLIC_PRIO62
    4'b 0001, // index[63] RV_PLIC_PRIO63
    4'b 0001, // index[64] RV_PLIC_PRIO64
    4'b 0001, // index[65] RV_PLIC_PRIO65
    4'b 0001, // index[66] RV_PLIC_PRIO66
    4'b 0001, // index[67] RV_PLIC_PRIO67
    4'b 0001, // index[68] RV_PLIC_PRIO68
    4'b 0001, // index[69] RV_PLIC_PRIO69
    4'b 0001, // index[70] RV_PLIC_PRIO70
    4'b 0001, // index[71] RV_PLIC_PRIO71
    4'b 0001, // index[72] RV_PLIC_PRIO72
    4'b 0001, // index[73] RV_PLIC_PRIO73
    4'b 0001, // index[74] RV_PLIC_PRIO74
    4'b 0001, // index[75] RV_PLIC_PRIO75
    4'b 0001, // index[76] RV_PLIC_PRIO76
    4'b 0001, // index[77] RV_PLIC_PRIO77
    4'b 0001, // index[78] RV_PLIC_PRIO78
    4'b 0001, // index[79] RV_PLIC_PRIO79
    4'b 0001, // index[80] RV_PLIC_PRIO80
    4'b 0001, // index[81] RV_PLIC_PRIO81
    4'b 0001, // index[82] RV_PLIC_PRIO82
    4'b 0001, // index[83] RV_PLIC_PRIO83
    4'b 0001, // index[84] RV_PLIC_PRIO84
    4'b 0001, // index[85] RV_PLIC_PRIO85
    4'b 0001, // index[86] RV_PLIC_PRIO86
    4'b 0001, // index[87] RV_PLIC_PRIO87
    4'b 0001, // index[88] RV_PLIC_PRIO88
    4'b 1111, // index[89] RV_PLIC_IP_0
    4'b 1111, // index[90] RV_PLIC_IP_1
    4'b 1111, // index[91] RV_PLIC_IP_2
    4'b 1111, // index[92] RV_PLIC_IE0_0
    4'b 1111, // index[93] RV_PLIC_IE0_1
    4'b 1111, // index[94] RV_PLIC_IE0_2
    4'b 0001, // index[95] RV_PLIC_THRESHOLD0
    4'b 0001, // index[96] RV_PLIC_CC0
    4'b 0001, // index[97] RV_PLIC_MSIP0
    4'b 0001  // index[98] RV_PLIC_ALERT_TEST
  };

endpackage