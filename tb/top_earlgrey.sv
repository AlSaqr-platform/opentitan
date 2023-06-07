// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// ------------------- W A R N I N G: A U T O - G E N E R A T E D   C O D E !! -------------------//
// PLEASE DO NOT HAND-EDIT THIS FILE. IT HAS BEEN AUTO-GENERATED WITH THE FOLLOWING COMMAND:
//
// util/topgen.py -t hw/top_earlgrey/data/top_earlgrey.hjson \
//                -o hw/top_earlgrey/ \
//                --rnd_cnst_seed 4881560218908238235

`include "prim_assert.sv"

module top_earlgrey #(
  // Manually defined parameters

  // Auto-inferred parameters
  // parameters for gpio
  parameter bit GpioGpioAsyncOn = 1,
  // parameters for pattgen
  // parameters for rv_timer
  // parameters for otp_ctrl
  parameter OtpCtrlMemInitFile = "/scratch/mciani/he-soc/hardware/working_dir/opentitan/hw/top_earlgrey/sw/tests/hello_test/otp-img.mem",
  // parameters for tlul2axi
  // parameters for lc_ctrl
  parameter logic [15:0] LcCtrlChipGen = 16'h 0000,
  parameter logic [15:0] LcCtrlChipRev = 16'h 0000,
  parameter logic [31:0] LcCtrlIdcodeValue = jtag_id_pkg::JTAG_IDCODE,
  // parameters for alert_handler
  // parameters for pwrmgr_aon
  // parameters for rstmgr_aon
  parameter bit SecRstmgrAonCheck = 1'b1,
  parameter int SecRstmgrAonMaxSyncDelay = 2,
  // parameters for clkmgr_aon
  // parameters for sysrst_ctrl_aon
  // parameters for pwm_aon
  // parameters for pinmux_aon
  parameter pinmux_pkg::target_cfg_t PinmuxAonTargetCfg = pinmux_pkg::DefaultTargetCfg,
  // parameters for aon_timer_aon
  // parameters for sram_ctrl_ret_aon
  parameter bit SramCtrlRetAonInstrExec = 0,
  // parameters for flash_ctrl
  parameter bit SecFlashCtrlScrambleEn = 1,
  parameter int FlashCtrlProgFifoDepth = 4,
  parameter int FlashCtrlRdFifoDepth = 16,
  // parameters for rv_dm
  parameter logic [31:0] RvDmIdcodeValue = jtag_id_pkg::JTAG_IDCODE,
  // parameters for rv_ot_plic
  // parameters for aes
  parameter bit SecAesMasking = 1,
  parameter aes_pkg::sbox_impl_e SecAesSBoxImpl = aes_pkg::SBoxImplDom,
  parameter int unsigned SecAesStartTriggerDelay = 0,
  parameter bit SecAesAllowForcingMasks = 1'b0,
  parameter bit SecAesSkipPRNGReseeding = 1'b0,
  // parameters for hmac
  // parameters for kmac
  parameter bit KmacEnMasking = 1,
  parameter int SecKmacCmdDelay = 0,
  parameter bit SecKmacIdleAcceptSwMsg = 0,
  // parameters for otbn
  parameter bit OtbnStub = 0,
  parameter otbn_pkg::regfile_e OtbnRegFile = otbn_pkg::RegFileFF,
  // parameters for keymgr
  parameter bit KeymgrKmacEnMasking = 1,
  // parameters for csrng
  parameter aes_pkg::sbox_impl_e CsrngSBoxImpl = aes_pkg::SBoxImplCanright,
  // parameters for entropy_src
  parameter bit EntropySrcStub = 0,
  // parameters for edn0
  // parameters for edn1
  // parameters for sram_ctrl_main
  parameter bit SramCtrlMainInstrExec = 1,
  // parameters for rom_ctrl
  parameter RomCtrlBootRomInitFile = "/scratch/mciani/he-soc/hardware/working_dir/opentitan/hw/top_earlgrey/sw/tests/hello_test/bootrom.vmem",
  parameter bit SecRomCtrlDisableScrambling = 1'b0,
  // parameters for rv_core_ibex
  parameter bit RvCoreIbexPMPEnable = 1,
  parameter int unsigned RvCoreIbexPMPGranularity = 0,
  parameter int unsigned RvCoreIbexPMPNumRegions = 16,
  parameter int unsigned RvCoreIbexMHPMCounterNum = 10,
  parameter int unsigned RvCoreIbexMHPMCounterWidth = 32,
  parameter bit RvCoreIbexRV32E = 0,
  parameter ibex_pkg::rv32m_e RvCoreIbexRV32M = ibex_pkg::RV32MSingleCycle,
  parameter ibex_pkg::rv32b_e RvCoreIbexRV32B = ibex_pkg::RV32BOTEarlGrey,
  parameter ibex_pkg::regfile_e RvCoreIbexRegFile = ibex_pkg::RegFileFF,
  parameter bit RvCoreIbexBranchTargetALU = 1,
  parameter bit RvCoreIbexWritebackStage = 1,
  parameter bit RvCoreIbexICache = 1,
  parameter bit RvCoreIbexICacheECC = 1,
  parameter bit RvCoreIbexICacheScramble = 1,
  parameter bit RvCoreIbexBranchPredictor = 0,
  parameter bit RvCoreIbexDbgTriggerEn = 1,
  parameter int RvCoreIbexDbgHwBreakNum = 4,
  parameter bit RvCoreIbexSecureIbex = 1,
  parameter int unsigned RvCoreIbexDmHaltAddr =
      tl_main_pkg::ADDR_SPACE_RV_DM__MEM + dm_ot::HaltAddress[31:0],
  parameter int unsigned RvCoreIbexDmExceptionAddr =
      tl_main_pkg::ADDR_SPACE_RV_DM__MEM + dm_ot::ExceptionAddress[31:0],
  parameter bit RvCoreIbexPipeLine = 0
) (
  // Multiplexed I/O
  input        [46:0] mio_in_i,
  output logic [46:0] mio_out_o,
  output logic [46:0] mio_oe_o,
  // Dedicated I/O
  input        [1:0]  dio_in_i,
  output logic [1:0]  dio_out_o,
  output logic [1:0]  dio_oe_o,

  // pad attributes to padring
  output prim_pad_wrapper_pkg::pad_attr_t [pinmux_reg_pkg::NMioPads-1:0] mio_attr_o,
  output prim_pad_wrapper_pkg::pad_attr_t [pinmux_reg_pkg::NDioPads-1:0] dio_attr_o,


  // Inter-module Signal External type
  output tlul2axi_pkg::slv_req_t       axi_req_o,
  input  tlul2axi_pkg::slv_rsp_t       axi_rsp_i,
  input  jtag_pkg::jtag_req_t       jtag_req_i,
  output jtag_pkg::jtag_rsp_t       jtag_rsp_o,
  output prim_mubi_pkg::mubi4_t       clk_main_jitter_en_o,
  output prim_mubi_pkg::mubi4_t       io_clk_byp_req_o,
  input  prim_mubi_pkg::mubi4_t       io_clk_byp_ack_i,
  output prim_mubi_pkg::mubi4_t       all_clk_byp_req_o,
  input  prim_mubi_pkg::mubi4_t       all_clk_byp_ack_i,
  output prim_mubi_pkg::mubi4_t       hi_speed_sel_o,
  input  prim_mubi_pkg::mubi4_t       div_step_down_req_i,
  input  prim_mubi_pkg::mubi4_t       calib_rdy_i,


  // All externally supplied clocks
  input clk_main_i,
  input clk_io_i,
  input clk_aon_i,
  
  input logic irq_ibex_i,
  input logic cfi_doorbell_i,
  input logic [1:0] por_n_i,

  // All clocks forwarded to ast
  output clkmgr_pkg::clkmgr_out_t clks_ast_o,
  output rstmgr_pkg::rstmgr_out_t rsts_ast_o,

  input                      scan_rst_ni, // reset used for test mode
  input                      scan_en_i,
  input prim_mubi_pkg::mubi4_t scanmode_i   // lc_ctrl_pkg::On for Scan
);

  import tlul_pkg::*;
  import top_pkg::*;
  import tl_main_pkg::*;
  import top_earlgrey_pkg::*;
  // Compile-time random constants
  import top_earlgrey_rnd_cnst_pkg::*;

  // Signals
  logic [40:0] mio_p2d;
  logic [49:0] mio_d2p;
  logic [49:0] mio_en_d2p;
  logic [1:0] dio_p2d;
  logic [1:0] dio_d2p;
  logic [1:0] dio_en_d2p;
  // gpio
  logic [31:0] cio_gpio_gpio_p2d;
  logic [31:0] cio_gpio_gpio_d2p;
  logic [31:0] cio_gpio_gpio_en_d2p;
  // pattgen
  logic        cio_pattgen_pda0_tx_d2p;
  logic        cio_pattgen_pda0_tx_en_d2p;
  logic        cio_pattgen_pcl0_tx_d2p;
  logic        cio_pattgen_pcl0_tx_en_d2p;
  logic        cio_pattgen_pda1_tx_d2p;
  logic        cio_pattgen_pda1_tx_en_d2p;
  logic        cio_pattgen_pcl1_tx_d2p;
  logic        cio_pattgen_pcl1_tx_en_d2p;
  // rv_timer
  // otp_ctrl
  logic [7:0]  cio_otp_ctrl_test_d2p;
  logic [7:0]  cio_otp_ctrl_test_en_d2p;
  // tlul2axi
  // lc_ctrl
  // alert_handler
  // pwrmgr_aon
  // rstmgr_aon
  // clkmgr_aon
  // sysrst_ctrl_aon
  logic        cio_sysrst_ctrl_aon_ac_present_p2d;
  logic        cio_sysrst_ctrl_aon_key0_in_p2d;
  logic        cio_sysrst_ctrl_aon_key1_in_p2d;
  logic        cio_sysrst_ctrl_aon_key2_in_p2d;
  logic        cio_sysrst_ctrl_aon_pwrb_in_p2d;
  logic        cio_sysrst_ctrl_aon_lid_open_p2d;
  logic        cio_sysrst_ctrl_aon_ec_rst_l_p2d;
  logic        cio_sysrst_ctrl_aon_flash_wp_l_p2d;
  logic        cio_sysrst_ctrl_aon_bat_disable_d2p;
  logic        cio_sysrst_ctrl_aon_bat_disable_en_d2p;
  logic        cio_sysrst_ctrl_aon_key0_out_d2p;
  logic        cio_sysrst_ctrl_aon_key0_out_en_d2p;
  logic        cio_sysrst_ctrl_aon_key1_out_d2p;
  logic        cio_sysrst_ctrl_aon_key1_out_en_d2p;
  logic        cio_sysrst_ctrl_aon_key2_out_d2p;
  logic        cio_sysrst_ctrl_aon_key2_out_en_d2p;
  logic        cio_sysrst_ctrl_aon_pwrb_out_d2p;
  logic        cio_sysrst_ctrl_aon_pwrb_out_en_d2p;
  logic        cio_sysrst_ctrl_aon_z3_wakeup_d2p;
  logic        cio_sysrst_ctrl_aon_z3_wakeup_en_d2p;
  logic        cio_sysrst_ctrl_aon_ec_rst_l_d2p;
  logic        cio_sysrst_ctrl_aon_ec_rst_l_en_d2p;
  logic        cio_sysrst_ctrl_aon_flash_wp_l_d2p;
  logic        cio_sysrst_ctrl_aon_flash_wp_l_en_d2p;
  // pwm_aon
  logic [5:0]  cio_pwm_aon_pwm_d2p;
  logic [5:0]  cio_pwm_aon_pwm_en_d2p;
  // pinmux_aon
  // aon_timer_aon
  // sram_ctrl_ret_aon
  // flash_ctrl
  logic        cio_flash_ctrl_tck_p2d;
  logic        cio_flash_ctrl_tms_p2d;
  logic        cio_flash_ctrl_tdi_p2d;
  logic        cio_flash_ctrl_tdo_d2p;
  logic        cio_flash_ctrl_tdo_en_d2p;
  // rv_dm
  // rv_ot_plic
  // aes
  // hmac
  // kmac
  // otbn
  // keymgr
  // csrng
  // entropy_src
  // edn0
  // edn1
  // sram_ctrl_main
  // rom_ctrl
  // rv_core_ibex


  logic [71:0]  intr_vector;
  // Interrupt source list
  logic [31:0] intr_gpio_gpio;
  logic intr_pattgen_done_ch0;
  logic intr_pattgen_done_ch1;
  logic intr_rv_timer_timer_expired_hart0_timer0;
  logic intr_otp_ctrl_otp_operation_done;
  logic intr_otp_ctrl_otp_error;
  logic intr_alert_handler_classa;
  logic intr_alert_handler_classb;
  logic intr_alert_handler_classc;
  logic intr_alert_handler_classd;
  logic intr_pwrmgr_aon_wakeup;
  logic intr_sysrst_ctrl_aon_event_detected;
  logic intr_aon_timer_aon_wkup_timer_expired;
  logic intr_aon_timer_aon_wdog_timer_bark;
  logic intr_flash_ctrl_prog_empty;
  logic intr_flash_ctrl_prog_lvl;
  logic intr_flash_ctrl_rd_full;
  logic intr_flash_ctrl_rd_lvl;
  logic intr_flash_ctrl_op_done;
  logic intr_flash_ctrl_corr_err;
  logic intr_hmac_hmac_done;
  logic intr_hmac_fifo_empty;
  logic intr_hmac_hmac_err;
  logic intr_kmac_kmac_done;
  logic intr_kmac_fifo_empty;
  logic intr_kmac_kmac_err;
  logic intr_otbn_done;
  logic intr_keymgr_op_done;
  logic intr_csrng_cs_cmd_req_done;
  logic intr_csrng_cs_entropy_req;
  logic intr_csrng_cs_hw_inst_exc;
  logic intr_csrng_cs_fatal_err;
  logic intr_entropy_src_es_entropy_valid;
  logic intr_entropy_src_es_health_test_failed;
  logic intr_entropy_src_es_observe_fifo_ready;
  logic intr_entropy_src_es_fatal_err;
  logic intr_edn0_edn_cmd_req_done;
  logic intr_edn0_edn_fatal_err;
  logic intr_edn1_edn_cmd_req_done;
  logic intr_edn1_edn_fatal_err;

  // Alert list
  prim_alert_pkg::alert_tx_t [alert_pkg::NAlerts-1:0]  alert_tx;
  prim_alert_pkg::alert_rx_t [alert_pkg::NAlerts-1:0]  alert_rx;


  // define inter-module signals
  alert_pkg::alert_crashdump_t       alert_handler_crashdump;
  prim_esc_pkg::esc_rx_t [3:0] alert_handler_esc_rx;
  prim_esc_pkg::esc_tx_t [3:0] alert_handler_esc_tx;
  logic       aon_timer_aon_nmi_wdog_timer_bark;
  csrng_pkg::csrng_req_t [1:0] csrng_csrng_cmd_req;
  csrng_pkg::csrng_rsp_t [1:0] csrng_csrng_cmd_rsp;
  entropy_src_pkg::entropy_src_hw_if_req_t       csrng_entropy_src_hw_if_req;
  entropy_src_pkg::entropy_src_hw_if_rsp_t       csrng_entropy_src_hw_if_rsp;
  entropy_src_pkg::cs_aes_halt_req_t       csrng_cs_aes_halt_req;
  entropy_src_pkg::cs_aes_halt_rsp_t       csrng_cs_aes_halt_rsp;
  flash_ctrl_pkg::keymgr_flash_t       flash_ctrl_keymgr;
  otp_ctrl_pkg::flash_otp_key_req_t       flash_ctrl_otp_req;
  otp_ctrl_pkg::flash_otp_key_rsp_t       flash_ctrl_otp_rsp;
  lc_ctrl_pkg::lc_flash_rma_seed_t       flash_ctrl_rma_seed;
  otp_ctrl_pkg::sram_otp_key_req_t [2:0] otp_ctrl_sram_otp_key_req;
  otp_ctrl_pkg::sram_otp_key_rsp_t [2:0] otp_ctrl_sram_otp_key_rsp;
  pwrmgr_pkg::pwr_flash_t       pwrmgr_aon_pwr_flash;
  pwrmgr_pkg::pwr_rst_req_t       pwrmgr_aon_pwr_rst_req;
  pwrmgr_pkg::pwr_rst_rsp_t       pwrmgr_aon_pwr_rst_rsp;
  pwrmgr_pkg::pwr_clk_req_t       pwrmgr_aon_pwr_clk_req;
  pwrmgr_pkg::pwr_clk_rsp_t       pwrmgr_aon_pwr_clk_rsp;
  pwrmgr_pkg::pwr_otp_req_t       pwrmgr_aon_pwr_otp_req;
  pwrmgr_pkg::pwr_otp_rsp_t       pwrmgr_aon_pwr_otp_rsp;
  pwrmgr_pkg::pwr_lc_req_t       pwrmgr_aon_pwr_lc_req;
  pwrmgr_pkg::pwr_lc_rsp_t       pwrmgr_aon_pwr_lc_rsp;
  logic       pwrmgr_aon_strap;
  logic       pwrmgr_aon_low_power;
  lc_ctrl_pkg::lc_tx_t       pwrmgr_aon_fetch_en;
  rom_ctrl_pkg::pwrmgr_data_t       rom_ctrl_pwrmgr_data;
  rom_ctrl_pkg::keymgr_data_t       rom_ctrl_keymgr_data;
  lc_ctrl_pkg::lc_tx_t       lc_ctrl_lc_flash_rma_req;
  lc_ctrl_pkg::lc_tx_t       flash_ctrl_rma_ack;
  lc_ctrl_pkg::lc_tx_t       otbn_lc_rma_ack;
  edn_pkg::edn_req_t [7:0] edn0_edn_req;
  edn_pkg::edn_rsp_t [7:0] edn0_edn_rsp;
  edn_pkg::edn_req_t [7:0] edn1_edn_req;
  edn_pkg::edn_rsp_t [7:0] edn1_edn_rsp;
  otp_ctrl_pkg::otbn_otp_key_req_t       otp_ctrl_otbn_otp_key_req;
  otp_ctrl_pkg::otbn_otp_key_rsp_t       otp_ctrl_otbn_otp_key_rsp;
  otp_ctrl_pkg::otp_keymgr_key_t       otp_ctrl_otp_keymgr_key;
  keymgr_pkg::hw_key_req_t       keymgr_aes_key;
  keymgr_pkg::hw_key_req_t       keymgr_kmac_key;
  keymgr_pkg::otbn_key_req_t       keymgr_otbn_key;
  kmac_pkg::app_req_t [2:0] kmac_app_req;
  kmac_pkg::app_rsp_t [2:0] kmac_app_rsp;
  logic       kmac_en_masking;
  prim_mubi_pkg::mubi4_t [3:0] clkmgr_aon_idle;
  jtag_pkg::jtag_req_t       pinmux_aon_lc_jtag_req;
  jtag_pkg::jtag_rsp_t       pinmux_aon_lc_jtag_rsp;
  lc_ctrl_pkg::lc_tx_t       pinmux_aon_pinmux_hw_debug_en;
  otp_ctrl_pkg::otp_lc_data_t       otp_ctrl_otp_lc_data;
  otp_ctrl_pkg::lc_otp_program_req_t       lc_ctrl_lc_otp_program_req;
  otp_ctrl_pkg::lc_otp_program_rsp_t       lc_ctrl_lc_otp_program_rsp;
  otp_ctrl_pkg::lc_otp_vendor_test_req_t       lc_ctrl_lc_otp_vendor_test_req;
  otp_ctrl_pkg::lc_otp_vendor_test_rsp_t       lc_ctrl_lc_otp_vendor_test_rsp;
  lc_ctrl_pkg::lc_keymgr_div_t       lc_ctrl_lc_keymgr_div;
  lc_ctrl_pkg::lc_tx_t       lc_ctrl_lc_dft_en;
  lc_ctrl_pkg::lc_tx_t       lc_ctrl_lc_nvm_debug_en;
  lc_ctrl_pkg::lc_tx_t       lc_ctrl_lc_hw_debug_en;
  lc_ctrl_pkg::lc_tx_t       lc_ctrl_lc_cpu_en;
  lc_ctrl_pkg::lc_tx_t       lc_ctrl_lc_keymgr_en;
  lc_ctrl_pkg::lc_tx_t       lc_ctrl_lc_escalate_en;
  lc_ctrl_pkg::lc_tx_t       lc_ctrl_lc_check_byp_en;
  lc_ctrl_pkg::lc_tx_t       lc_ctrl_lc_clk_byp_req;
  lc_ctrl_pkg::lc_tx_t       lc_ctrl_lc_clk_byp_ack;
  lc_ctrl_pkg::lc_tx_t       lc_ctrl_lc_creator_seed_sw_rw_en;
  lc_ctrl_pkg::lc_tx_t       lc_ctrl_lc_owner_seed_sw_rw_en;
  lc_ctrl_pkg::lc_tx_t       lc_ctrl_lc_iso_part_sw_rd_en;
  lc_ctrl_pkg::lc_tx_t       lc_ctrl_lc_iso_part_sw_wr_en;
  lc_ctrl_pkg::lc_tx_t       lc_ctrl_lc_seed_hw_rd_en;
  logic       rv_ot_plic_msip;
  logic       rv_ot_plic_irq;
  logic       rv_dm_debug_req;
  rv_core_ibex_pkg::cpu_crash_dump_t       rv_core_ibex_crash_dump;
  pwrmgr_pkg::pwr_cpu_t       rv_core_ibex_pwrmgr;
  logic       rv_dm_ndmreset_req;
  prim_mubi_pkg::mubi4_t       rstmgr_aon_sw_rst_req;
  logic [3:0] pwrmgr_aon_wakeups;
  logic [1:0] pwrmgr_aon_rstreqs;
  tlul_pkg::tl_h2d_t       main_tl_rv_core_ibex__corei_req;
  tlul_pkg::tl_d2h_t       main_tl_rv_core_ibex__corei_rsp;
  tlul_pkg::tl_h2d_t       main_tl_rv_core_ibex__cored_req;
  tlul_pkg::tl_d2h_t       main_tl_rv_core_ibex__cored_rsp;
  tlul_pkg::tl_h2d_t       main_tl_rv_dm__sba_req;
  tlul_pkg::tl_d2h_t       main_tl_rv_dm__sba_rsp;
  tlul_pkg::tl_h2d_t       rv_dm_regs_tl_d_req;
  tlul_pkg::tl_d2h_t       rv_dm_regs_tl_d_rsp;
  tlul_pkg::tl_h2d_t       rv_dm_mem_tl_d_req;
  tlul_pkg::tl_d2h_t       rv_dm_mem_tl_d_rsp;
  tlul_pkg::tl_h2d_t       rom_ctrl_rom_tl_req;
  tlul_pkg::tl_d2h_t       rom_ctrl_rom_tl_rsp;
  tlul_pkg::tl_h2d_t       rom_ctrl_regs_tl_req;
  tlul_pkg::tl_d2h_t       rom_ctrl_regs_tl_rsp;
  tlul_pkg::tl_h2d_t       main_tl_peri_req;
  tlul_pkg::tl_d2h_t       main_tl_peri_rsp;
  tlul_pkg::tl_h2d_t       tlul2axi_tl_req;
  tlul_pkg::tl_d2h_t       tlul2axi_tl_rsp;
  tlul_pkg::tl_h2d_t       flash_ctrl_core_tl_req;
  tlul_pkg::tl_d2h_t       flash_ctrl_core_tl_rsp;
  tlul_pkg::tl_h2d_t       flash_ctrl_prim_tl_req;
  tlul_pkg::tl_d2h_t       flash_ctrl_prim_tl_rsp;
  tlul_pkg::tl_h2d_t       flash_ctrl_mem_tl_req;
  tlul_pkg::tl_d2h_t       flash_ctrl_mem_tl_rsp;
  tlul_pkg::tl_h2d_t       hmac_tl_req;
  tlul_pkg::tl_d2h_t       hmac_tl_rsp;
  tlul_pkg::tl_h2d_t       kmac_tl_req;
  tlul_pkg::tl_d2h_t       kmac_tl_rsp;
  tlul_pkg::tl_h2d_t       aes_tl_req;
  tlul_pkg::tl_d2h_t       aes_tl_rsp;
  tlul_pkg::tl_h2d_t       entropy_src_tl_req;
  tlul_pkg::tl_d2h_t       entropy_src_tl_rsp;
  tlul_pkg::tl_h2d_t       csrng_tl_req;
  tlul_pkg::tl_d2h_t       csrng_tl_rsp;
  tlul_pkg::tl_h2d_t       edn0_tl_req;
  tlul_pkg::tl_d2h_t       edn0_tl_rsp;
  tlul_pkg::tl_h2d_t       edn1_tl_req;
  tlul_pkg::tl_d2h_t       edn1_tl_rsp;
  tlul_pkg::tl_h2d_t       rv_ot_plic_tl_req;
  tlul_pkg::tl_d2h_t       rv_ot_plic_tl_rsp;
  tlul_pkg::tl_h2d_t       otbn_tl_req;
  tlul_pkg::tl_d2h_t       otbn_tl_rsp;
  tlul_pkg::tl_h2d_t       keymgr_tl_req;
  tlul_pkg::tl_d2h_t       keymgr_tl_rsp;
  tlul_pkg::tl_h2d_t       rv_core_ibex_cfg_tl_d_req;
  tlul_pkg::tl_d2h_t       rv_core_ibex_cfg_tl_d_rsp;
  tlul_pkg::tl_h2d_t       sram_ctrl_main_regs_tl_req;
  tlul_pkg::tl_d2h_t       sram_ctrl_main_regs_tl_rsp;
  tlul_pkg::tl_h2d_t       sram_ctrl_main_ram_tl_req;
  tlul_pkg::tl_d2h_t       sram_ctrl_main_ram_tl_rsp;
  tlul_pkg::tl_h2d_t       pattgen_tl_req;
  tlul_pkg::tl_d2h_t       pattgen_tl_rsp;
  tlul_pkg::tl_h2d_t       pwm_aon_tl_req;
  tlul_pkg::tl_d2h_t       pwm_aon_tl_rsp;
  tlul_pkg::tl_h2d_t       gpio_tl_req;
  tlul_pkg::tl_d2h_t       gpio_tl_rsp;
  tlul_pkg::tl_h2d_t       rv_timer_tl_req;
  tlul_pkg::tl_d2h_t       rv_timer_tl_rsp;
  tlul_pkg::tl_h2d_t       pwrmgr_aon_tl_req;
  tlul_pkg::tl_d2h_t       pwrmgr_aon_tl_rsp;
  tlul_pkg::tl_h2d_t       rstmgr_aon_tl_req;
  tlul_pkg::tl_d2h_t       rstmgr_aon_tl_rsp;
  tlul_pkg::tl_h2d_t       clkmgr_aon_tl_req;
  tlul_pkg::tl_d2h_t       clkmgr_aon_tl_rsp;
  tlul_pkg::tl_h2d_t       pinmux_aon_tl_req;
  tlul_pkg::tl_d2h_t       pinmux_aon_tl_rsp;
  tlul_pkg::tl_h2d_t       otp_ctrl_core_tl_req;
  tlul_pkg::tl_d2h_t       otp_ctrl_core_tl_rsp;
  tlul_pkg::tl_h2d_t       otp_ctrl_prim_tl_req;
  tlul_pkg::tl_d2h_t       otp_ctrl_prim_tl_rsp;
  tlul_pkg::tl_h2d_t       lc_ctrl_tl_req;
  tlul_pkg::tl_d2h_t       lc_ctrl_tl_rsp;
  tlul_pkg::tl_h2d_t       alert_handler_tl_req;
  tlul_pkg::tl_d2h_t       alert_handler_tl_rsp;
  tlul_pkg::tl_h2d_t       sram_ctrl_ret_aon_regs_tl_req;
  tlul_pkg::tl_d2h_t       sram_ctrl_ret_aon_regs_tl_rsp;
  tlul_pkg::tl_h2d_t       sram_ctrl_ret_aon_ram_tl_req;
  tlul_pkg::tl_d2h_t       sram_ctrl_ret_aon_ram_tl_rsp;
  tlul_pkg::tl_h2d_t       aon_timer_aon_tl_req;
  tlul_pkg::tl_d2h_t       aon_timer_aon_tl_rsp;
  tlul_pkg::tl_h2d_t       sysrst_ctrl_aon_tl_req;
  tlul_pkg::tl_d2h_t       sysrst_ctrl_aon_tl_rsp;
  clkmgr_pkg::clkmgr_out_t       clkmgr_aon_clocks;
  clkmgr_pkg::clkmgr_cg_en_t       clkmgr_aon_cg_en;
  rstmgr_pkg::rstmgr_out_t       rstmgr_aon_resets;
  rstmgr_pkg::rstmgr_rst_en_t       rstmgr_aon_rst_en;
  logic       rv_core_ibex_irq_timer;
  logic [31:0] rv_core_ibex_hart_id;
  logic [31:0] rv_core_ibex_boot_addr;
  jtag_pkg::jtag_req_t       pinmux_aon_dft_jtag_req;
  jtag_pkg::jtag_rsp_t       pinmux_aon_dft_jtag_rsp;
  otp_ctrl_part_pkg::otp_hw_cfg_t       otp_ctrl_otp_hw_cfg;
  prim_mubi_pkg::mubi8_t       csrng_otp_en_csrng_sw_app_read;
  prim_mubi_pkg::mubi8_t       entropy_src_otp_en_entropy_src_fw_read;
  prim_mubi_pkg::mubi8_t       entropy_src_otp_en_entropy_src_fw_over;
  otp_ctrl_pkg::otp_device_id_t       lc_ctrl_otp_device_id;
  otp_ctrl_pkg::otp_manuf_state_t       lc_ctrl_otp_manuf_state;
  otp_ctrl_pkg::otp_device_id_t       keymgr_otp_device_id;
  prim_mubi_pkg::mubi8_t       sram_ctrl_main_otp_en_sram_ifetch;

  // define mixed connection to port

  // define partial inter-module tie-off
  edn_pkg::edn_rsp_t unused_edn0_edn_rsp7;
  edn_pkg::edn_rsp_t unused_edn1_edn_rsp1;
  edn_pkg::edn_rsp_t unused_edn1_edn_rsp2;
  edn_pkg::edn_rsp_t unused_edn1_edn_rsp3;
  edn_pkg::edn_rsp_t unused_edn1_edn_rsp4;
  edn_pkg::edn_rsp_t unused_edn1_edn_rsp5;
  edn_pkg::edn_rsp_t unused_edn1_edn_rsp6;
  edn_pkg::edn_rsp_t unused_edn1_edn_rsp7;

  // assign partial inter-module tie-off
  assign unused_edn0_edn_rsp7 = edn0_edn_rsp[7];
  assign unused_edn1_edn_rsp1 = edn1_edn_rsp[1];
  assign unused_edn1_edn_rsp2 = edn1_edn_rsp[2];
  assign unused_edn1_edn_rsp3 = edn1_edn_rsp[3];
  assign unused_edn1_edn_rsp4 = edn1_edn_rsp[4];
  assign unused_edn1_edn_rsp5 = edn1_edn_rsp[5];
  assign unused_edn1_edn_rsp6 = edn1_edn_rsp[6];
  assign unused_edn1_edn_rsp7 = edn1_edn_rsp[7];
  assign edn0_edn_req[7] = '0;
  assign edn1_edn_req[1] = '0;
  assign edn1_edn_req[2] = '0;
  assign edn1_edn_req[3] = '0;
  assign edn1_edn_req[4] = '0;
  assign edn1_edn_req[5] = '0;
  assign edn1_edn_req[6] = '0;
  assign edn1_edn_req[7] = '0;


  // OTP HW_CFG Broadcast signals.
  // TODO(#6713): The actual struct breakout and mapping currently needs to
  // be performed by hand.
  assign csrng_otp_en_csrng_sw_app_read = otp_ctrl_otp_hw_cfg.data.en_csrng_sw_app_read;
  assign entropy_src_otp_en_entropy_src_fw_read = otp_ctrl_otp_hw_cfg.data.en_entropy_src_fw_read;
  assign entropy_src_otp_en_entropy_src_fw_over = otp_ctrl_otp_hw_cfg.data.en_entropy_src_fw_over;
  assign sram_ctrl_main_otp_en_sram_ifetch = otp_ctrl_otp_hw_cfg.data.en_sram_ifetch;
  assign lc_ctrl_otp_device_id = otp_ctrl_otp_hw_cfg.data.device_id;
  assign lc_ctrl_otp_manuf_state = otp_ctrl_otp_hw_cfg.data.manuf_state;
  assign keymgr_otp_device_id = otp_ctrl_otp_hw_cfg.data.device_id;

  logic unused_otp_hw_cfg_bits;
  assign unused_otp_hw_cfg_bits = ^{
    otp_ctrl_otp_hw_cfg.valid,
    otp_ctrl_otp_hw_cfg.data.hw_cfg_digest,
    otp_ctrl_otp_hw_cfg.data.unallocated
  };

  // See #7978 This below is a hack.
  // This is because ast is a comportable-like module that sits outside
  // of top_earlgrey's boundary.
  assign clks_ast_o = clkmgr_aon_clocks;
  assign rsts_ast_o = rstmgr_aon_resets;

  // ibex specific assignments
  // TODO: This should be further automated in the future.
  assign rv_core_ibex_irq_timer = intr_rv_timer_timer_expired_hart0_timer0;
  assign rv_core_ibex_hart_id = '0;

  assign rv_core_ibex_boot_addr = ADDR_SPACE_ROM_CTRL__ROM;


  // Struct breakout module tool-inserted DFT TAP signals
  pinmux_jtag_breakout u_dft_tap_breakout (
    .req_i    (pinmux_aon_dft_jtag_req),
    .rsp_o    (pinmux_aon_dft_jtag_rsp),
    .tck_o    (),
    .trst_no  (),
    .tms_o    (),
    .tdi_o    (),
    .tdo_i    (1'b0),
    .tdo_oe_i (1'b0)
  );

  // Wire up alert handler LPGs
  prim_mubi_pkg::mubi4_t [alert_pkg::NLpg-1:0] lpg_cg_en;
  prim_mubi_pkg::mubi4_t [alert_pkg::NLpg-1:0] lpg_rst_en;


  // peri_lc_io_div4_0
  assign lpg_cg_en[0] = clkmgr_aon_cg_en.io_div4_peri;
  assign lpg_rst_en[0] = rstmgr_aon_rst_en.lc_io_div4[rstmgr_pkg::Domain0Sel];
  // timers_lc_io_div4_0
  assign lpg_cg_en[1] = clkmgr_aon_cg_en.io_div4_timers;
  assign lpg_rst_en[1] = rstmgr_aon_rst_en.lc_io_div4[rstmgr_pkg::Domain0Sel];
  // secure_lc_io_div4_0
  assign lpg_cg_en[2] = clkmgr_aon_cg_en.io_div4_secure;
  assign lpg_rst_en[2] = rstmgr_aon_rst_en.lc_io_div4[rstmgr_pkg::Domain0Sel];
  // powerup_por_io_div4_Aon
  assign lpg_cg_en[3] = clkmgr_aon_cg_en.io_div4_powerup;
  assign lpg_rst_en[3] = rstmgr_aon_rst_en.por_io_div4[rstmgr_pkg::DomainAonSel];
  // powerup_lc_io_div4_Aon
  assign lpg_cg_en[4] = clkmgr_aon_cg_en.io_div4_powerup;
  assign lpg_rst_en[4] = rstmgr_aon_rst_en.lc_io_div4[rstmgr_pkg::DomainAonSel];
  // secure_lc_io_div4_Aon
  assign lpg_cg_en[5] = clkmgr_aon_cg_en.io_div4_secure;
  assign lpg_rst_en[5] = rstmgr_aon_rst_en.lc_io_div4[rstmgr_pkg::DomainAonSel];
  // peri_lc_io_div4_Aon
  assign lpg_cg_en[6] = clkmgr_aon_cg_en.io_div4_peri;
  assign lpg_rst_en[6] = rstmgr_aon_rst_en.lc_io_div4[rstmgr_pkg::DomainAonSel];
  // timers_lc_io_div4_Aon
  assign lpg_cg_en[7] = clkmgr_aon_cg_en.io_div4_timers;
  assign lpg_rst_en[7] = rstmgr_aon_rst_en.lc_io_div4[rstmgr_pkg::DomainAonSel];
  // infra_lc_io_div4_Aon
  assign lpg_cg_en[8] = clkmgr_aon_cg_en.io_div4_infra;
  assign lpg_rst_en[8] = rstmgr_aon_rst_en.lc_io_div4[rstmgr_pkg::DomainAonSel];
  // infra_lc_0
  assign lpg_cg_en[9] = clkmgr_aon_cg_en.main_infra;
  assign lpg_rst_en[9] = rstmgr_aon_rst_en.lc[rstmgr_pkg::Domain0Sel];
  // infra_sys_0
  assign lpg_cg_en[10] = clkmgr_aon_cg_en.main_infra;
  assign lpg_rst_en[10] = rstmgr_aon_rst_en.sys[rstmgr_pkg::Domain0Sel];
  // secure_lc_0
  assign lpg_cg_en[11] = clkmgr_aon_cg_en.main_secure;
  assign lpg_rst_en[11] = rstmgr_aon_rst_en.lc[rstmgr_pkg::Domain0Sel];
  // aes_trans_lc_0
  assign lpg_cg_en[12] = clkmgr_aon_cg_en.main_aes;
  assign lpg_rst_en[12] = rstmgr_aon_rst_en.lc[rstmgr_pkg::Domain0Sel];
  // hmac_trans_lc_0
  assign lpg_cg_en[13] = clkmgr_aon_cg_en.main_hmac;
  assign lpg_rst_en[13] = rstmgr_aon_rst_en.lc[rstmgr_pkg::Domain0Sel];
  // kmac_trans_lc_0
  assign lpg_cg_en[14] = clkmgr_aon_cg_en.main_kmac;
  assign lpg_rst_en[14] = rstmgr_aon_rst_en.lc[rstmgr_pkg::Domain0Sel];
  // otbn_trans_lc_0
  assign lpg_cg_en[15] = clkmgr_aon_cg_en.main_otbn;
  assign lpg_rst_en[15] = rstmgr_aon_rst_en.lc[rstmgr_pkg::Domain0Sel];

// tie-off unused connections
//VCS coverage off
// pragma coverage off
    prim_mubi_pkg::mubi4_t unused_cg_en_0;
    assign unused_cg_en_0 = clkmgr_aon_cg_en.aon_powerup;
    prim_mubi_pkg::mubi4_t unused_cg_en_1;
    assign unused_cg_en_1 = clkmgr_aon_cg_en.main_powerup;
    prim_mubi_pkg::mubi4_t unused_cg_en_2;
    assign unused_cg_en_2 = clkmgr_aon_cg_en.io_powerup;
    prim_mubi_pkg::mubi4_t unused_cg_en_3;
    assign unused_cg_en_3 = clkmgr_aon_cg_en.io_div2_powerup;
    prim_mubi_pkg::mubi4_t unused_cg_en_4;
    assign unused_cg_en_4 = clkmgr_aon_cg_en.aon_secure;
    prim_mubi_pkg::mubi4_t unused_cg_en_5;
    assign unused_cg_en_5 = clkmgr_aon_cg_en.aon_peri;
    prim_mubi_pkg::mubi4_t unused_cg_en_6;
    assign unused_cg_en_6 = clkmgr_aon_cg_en.aon_timers;
    prim_mubi_pkg::mubi4_t unused_rst_en_0;
    assign unused_rst_en_0 = rstmgr_aon_rst_en.por_aon[rstmgr_pkg::DomainAonSel];
    prim_mubi_pkg::mubi4_t unused_rst_en_1;
    assign unused_rst_en_1 = rstmgr_aon_rst_en.por_aon[rstmgr_pkg::Domain0Sel];
    prim_mubi_pkg::mubi4_t unused_rst_en_2;
    assign unused_rst_en_2 = rstmgr_aon_rst_en.por[rstmgr_pkg::DomainAonSel];
    prim_mubi_pkg::mubi4_t unused_rst_en_3;
    assign unused_rst_en_3 = rstmgr_aon_rst_en.por[rstmgr_pkg::Domain0Sel];
    prim_mubi_pkg::mubi4_t unused_rst_en_4;
    assign unused_rst_en_4 = rstmgr_aon_rst_en.por_io[rstmgr_pkg::DomainAonSel];
    prim_mubi_pkg::mubi4_t unused_rst_en_5;
    assign unused_rst_en_5 = rstmgr_aon_rst_en.por_io[rstmgr_pkg::Domain0Sel];
    prim_mubi_pkg::mubi4_t unused_rst_en_6;
    assign unused_rst_en_6 = rstmgr_aon_rst_en.por_io_div2[rstmgr_pkg::DomainAonSel];
    prim_mubi_pkg::mubi4_t unused_rst_en_7;
    assign unused_rst_en_7 = rstmgr_aon_rst_en.por_io_div2[rstmgr_pkg::Domain0Sel];
    prim_mubi_pkg::mubi4_t unused_rst_en_8;
    assign unused_rst_en_8 = rstmgr_aon_rst_en.por_io_div4[rstmgr_pkg::Domain0Sel];
    prim_mubi_pkg::mubi4_t unused_rst_en_9;
    assign unused_rst_en_9 = rstmgr_aon_rst_en.lc_shadowed[rstmgr_pkg::DomainAonSel];
    prim_mubi_pkg::mubi4_t unused_rst_en_10;
    assign unused_rst_en_10 = rstmgr_aon_rst_en.lc[rstmgr_pkg::DomainAonSel];
    prim_mubi_pkg::mubi4_t unused_rst_en_11;
    assign unused_rst_en_11 = rstmgr_aon_rst_en.lc_shadowed[rstmgr_pkg::Domain0Sel];
    prim_mubi_pkg::mubi4_t unused_rst_en_12;
    assign unused_rst_en_12 = rstmgr_aon_rst_en.lc_aon[rstmgr_pkg::DomainAonSel];
    prim_mubi_pkg::mubi4_t unused_rst_en_13;
    assign unused_rst_en_13 = rstmgr_aon_rst_en.lc_aon[rstmgr_pkg::Domain0Sel];
    prim_mubi_pkg::mubi4_t unused_rst_en_14;
    assign unused_rst_en_14 = rstmgr_aon_rst_en.lc_io[rstmgr_pkg::DomainAonSel];
    prim_mubi_pkg::mubi4_t unused_rst_en_15;
    assign unused_rst_en_15 = rstmgr_aon_rst_en.lc_io[rstmgr_pkg::Domain0Sel];
    prim_mubi_pkg::mubi4_t unused_rst_en_16;
    assign unused_rst_en_16 = rstmgr_aon_rst_en.lc_io_div2[rstmgr_pkg::DomainAonSel];
    prim_mubi_pkg::mubi4_t unused_rst_en_17;
    assign unused_rst_en_17 = rstmgr_aon_rst_en.lc_io_div2[rstmgr_pkg::Domain0Sel];
    prim_mubi_pkg::mubi4_t unused_rst_en_18;
    assign unused_rst_en_18 = rstmgr_aon_rst_en.lc_io_div4_shadowed[rstmgr_pkg::DomainAonSel];
    prim_mubi_pkg::mubi4_t unused_rst_en_19;
    assign unused_rst_en_19 = rstmgr_aon_rst_en.lc_io_div4_shadowed[rstmgr_pkg::Domain0Sel];
    prim_mubi_pkg::mubi4_t unused_rst_en_20;
    assign unused_rst_en_20 = rstmgr_aon_rst_en.sys[rstmgr_pkg::DomainAonSel];
    prim_mubi_pkg::mubi4_t unused_rst_en_21;
    assign unused_rst_en_21 = rstmgr_aon_rst_en.sys_io_div4[rstmgr_pkg::DomainAonSel];
    prim_mubi_pkg::mubi4_t unused_rst_en_22;
    assign unused_rst_en_22 = rstmgr_aon_rst_en.sys_io_div4[rstmgr_pkg::Domain0Sel];
//VCS coverage on
// pragma coverage on

  // Peripheral Instantiation


  gpio #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[0:0]),
    .GpioAsyncOn(GpioGpioAsyncOn)
  ) u_gpio (

      // Input
      .cio_gpio_i    (cio_gpio_gpio_p2d),

      // Output
      .cio_gpio_o    (cio_gpio_gpio_d2p),
      .cio_gpio_en_o (cio_gpio_gpio_en_d2p),

      // Interrupt
      .intr_gpio_o (intr_gpio_gpio),
      // [0]: fatal_fault
      .alert_tx_o  ( alert_tx[0:0] ),
      .alert_rx_i  ( alert_rx[0:0] ),

      // Inter-module signals
      .tl_i(gpio_tl_req),
      .tl_o(gpio_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_io_div4_peri),
      .rst_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::Domain0Sel])
  );
  pattgen #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[1:1])
  ) u_pattgen (

      // Output
      .cio_pda0_tx_o    (cio_pattgen_pda0_tx_d2p),
      .cio_pda0_tx_en_o (cio_pattgen_pda0_tx_en_d2p),
      .cio_pcl0_tx_o    (cio_pattgen_pcl0_tx_d2p),
      .cio_pcl0_tx_en_o (cio_pattgen_pcl0_tx_en_d2p),
      .cio_pda1_tx_o    (cio_pattgen_pda1_tx_d2p),
      .cio_pda1_tx_en_o (cio_pattgen_pda1_tx_en_d2p),
      .cio_pcl1_tx_o    (cio_pattgen_pcl1_tx_d2p),
      .cio_pcl1_tx_en_o (cio_pattgen_pcl1_tx_en_d2p),

      // Interrupt
      .intr_done_ch0_o (intr_pattgen_done_ch0),
      .intr_done_ch1_o (intr_pattgen_done_ch1),
      // [1]: fatal_fault
      .alert_tx_o  ( alert_tx[1:1] ),
      .alert_rx_i  ( alert_rx[1:1] ),

      // Inter-module signals
      .tl_i(pattgen_tl_req),
      .tl_o(pattgen_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_io_div4_peri),
      .rst_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::Domain0Sel])
  );
  rv_timer #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[2:2])
  ) u_rv_timer (

      // Interrupt
      .intr_timer_expired_hart0_timer0_o (intr_rv_timer_timer_expired_hart0_timer0),
      // [2]: fatal_fault
      .alert_tx_o  ( alert_tx[2:2] ),
      .alert_rx_i  ( alert_rx[2:2] ),

      // Inter-module signals
      .tl_i(rv_timer_tl_req),
      .tl_o(rv_timer_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_io_div4_timers),
      .rst_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::Domain0Sel])
  );
  otp_ctrl #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[7:3]),
    .MemInitFile(OtpCtrlMemInitFile),
    .RndCnstLfsrSeed(RndCnstOtpCtrlLfsrSeed),
    .RndCnstLfsrPerm(RndCnstOtpCtrlLfsrPerm),
    .RndCnstScrmblKeyInit(RndCnstOtpCtrlScrmblKeyInit)
  ) u_otp_ctrl (

      // Output
      .cio_test_o    (cio_otp_ctrl_test_d2p),
      .cio_test_en_o (cio_otp_ctrl_test_en_d2p),

      // Interrupt
      .intr_otp_operation_done_o (intr_otp_ctrl_otp_operation_done),
      .intr_otp_error_o          (intr_otp_ctrl_otp_error),
      // [3]: fatal_macro_error
      // [4]: fatal_check_error
      // [5]: fatal_bus_integ_error
      // [6]: fatal_prim_otp_alert
      // [7]: recov_prim_otp_alert
      .alert_tx_o  ( alert_tx[7:3] ),
      .alert_rx_i  ( alert_rx[7:3] ),

      // Inter-module signals
      .otp_ext_voltage_h_io(),
      .otp_ast_pwr_seq_o(),
      .otp_ast_pwr_seq_h_i('0),
      .edn_o(edn0_edn_req[1]),
      .edn_i(edn0_edn_rsp[1]),
      .pwr_otp_i(pwrmgr_aon_pwr_otp_req),
      .pwr_otp_o(pwrmgr_aon_pwr_otp_rsp),
      .lc_otp_vendor_test_i(lc_ctrl_lc_otp_vendor_test_req),
      .lc_otp_vendor_test_o(lc_ctrl_lc_otp_vendor_test_rsp),
      .lc_otp_program_i(lc_ctrl_lc_otp_program_req),
      .lc_otp_program_o(lc_ctrl_lc_otp_program_rsp),
      .otp_lc_data_o(otp_ctrl_otp_lc_data),
      .lc_escalate_en_i(lc_ctrl_lc_escalate_en),
      .lc_creator_seed_sw_rw_en_i(lc_ctrl_lc_creator_seed_sw_rw_en),
      .lc_seed_hw_rd_en_i(lc_ctrl_lc_seed_hw_rd_en),
      .lc_dft_en_i(lc_ctrl_lc_dft_en),
      .lc_check_byp_en_i(lc_ctrl_lc_check_byp_en),
      .otp_keymgr_key_o(otp_ctrl_otp_keymgr_key),
      .flash_otp_key_i(flash_ctrl_otp_req),
      .flash_otp_key_o(flash_ctrl_otp_rsp),
      .sram_otp_key_i(otp_ctrl_sram_otp_key_req),
      .sram_otp_key_o(otp_ctrl_sram_otp_key_rsp),
      .otbn_otp_key_i(otp_ctrl_otbn_otp_key_req),
      .otbn_otp_key_o(otp_ctrl_otbn_otp_key_rsp),
      .otp_hw_cfg_o(otp_ctrl_otp_hw_cfg),
      .obs_ctrl_i(),
      .otp_obs_o(),
      .core_tl_i(otp_ctrl_core_tl_req),
      .core_tl_o(otp_ctrl_core_tl_rsp),
      .prim_tl_i(otp_ctrl_prim_tl_req),
      .prim_tl_o(otp_ctrl_prim_tl_rsp),
      .scanmode_i,
      .scan_rst_ni,
      .scan_en_i,

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_io_div4_secure),
      .clk_edn_i (clkmgr_aon_clocks.clk_main_secure),
      .rst_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::Domain0Sel]),
      .rst_edn_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel])
  );
  tlul2axi u_tlul2axi (

      // Inter-module signals
      .axi_req_o(axi_req_o),
      .axi_rsp_i(axi_rsp_i),
      .tl_i(tlul2axi_tl_req),
      .tl_o(tlul2axi_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_secure),
      .rst_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::Domain0Sel])
  );
  lc_ctrl #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[10:8]),
    .RndCnstLcKeymgrDivInvalid(RndCnstLcCtrlLcKeymgrDivInvalid),
    .RndCnstLcKeymgrDivTestDevRma(RndCnstLcCtrlLcKeymgrDivTestDevRma),
    .RndCnstLcKeymgrDivProduction(RndCnstLcCtrlLcKeymgrDivProduction),
    .RndCnstInvalidTokens(RndCnstLcCtrlInvalidTokens),
    .ChipGen(LcCtrlChipGen),
    .ChipRev(LcCtrlChipRev),
    .IdcodeValue(LcCtrlIdcodeValue)
  ) u_lc_ctrl (
      // [8]: fatal_prog_error
      // [9]: fatal_state_error
      // [10]: fatal_bus_integ_error
      .alert_tx_o  ( alert_tx[10:8] ),
      .alert_rx_i  ( alert_rx[10:8] ),

      // Inter-module signals
      .jtag_i(pinmux_aon_lc_jtag_req),
      .jtag_o(pinmux_aon_lc_jtag_rsp),
      .esc_scrap_state0_tx_i(alert_handler_esc_tx[1]),
      .esc_scrap_state0_rx_o(alert_handler_esc_rx[1]),
      .esc_scrap_state1_tx_i(alert_handler_esc_tx[2]),
      .esc_scrap_state1_rx_o(alert_handler_esc_rx[2]),
      .pwr_lc_i(pwrmgr_aon_pwr_lc_req),
      .pwr_lc_o(pwrmgr_aon_pwr_lc_rsp),
      .lc_otp_vendor_test_o(lc_ctrl_lc_otp_vendor_test_req),
      .lc_otp_vendor_test_i(lc_ctrl_lc_otp_vendor_test_rsp),
      .otp_lc_data_i(otp_ctrl_otp_lc_data),
      .lc_otp_program_o(lc_ctrl_lc_otp_program_req),
      .lc_otp_program_i(lc_ctrl_lc_otp_program_rsp),
      .kmac_data_o(kmac_app_req[1]),
      .kmac_data_i(kmac_app_rsp[1]),
      .lc_dft_en_o(lc_ctrl_lc_dft_en),
      .lc_nvm_debug_en_o(lc_ctrl_lc_nvm_debug_en),
      .lc_hw_debug_en_o(lc_ctrl_lc_hw_debug_en),
      .lc_cpu_en_o(lc_ctrl_lc_cpu_en),
      .lc_keymgr_en_o(lc_ctrl_lc_keymgr_en),
      .lc_escalate_en_o(lc_ctrl_lc_escalate_en),
      .lc_clk_byp_req_o(lc_ctrl_lc_clk_byp_req),
      .lc_clk_byp_ack_i(lc_ctrl_lc_clk_byp_ack),
      .lc_flash_rma_req_o(lc_ctrl_lc_flash_rma_req),
      .lc_flash_rma_seed_o(flash_ctrl_rma_seed),
      .lc_flash_rma_ack_i(otbn_lc_rma_ack),
      .lc_check_byp_en_o(lc_ctrl_lc_check_byp_en),
      .lc_creator_seed_sw_rw_en_o(lc_ctrl_lc_creator_seed_sw_rw_en),
      .lc_owner_seed_sw_rw_en_o(lc_ctrl_lc_owner_seed_sw_rw_en),
      .lc_iso_part_sw_rd_en_o(lc_ctrl_lc_iso_part_sw_rd_en),
      .lc_iso_part_sw_wr_en_o(lc_ctrl_lc_iso_part_sw_wr_en),
      .lc_seed_hw_rd_en_o(lc_ctrl_lc_seed_hw_rd_en),
      .lc_keymgr_div_o(lc_ctrl_lc_keymgr_div),
      .otp_device_id_i(lc_ctrl_otp_device_id),
      .otp_manuf_state_i(lc_ctrl_otp_manuf_state),
      .hw_rev_o(),
      .tl_i(lc_ctrl_tl_req),
      .tl_o(lc_ctrl_tl_rsp),
      .scanmode_i,
      .scan_rst_ni,

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_io_div4_secure),
      .clk_kmac_i (clkmgr_aon_clocks.clk_main_secure),
      .rst_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::Domain0Sel]),
      .rst_kmac_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel])
  );
  alert_handler #(
    .RndCnstLfsrSeed(RndCnstAlertHandlerLfsrSeed),
    .RndCnstLfsrPerm(RndCnstAlertHandlerLfsrPerm)
  ) u_alert_handler (

      // Interrupt
      .intr_classa_o (intr_alert_handler_classa),
      .intr_classb_o (intr_alert_handler_classb),
      .intr_classc_o (intr_alert_handler_classc),
      .intr_classd_o (intr_alert_handler_classd),

      // Inter-module signals
      .crashdump_o(alert_handler_crashdump),
      .edn_o(edn0_edn_req[3]),
      .edn_i(edn0_edn_rsp[3]),
      .esc_rx_i(alert_handler_esc_rx),
      .esc_tx_o(alert_handler_esc_tx),
      .tl_i(alert_handler_tl_req),
      .tl_o(alert_handler_tl_rsp),
      // alert signals
      .alert_rx_o  ( alert_rx ),
      .alert_tx_i  ( alert_tx ),
      // synchronized clock gated / reset asserted
      // indications for each alert
      .lpg_cg_en_i  ( lpg_cg_en  ),
      .lpg_rst_en_i ( lpg_rst_en ),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_io_div4_secure),
      .clk_edn_i (clkmgr_aon_clocks.clk_main_secure),
      .rst_shadowed_ni (rstmgr_aon_resets.rst_lc_io_div4_shadowed_n[rstmgr_pkg::Domain0Sel]),
      .rst_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::Domain0Sel]),
      .rst_edn_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel])
  );
  pwrmgr #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[11:11])
  ) u_pwrmgr_aon (

      // Interrupt
      .intr_wakeup_o (intr_pwrmgr_aon_wakeup),
      // [11]: fatal_fault
      .alert_tx_o  ( alert_tx[11:11] ),
      .alert_rx_i  ( alert_rx[11:11] ),

      // Inter-module signals
      .pwr_ast_o(),
      .pwr_ast_i(pwrmgr_pkg::PWR_AST_RSP_DEFAULT),
      .pwr_rst_o(pwrmgr_aon_pwr_rst_req),
      .pwr_rst_i(pwrmgr_aon_pwr_rst_rsp),
      .pwr_clk_o(pwrmgr_aon_pwr_clk_req),
      .pwr_clk_i(pwrmgr_aon_pwr_clk_rsp),
      .pwr_otp_o(pwrmgr_aon_pwr_otp_req),
      .pwr_otp_i(pwrmgr_aon_pwr_otp_rsp),
      .pwr_lc_o(pwrmgr_aon_pwr_lc_req),
      .pwr_lc_i(pwrmgr_aon_pwr_lc_rsp),
      .pwr_flash_i(pwrmgr_aon_pwr_flash),
      .esc_rst_tx_i(alert_handler_esc_tx[3]),
      .esc_rst_rx_o(alert_handler_esc_rx[3]),
      .pwr_cpu_i(rv_core_ibex_pwrmgr),
      .wakeups_i(pwrmgr_aon_wakeups),
      .rstreqs_i(pwrmgr_aon_rstreqs),
      .ndmreset_req_i(rv_dm_ndmreset_req),
      .strap_o(pwrmgr_aon_strap),
      .low_power_o(pwrmgr_aon_low_power),
      .rom_ctrl_i(rom_ctrl_pwrmgr_data),
      .fetch_en_o(pwrmgr_aon_fetch_en),
      .lc_dft_en_i(lc_ctrl_lc_dft_en),
      .lc_hw_debug_en_i(lc_ctrl_lc_hw_debug_en),
      .sw_rst_req_i(rstmgr_aon_sw_rst_req),
      .tl_i(pwrmgr_aon_tl_req),
      .tl_o(pwrmgr_aon_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_io_div4_powerup),
      .clk_slow_i (clkmgr_aon_clocks.clk_aon_powerup),
      .clk_lc_i (clkmgr_aon_clocks.clk_io_div4_powerup),
      .clk_esc_i (clkmgr_aon_clocks.clk_io_div4_secure),
      .rst_ni (rstmgr_aon_resets.rst_por_io_div4_n[rstmgr_pkg::DomainAonSel]),
      .rst_main_ni (rstmgr_aon_resets.rst_por_aon_n[rstmgr_pkg::Domain0Sel]),
      .rst_lc_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::DomainAonSel]),
      .rst_esc_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::DomainAonSel]),
      .rst_slow_ni (rstmgr_aon_resets.rst_por_aon_n[rstmgr_pkg::DomainAonSel])
  );
  rstmgr #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[13:12]),
    .SecCheck(SecRstmgrAonCheck),
    .SecMaxSyncDelay(SecRstmgrAonMaxSyncDelay)
  ) u_rstmgr_aon (
      // [12]: fatal_fault
      // [13]: fatal_cnsty_fault
      .alert_tx_o  ( alert_tx[13:12] ),
      .alert_rx_i  ( alert_rx[13:12] ),

      // Inter-module signals
      .por_n_i(por_n_i),
      .pwr_i(pwrmgr_aon_pwr_rst_req),
      .pwr_o(pwrmgr_aon_pwr_rst_rsp),
      .resets_o(rstmgr_aon_resets),
      .rst_en_o(rstmgr_aon_rst_en),
      .alert_dump_i(alert_handler_crashdump),
      .cpu_dump_i(rv_core_ibex_crash_dump),
      .sw_rst_req_o(rstmgr_aon_sw_rst_req),
      .tl_i(rstmgr_aon_tl_req),
      .tl_o(rstmgr_aon_tl_rsp),
      .scanmode_i,
      .scan_rst_ni,

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_io_div4_powerup),
      .clk_por_i (clkmgr_aon_clocks.clk_io_div4_powerup),
      .clk_aon_i (clkmgr_aon_clocks.clk_aon_powerup),
      .clk_main_i (clkmgr_aon_clocks.clk_main_powerup),
      .clk_io_i (clkmgr_aon_clocks.clk_io_powerup),
      .clk_io_div2_i (clkmgr_aon_clocks.clk_io_div2_powerup),
      .clk_io_div4_i (clkmgr_aon_clocks.clk_io_div4_powerup),
      .rst_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::DomainAonSel]),
      .rst_por_ni (rstmgr_aon_resets.rst_por_io_div4_n[rstmgr_pkg::DomainAonSel])
  );
  clkmgr #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[15:14])
  ) u_clkmgr_aon (
      // [14]: recov_fault
      // [15]: fatal_fault
      .alert_tx_o  ( alert_tx[15:14] ),
      .alert_rx_i  ( alert_rx[15:14] ),

      // Inter-module signals
      .clocks_o(clkmgr_aon_clocks),
      .cg_en_o(clkmgr_aon_cg_en),
      .lc_hw_debug_en_i(lc_ctrl_lc_hw_debug_en),
      .io_clk_byp_req_o(io_clk_byp_req_o),
      .io_clk_byp_ack_i(io_clk_byp_ack_i),
      .all_clk_byp_req_o(all_clk_byp_req_o),
      .all_clk_byp_ack_i(all_clk_byp_ack_i),
      .hi_speed_sel_o(hi_speed_sel_o),
      .div_step_down_req_i(div_step_down_req_i),
      .lc_clk_byp_req_i(lc_ctrl_lc_clk_byp_req),
      .lc_clk_byp_ack_o(lc_ctrl_lc_clk_byp_ack),
      .jitter_en_o(clk_main_jitter_en_o),
      .pwr_i(pwrmgr_aon_pwr_clk_req),
      .pwr_o(pwrmgr_aon_pwr_clk_rsp),
      .idle_i(clkmgr_aon_idle),
      .calib_rdy_i(calib_rdy_i),
      .tl_i(clkmgr_aon_tl_req),
      .tl_o(clkmgr_aon_tl_rsp),
      .scanmode_i,

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_io_div4_powerup),
      .clk_main_i (clk_main_i),
      .clk_io_i (clk_io_i),
      .clk_aon_i (clk_aon_i),
      .rst_shadowed_ni (rstmgr_aon_resets.rst_lc_io_div4_shadowed_n[rstmgr_pkg::DomainAonSel]),
      .rst_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::DomainAonSel]),
      .rst_aon_ni (rstmgr_aon_resets.rst_lc_aon_n[rstmgr_pkg::DomainAonSel]),
      .rst_io_ni (rstmgr_aon_resets.rst_lc_io_n[rstmgr_pkg::DomainAonSel]),
      .rst_io_div2_ni (rstmgr_aon_resets.rst_lc_io_div2_n[rstmgr_pkg::DomainAonSel]),
      .rst_io_div4_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::DomainAonSel]),
      .rst_main_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::DomainAonSel]),
      .rst_root_ni (rstmgr_aon_resets.rst_por_io_div4_n[rstmgr_pkg::DomainAonSel]),
      .rst_root_io_ni (rstmgr_aon_resets.rst_por_io_n[rstmgr_pkg::DomainAonSel]),
      .rst_root_io_div2_ni (rstmgr_aon_resets.rst_por_io_div2_n[rstmgr_pkg::DomainAonSel]),
      .rst_root_io_div4_ni (rstmgr_aon_resets.rst_por_io_div4_n[rstmgr_pkg::DomainAonSel]),
      .rst_root_main_ni (rstmgr_aon_resets.rst_por_n[rstmgr_pkg::DomainAonSel])
  );
  sysrst_ctrl #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[16:16])
  ) u_sysrst_ctrl_aon (

      // Input
      .cio_ac_present_i     (cio_sysrst_ctrl_aon_ac_present_p2d),
      .cio_key0_in_i        (cio_sysrst_ctrl_aon_key0_in_p2d),
      .cio_key1_in_i        (cio_sysrst_ctrl_aon_key1_in_p2d),
      .cio_key2_in_i        (cio_sysrst_ctrl_aon_key2_in_p2d),
      .cio_pwrb_in_i        (cio_sysrst_ctrl_aon_pwrb_in_p2d),
      .cio_lid_open_i       (cio_sysrst_ctrl_aon_lid_open_p2d),
      .cio_ec_rst_l_i       (cio_sysrst_ctrl_aon_ec_rst_l_p2d),
      .cio_flash_wp_l_i     (cio_sysrst_ctrl_aon_flash_wp_l_p2d),

      // Output
      .cio_bat_disable_o    (cio_sysrst_ctrl_aon_bat_disable_d2p),
      .cio_bat_disable_en_o (cio_sysrst_ctrl_aon_bat_disable_en_d2p),
      .cio_key0_out_o       (cio_sysrst_ctrl_aon_key0_out_d2p),
      .cio_key0_out_en_o    (cio_sysrst_ctrl_aon_key0_out_en_d2p),
      .cio_key1_out_o       (cio_sysrst_ctrl_aon_key1_out_d2p),
      .cio_key1_out_en_o    (cio_sysrst_ctrl_aon_key1_out_en_d2p),
      .cio_key2_out_o       (cio_sysrst_ctrl_aon_key2_out_d2p),
      .cio_key2_out_en_o    (cio_sysrst_ctrl_aon_key2_out_en_d2p),
      .cio_pwrb_out_o       (cio_sysrst_ctrl_aon_pwrb_out_d2p),
      .cio_pwrb_out_en_o    (cio_sysrst_ctrl_aon_pwrb_out_en_d2p),
      .cio_z3_wakeup_o      (cio_sysrst_ctrl_aon_z3_wakeup_d2p),
      .cio_z3_wakeup_en_o   (cio_sysrst_ctrl_aon_z3_wakeup_en_d2p),
      .cio_ec_rst_l_o       (cio_sysrst_ctrl_aon_ec_rst_l_d2p),
      .cio_ec_rst_l_en_o    (cio_sysrst_ctrl_aon_ec_rst_l_en_d2p),
      .cio_flash_wp_l_o     (cio_sysrst_ctrl_aon_flash_wp_l_d2p),
      .cio_flash_wp_l_en_o  (cio_sysrst_ctrl_aon_flash_wp_l_en_d2p),

      // Interrupt
      .intr_event_detected_o (intr_sysrst_ctrl_aon_event_detected),
      // [16]: fatal_fault
      .alert_tx_o  ( alert_tx[16:16] ),
      .alert_rx_i  ( alert_rx[16:16] ),

      // Inter-module signals
      .wkup_req_o(pwrmgr_aon_wakeups[0]),
      .rst_req_o(pwrmgr_aon_rstreqs[0]),
      .tl_i(sysrst_ctrl_aon_tl_req),
      .tl_o(sysrst_ctrl_aon_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_io_div4_secure),
      .clk_aon_i (clkmgr_aon_clocks.clk_aon_secure),
      .rst_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::DomainAonSel]),
      .rst_aon_ni (rstmgr_aon_resets.rst_lc_aon_n[rstmgr_pkg::DomainAonSel])
  );
  pwm #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[17:17])
  ) u_pwm_aon (

      // Output
      .cio_pwm_o    (cio_pwm_aon_pwm_d2p),
      .cio_pwm_en_o (cio_pwm_aon_pwm_en_d2p),
      // [17]: fatal_fault
      .alert_tx_o  ( alert_tx[17:17] ),
      .alert_rx_i  ( alert_rx[17:17] ),

      // Inter-module signals
      .tl_i(pwm_aon_tl_req),
      .tl_o(pwm_aon_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_io_div4_peri),
      .clk_core_i (clkmgr_aon_clocks.clk_aon_peri),
      .rst_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::DomainAonSel]),
      .rst_core_ni (rstmgr_aon_resets.rst_lc_aon_n[rstmgr_pkg::DomainAonSel])
  );
  pinmux #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[18:18]),
    .TargetCfg(PinmuxAonTargetCfg)
  ) u_pinmux_aon (
      // [18]: fatal_fault
      .alert_tx_o  ( alert_tx[18:18] ),
      .alert_rx_i  ( alert_rx[18:18] ),

      // Inter-module signals
      .lc_hw_debug_en_i(lc_ctrl_lc_hw_debug_en),
      .lc_dft_en_i(lc_ctrl_lc_dft_en),
      .lc_escalate_en_i(lc_ctrl_lc_escalate_en),
      .lc_check_byp_en_i(lc_ctrl_lc_check_byp_en),
      .pinmux_hw_debug_en_o(pinmux_aon_pinmux_hw_debug_en),
      .lc_jtag_o(pinmux_aon_lc_jtag_req),
      .lc_jtag_i(pinmux_aon_lc_jtag_rsp),
      .rv_jtag_o(),
      .rv_jtag_i(jtag_pkg::JTAG_RSP_DEFAULT),
      .dft_jtag_o(pinmux_aon_dft_jtag_req),
      .dft_jtag_i(pinmux_aon_dft_jtag_rsp),
      .dft_strap_test_o(),
      .dft_hold_tap_sel_i('0),
      .sleep_en_i(pwrmgr_aon_low_power),
      .strap_en_i(pwrmgr_aon_strap),
      .pin_wkup_req_o(pwrmgr_aon_wakeups[1]),
      .usbdev_dppullup_en_i('0),
      .usbdev_dnpullup_en_i('0),
      .usb_dppullup_en_o(),
      .usb_dnpullup_en_o(),
      .usb_wkup_req_o(pwrmgr_aon_wakeups[2]),
      .usbdev_suspend_req_i('0),
      .usbdev_wake_ack_i('0),
      .usbdev_bus_reset_o(),
      .usbdev_sense_lost_o(),
      .usbdev_wake_detect_active_o(),
      .tl_i(pinmux_aon_tl_req),
      .tl_o(pinmux_aon_tl_rsp),

      .periph_to_mio_i      (mio_d2p    ),
      .periph_to_mio_oe_i   (mio_en_d2p ),
      .mio_to_periph_o      (mio_p2d    ),

      .mio_attr_o,
      .mio_out_o,
      .mio_oe_o,
      .mio_in_i,

      .periph_to_dio_i      (dio_d2p    ),
      .periph_to_dio_oe_i   (dio_en_d2p ),
      .dio_to_periph_o      (dio_p2d    ),

      .dio_attr_o,
      .dio_out_o,
      .dio_oe_o,
      .dio_in_i,

      .scanmode_i,

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_io_div4_powerup),
      .clk_aon_i (clkmgr_aon_clocks.clk_aon_powerup),
      .rst_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::DomainAonSel]),
      .rst_aon_ni (rstmgr_aon_resets.rst_lc_aon_n[rstmgr_pkg::DomainAonSel]),
      .rst_sys_ni (rstmgr_aon_resets.rst_sys_io_div4_n[rstmgr_pkg::DomainAonSel])
  );
  aon_timer #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[19:19])
  ) u_aon_timer_aon (

      // Interrupt
      .intr_wkup_timer_expired_o (intr_aon_timer_aon_wkup_timer_expired),
      .intr_wdog_timer_bark_o    (intr_aon_timer_aon_wdog_timer_bark),
      // [19]: fatal_fault
      .alert_tx_o  ( alert_tx[19:19] ),
      .alert_rx_i  ( alert_rx[19:19] ),

      // Inter-module signals
      .nmi_wdog_timer_bark_o(aon_timer_aon_nmi_wdog_timer_bark),
      .wkup_req_o(pwrmgr_aon_wakeups[3]),
      .aon_timer_rst_req_o(pwrmgr_aon_rstreqs[1]),
      .lc_escalate_en_i(lc_ctrl_lc_escalate_en),
      .sleep_mode_i(pwrmgr_aon_low_power),
      .tl_i(aon_timer_aon_tl_req),
      .tl_o(aon_timer_aon_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_io_div4_timers),
      .clk_aon_i (clkmgr_aon_clocks.clk_aon_timers),
      .rst_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::DomainAonSel]),
      .rst_aon_ni (rstmgr_aon_resets.rst_lc_aon_n[rstmgr_pkg::DomainAonSel])
  );
  sram_ctrl #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[20:20]),
    .RndCnstSramKey(RndCnstSramCtrlRetAonSramKey),
    .RndCnstSramNonce(RndCnstSramCtrlRetAonSramNonce),
    .RndCnstLfsrSeed(RndCnstSramCtrlRetAonLfsrSeed),
    .RndCnstLfsrPerm(RndCnstSramCtrlRetAonLfsrPerm),
    .MemSizeRam(4096),
    .InstrExec(SramCtrlRetAonInstrExec)
  ) u_sram_ctrl_ret_aon (
      // [20]: fatal_error
      .alert_tx_o  ( alert_tx[20:20] ),
      .alert_rx_i  ( alert_rx[20:20] ),

      // Inter-module signals
      .sram_otp_key_o(otp_ctrl_sram_otp_key_req[1]),
      .sram_otp_key_i(otp_ctrl_sram_otp_key_rsp[1]),
      .cfg_i('0),
      .lc_escalate_en_i(lc_ctrl_lc_escalate_en),
      .lc_hw_debug_en_i(lc_ctrl_pkg::Off),
      .otp_en_sram_ifetch_i(prim_mubi_pkg::MuBi8False),
      .regs_tl_i(sram_ctrl_ret_aon_regs_tl_req),
      .regs_tl_o(sram_ctrl_ret_aon_regs_tl_rsp),
      .ram_tl_i(sram_ctrl_ret_aon_ram_tl_req),
      .ram_tl_o(sram_ctrl_ret_aon_ram_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_io_div4_infra),
      .clk_otp_i (clkmgr_aon_clocks.clk_io_div4_infra),
      .rst_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::DomainAonSel]),
      .rst_otp_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::DomainAonSel])
  );
  flash_ctrl #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[25:21]),
    .RndCnstAddrKey(RndCnstFlashCtrlAddrKey),
    .RndCnstDataKey(RndCnstFlashCtrlDataKey),
    .RndCnstAllSeeds(RndCnstFlashCtrlAllSeeds),
    .RndCnstLfsrSeed(RndCnstFlashCtrlLfsrSeed),
    .RndCnstLfsrPerm(RndCnstFlashCtrlLfsrPerm),
    .SecScrambleEn(SecFlashCtrlScrambleEn),
    .ProgFifoDepth(FlashCtrlProgFifoDepth),
    .RdFifoDepth(FlashCtrlRdFifoDepth)
  ) u_flash_ctrl (

      // Input
      .cio_tck_i    (cio_flash_ctrl_tck_p2d),
      .cio_tms_i    (cio_flash_ctrl_tms_p2d),
      .cio_tdi_i    (cio_flash_ctrl_tdi_p2d),

      // Output
      .cio_tdo_o    (cio_flash_ctrl_tdo_d2p),
      .cio_tdo_en_o (cio_flash_ctrl_tdo_en_d2p),

      // Interrupt
      .intr_prog_empty_o (intr_flash_ctrl_prog_empty),
      .intr_prog_lvl_o   (intr_flash_ctrl_prog_lvl),
      .intr_rd_full_o    (intr_flash_ctrl_rd_full),
      .intr_rd_lvl_o     (intr_flash_ctrl_rd_lvl),
      .intr_op_done_o    (intr_flash_ctrl_op_done),
      .intr_corr_err_o   (intr_flash_ctrl_corr_err),
      // [21]: recov_err
      // [22]: fatal_std_err
      // [23]: fatal_err
      // [24]: fatal_prim_flash_alert
      // [25]: recov_prim_flash_alert
      .alert_tx_o  ( alert_tx[25:21] ),
      .alert_rx_i  ( alert_rx[25:21] ),

      // Inter-module signals
      .otp_o(flash_ctrl_otp_req),
      .otp_i(flash_ctrl_otp_rsp),
      .lc_nvm_debug_en_i(lc_ctrl_lc_nvm_debug_en),
      .flash_bist_enable_i(),
      .flash_power_down_h_i('0),
      .flash_power_ready_h_i('0),
      .flash_test_mode_a_io(),
      .flash_test_voltage_h_io(),
      .lc_creator_seed_sw_rw_en_i(lc_ctrl_lc_creator_seed_sw_rw_en),
      .lc_owner_seed_sw_rw_en_i(lc_ctrl_lc_owner_seed_sw_rw_en),
      .lc_iso_part_sw_rd_en_i(lc_ctrl_lc_iso_part_sw_rd_en),
      .lc_iso_part_sw_wr_en_i(lc_ctrl_lc_iso_part_sw_wr_en),
      .lc_seed_hw_rd_en_i(lc_ctrl_lc_seed_hw_rd_en),
      .lc_escalate_en_i(lc_ctrl_lc_escalate_en),
      .rma_req_i(lc_ctrl_lc_flash_rma_req),
      .rma_ack_o(flash_ctrl_rma_ack),
      .rma_seed_i(flash_ctrl_rma_seed),
      .pwrmgr_o(pwrmgr_aon_pwr_flash),
      .keymgr_o(flash_ctrl_keymgr),
      .obs_ctrl_i(),
      .fla_obs_o(),
      .core_tl_i(flash_ctrl_core_tl_req),
      .core_tl_o(flash_ctrl_core_tl_rsp),
      .prim_tl_i(flash_ctrl_prim_tl_req),
      .prim_tl_o(flash_ctrl_prim_tl_rsp),
      .mem_tl_i(flash_ctrl_mem_tl_req),
      .mem_tl_o(flash_ctrl_mem_tl_rsp),
      .scanmode_i,
      .scan_rst_ni,
      .scan_en_i,

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_infra),
      .clk_otp_i (clkmgr_aon_clocks.clk_io_div4_infra),
      .rst_shadowed_ni (rstmgr_aon_resets.rst_lc_shadowed_n[rstmgr_pkg::Domain0Sel]),
      .rst_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel]),
      .rst_otp_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::Domain0Sel])
  );
  rv_dm #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[26:26]),
    .IdcodeValue(RvDmIdcodeValue)
  ) u_rv_dm (
      // [26]: fatal_fault
      .alert_tx_o  ( alert_tx[26:26] ),
      .alert_rx_i  ( alert_rx[26:26] ),

      // Inter-module signals
      .jtag_i(jtag_req_i),
      .jtag_o(jtag_rsp_o),
      .lc_hw_debug_en_i(lc_ctrl_lc_hw_debug_en),
      .pinmux_hw_debug_en_i(pinmux_aon_pinmux_hw_debug_en),
      .unavailable_i(1'b0),
      .ndmreset_req_o(rv_dm_ndmreset_req),
      .dmactive_o(),
      .debug_req_o(rv_dm_debug_req),
      .sba_tl_h_o(main_tl_rv_dm__sba_req),
      .sba_tl_h_i(main_tl_rv_dm__sba_rsp),
      .regs_tl_d_i(rv_dm_regs_tl_d_req),
      .regs_tl_d_o(rv_dm_regs_tl_d_rsp),
      .mem_tl_d_i(rv_dm_mem_tl_d_req),
      .mem_tl_d_o(rv_dm_mem_tl_d_rsp),
      .scanmode_i,
      .scan_rst_ni,

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_infra),
      .rst_ni (rstmgr_aon_resets.rst_sys_n[rstmgr_pkg::Domain0Sel])
  );
  rv_ot_plic #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[27:27])
  ) u_rv_ot_plic (
      // [27]: fatal_fault
      .alert_tx_o  ( alert_tx[27:27] ),
      .alert_rx_i  ( alert_rx[27:27] ),

      // Inter-module signals
      .irq_o(rv_ot_plic_irq),
      .irq_id_o(),
      .msip_o(rv_ot_plic_msip),
      .tl_i(rv_ot_plic_tl_req),
      .tl_o(rv_ot_plic_tl_rsp),
      .intr_src_i (intr_vector),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_secure),
      .rst_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel])
  );
  aes #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[29:28]),
    .AES192Enable(1'b1),
    .SecMasking(SecAesMasking),
    .SecSBoxImpl(SecAesSBoxImpl),
    .SecStartTriggerDelay(SecAesStartTriggerDelay),
    .SecAllowForcingMasks(SecAesAllowForcingMasks),
    .SecSkipPRNGReseeding(SecAesSkipPRNGReseeding),
    .RndCnstClearingLfsrSeed(RndCnstAesClearingLfsrSeed),
    .RndCnstClearingLfsrPerm(RndCnstAesClearingLfsrPerm),
    .RndCnstClearingSharePerm(RndCnstAesClearingSharePerm),
    .RndCnstMaskingLfsrSeed(RndCnstAesMaskingLfsrSeed),
    .RndCnstMaskingLfsrPerm(RndCnstAesMaskingLfsrPerm)
  ) u_aes (
      // [28]: recov_ctrl_update_err
      // [29]: fatal_fault
      .alert_tx_o  ( alert_tx[29:28] ),
      .alert_rx_i  ( alert_rx[29:28] ),

      // Inter-module signals
      .idle_o(clkmgr_aon_idle[0]),
      .lc_escalate_en_i(lc_ctrl_lc_escalate_en),
      .edn_o(edn0_edn_req[4]),
      .edn_i(edn0_edn_rsp[4]),
      .keymgr_key_i(keymgr_aes_key),
      .tl_i(aes_tl_req),
      .tl_o(aes_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_aes),
      .clk_edn_i (clkmgr_aon_clocks.clk_main_aes),
      .rst_shadowed_ni (rstmgr_aon_resets.rst_lc_shadowed_n[rstmgr_pkg::Domain0Sel]),
      .rst_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel]),
      .rst_edn_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel])
  );
  hmac #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[30:30])
  ) u_hmac (

      // Interrupt
      .intr_hmac_done_o  (intr_hmac_hmac_done),
      .intr_fifo_empty_o (intr_hmac_fifo_empty),
      .intr_hmac_err_o   (intr_hmac_hmac_err),
      // [30]: fatal_fault
      .alert_tx_o  ( alert_tx[30:30] ),
      .alert_rx_i  ( alert_rx[30:30] ),

      // Inter-module signals
      .idle_o(clkmgr_aon_idle[1]),
      .tl_i(hmac_tl_req),
      .tl_o(hmac_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_hmac),
      .rst_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel])
  );
  kmac #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[32:31]),
    .EnMasking(KmacEnMasking),
    .SecCmdDelay(SecKmacCmdDelay),
    .SecIdleAcceptSwMsg(SecKmacIdleAcceptSwMsg),
    .RndCnstLfsrSeed(RndCnstKmacLfsrSeed),
    .RndCnstLfsrPerm(RndCnstKmacLfsrPerm),
    .RndCnstLfsrFwdPerm(RndCnstKmacLfsrFwdPerm),
    .RndCnstMsgPerm(RndCnstKmacMsgPerm)
  ) u_kmac (

      // Interrupt
      .intr_kmac_done_o  (intr_kmac_kmac_done),
      .intr_fifo_empty_o (intr_kmac_fifo_empty),
      .intr_kmac_err_o   (intr_kmac_kmac_err),
      // [31]: recov_operation_err
      // [32]: fatal_fault_err
      .alert_tx_o  ( alert_tx[32:31] ),
      .alert_rx_i  ( alert_rx[32:31] ),

      // Inter-module signals
      .keymgr_key_i(keymgr_kmac_key),
      .app_i(kmac_app_req),
      .app_o(kmac_app_rsp),
      .entropy_o(edn0_edn_req[2]),
      .entropy_i(edn0_edn_rsp[2]),
      .idle_o(clkmgr_aon_idle[2]),
      .en_masking_o(kmac_en_masking),
      .lc_escalate_en_i(lc_ctrl_lc_escalate_en),
      .tl_i(kmac_tl_req),
      .tl_o(kmac_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_kmac),
      .clk_edn_i (clkmgr_aon_clocks.clk_main_kmac),
      .rst_shadowed_ni (rstmgr_aon_resets.rst_lc_shadowed_n[rstmgr_pkg::Domain0Sel]),
      .rst_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel]),
      .rst_edn_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel])
  );
  otbn #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[34:33]),
    .Stub(OtbnStub),
    .RegFile(OtbnRegFile),
    .RndCnstUrndPrngSeed(RndCnstOtbnUrndPrngSeed),
    .RndCnstOtbnKey(RndCnstOtbnOtbnKey),
    .RndCnstOtbnNonce(RndCnstOtbnOtbnNonce)
  ) u_otbn (

      // Interrupt
      .intr_done_o (intr_otbn_done),
      // [33]: fatal
      // [34]: recov
      .alert_tx_o  ( alert_tx[34:33] ),
      .alert_rx_i  ( alert_rx[34:33] ),

      // Inter-module signals
      .otbn_otp_key_o(otp_ctrl_otbn_otp_key_req),
      .otbn_otp_key_i(otp_ctrl_otbn_otp_key_rsp),
      .edn_rnd_o(edn1_edn_req[0]),
      .edn_rnd_i(edn1_edn_rsp[0]),
      .edn_urnd_o(edn0_edn_req[5]),
      .edn_urnd_i(edn0_edn_rsp[5]),
      .idle_o(clkmgr_aon_idle[3]),
      .ram_cfg_i(prim_ram_1p_pkg::RAM_1P_CFG_DEFAULT),
      .lc_escalate_en_i(lc_ctrl_lc_escalate_en),
      .lc_rma_req_i(flash_ctrl_rma_ack),
      .lc_rma_ack_o(otbn_lc_rma_ack),
      .keymgr_key_i(keymgr_otbn_key),
      .tl_i(otbn_tl_req),
      .tl_o(otbn_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_otbn),
      .clk_edn_i (clkmgr_aon_clocks.clk_main_secure),
      .clk_otp_i (clkmgr_aon_clocks.clk_io_div4_secure),
      .rst_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel]),
      .rst_edn_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel]),
      .rst_otp_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::Domain0Sel])
  );
  keymgr #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[36:35]),
    .KmacEnMasking(KeymgrKmacEnMasking),
    .RndCnstLfsrSeed(RndCnstKeymgrLfsrSeed),
    .RndCnstLfsrPerm(RndCnstKeymgrLfsrPerm),
    .RndCnstRandPerm(RndCnstKeymgrRandPerm),
    .RndCnstRevisionSeed(RndCnstKeymgrRevisionSeed),
    .RndCnstCreatorIdentitySeed(RndCnstKeymgrCreatorIdentitySeed),
    .RndCnstOwnerIntIdentitySeed(RndCnstKeymgrOwnerIntIdentitySeed),
    .RndCnstOwnerIdentitySeed(RndCnstKeymgrOwnerIdentitySeed),
    .RndCnstSoftOutputSeed(RndCnstKeymgrSoftOutputSeed),
    .RndCnstHardOutputSeed(RndCnstKeymgrHardOutputSeed),
    .RndCnstAesSeed(RndCnstKeymgrAesSeed),
    .RndCnstKmacSeed(RndCnstKeymgrKmacSeed),
    .RndCnstOtbnSeed(RndCnstKeymgrOtbnSeed),
    .RndCnstCdi(RndCnstKeymgrCdi),
    .RndCnstNoneSeed(RndCnstKeymgrNoneSeed)
  ) u_keymgr (

      // Interrupt
      .intr_op_done_o (intr_keymgr_op_done),
      // [35]: recov_operation_err
      // [36]: fatal_fault_err
      .alert_tx_o  ( alert_tx[36:35] ),
      .alert_rx_i  ( alert_rx[36:35] ),

      // Inter-module signals
      .edn_o(edn0_edn_req[0]),
      .edn_i(edn0_edn_rsp[0]),
      .aes_key_o(keymgr_aes_key),
      .kmac_key_o(keymgr_kmac_key),
      .otbn_key_o(keymgr_otbn_key),
      .kmac_data_o(kmac_app_req[0]),
      .kmac_data_i(kmac_app_rsp[0]),
      .otp_key_i(otp_ctrl_otp_keymgr_key),
      .otp_device_id_i(keymgr_otp_device_id),
      .flash_i(flash_ctrl_keymgr),
      .lc_keymgr_en_i(lc_ctrl_lc_keymgr_en),
      .lc_keymgr_div_i(lc_ctrl_lc_keymgr_div),
      .rom_digest_i(rom_ctrl_keymgr_data),
      .kmac_en_masking_i(kmac_en_masking),
      .tl_i(keymgr_tl_req),
      .tl_o(keymgr_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_secure),
      .clk_edn_i (clkmgr_aon_clocks.clk_main_secure),
      .rst_shadowed_ni (rstmgr_aon_resets.rst_lc_shadowed_n[rstmgr_pkg::Domain0Sel]),
      .rst_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel]),
      .rst_edn_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel])
  );
  csrng #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[38:37]),
    .RndCnstCsKeymgrDivNonProduction(RndCnstCsrngCsKeymgrDivNonProduction),
    .RndCnstCsKeymgrDivProduction(RndCnstCsrngCsKeymgrDivProduction),
    .SBoxImpl(CsrngSBoxImpl)
  ) u_csrng (

      // Interrupt
      .intr_cs_cmd_req_done_o (intr_csrng_cs_cmd_req_done),
      .intr_cs_entropy_req_o  (intr_csrng_cs_entropy_req),
      .intr_cs_hw_inst_exc_o  (intr_csrng_cs_hw_inst_exc),
      .intr_cs_fatal_err_o    (intr_csrng_cs_fatal_err),
      // [37]: recov_alert
      // [38]: fatal_alert
      .alert_tx_o  ( alert_tx[38:37] ),
      .alert_rx_i  ( alert_rx[38:37] ),

      // Inter-module signals
      .csrng_cmd_i(csrng_csrng_cmd_req),
      .csrng_cmd_o(csrng_csrng_cmd_rsp),
      .entropy_src_hw_if_o(csrng_entropy_src_hw_if_req),
      .entropy_src_hw_if_i(csrng_entropy_src_hw_if_rsp),
      .cs_aes_halt_i(csrng_cs_aes_halt_req),
      .cs_aes_halt_o(csrng_cs_aes_halt_rsp),
      .otp_en_csrng_sw_app_read_i(csrng_otp_en_csrng_sw_app_read),
      .lc_hw_debug_en_i(lc_ctrl_lc_hw_debug_en),
      .tl_i(csrng_tl_req),
      .tl_o(csrng_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_secure),
      .rst_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel])
  );
  entropy_src #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[40:39]),
    .Stub(EntropySrcStub)
  ) u_entropy_src (

      // Interrupt
      .intr_es_entropy_valid_o      (intr_entropy_src_es_entropy_valid),
      .intr_es_health_test_failed_o (intr_entropy_src_es_health_test_failed),
      .intr_es_observe_fifo_ready_o (intr_entropy_src_es_observe_fifo_ready),
      .intr_es_fatal_err_o          (intr_entropy_src_es_fatal_err),
      // [39]: recov_alert
      // [40]: fatal_alert
      .alert_tx_o  ( alert_tx[40:39] ),
      .alert_rx_i  ( alert_rx[40:39] ),

      // Inter-module signals
      .entropy_src_hw_if_i(csrng_entropy_src_hw_if_req),
      .entropy_src_hw_if_o(csrng_entropy_src_hw_if_rsp),
      .cs_aes_halt_o(csrng_cs_aes_halt_req),
      .cs_aes_halt_i(csrng_cs_aes_halt_rsp),
      .entropy_src_rng_o(),
      .entropy_src_rng_i(entropy_src_pkg::ENTROPY_SRC_RNG_RSP_DEFAULT),
      .entropy_src_xht_o(),
      .entropy_src_xht_i(entropy_src_pkg::ENTROPY_SRC_XHT_RSP_DEFAULT),
      .otp_en_entropy_src_fw_read_i(entropy_src_otp_en_entropy_src_fw_read),
      .otp_en_entropy_src_fw_over_i(entropy_src_otp_en_entropy_src_fw_over),
      .rng_fips_o(),
      .tl_i(entropy_src_tl_req),
      .tl_o(entropy_src_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_secure),
      .rst_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel])
  );
  edn #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[42:41])
  ) u_edn0 (

      // Interrupt
      .intr_edn_cmd_req_done_o (intr_edn0_edn_cmd_req_done),
      .intr_edn_fatal_err_o    (intr_edn0_edn_fatal_err),
      // [41]: recov_alert
      // [42]: fatal_alert
      .alert_tx_o  ( alert_tx[42:41] ),
      .alert_rx_i  ( alert_rx[42:41] ),

      // Inter-module signals
      .csrng_cmd_o(csrng_csrng_cmd_req[0]),
      .csrng_cmd_i(csrng_csrng_cmd_rsp[0]),
      .edn_i(edn0_edn_req),
      .edn_o(edn0_edn_rsp),
      .tl_i(edn0_tl_req),
      .tl_o(edn0_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_secure),
      .rst_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel])
  );
  edn #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[44:43])
  ) u_edn1 (

      // Interrupt
      .intr_edn_cmd_req_done_o (intr_edn1_edn_cmd_req_done),
      .intr_edn_fatal_err_o    (intr_edn1_edn_fatal_err),
      // [43]: recov_alert
      // [44]: fatal_alert
      .alert_tx_o  ( alert_tx[44:43] ),
      .alert_rx_i  ( alert_rx[44:43] ),

      // Inter-module signals
      .csrng_cmd_o(csrng_csrng_cmd_req[1]),
      .csrng_cmd_i(csrng_csrng_cmd_rsp[1]),
      .edn_i(edn1_edn_req),
      .edn_o(edn1_edn_rsp),
      .tl_i(edn1_tl_req),
      .tl_o(edn1_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_secure),
      .rst_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel])
  );
  sram_ctrl #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[45:45]),
    .RndCnstSramKey(RndCnstSramCtrlMainSramKey),
    .RndCnstSramNonce(RndCnstSramCtrlMainSramNonce),
    .RndCnstLfsrSeed(RndCnstSramCtrlMainLfsrSeed),
    .RndCnstLfsrPerm(RndCnstSramCtrlMainLfsrPerm),
    .MemSizeRam(131072),
    .InstrExec(SramCtrlMainInstrExec)
  ) u_sram_ctrl_main (
      // [45]: fatal_error
      .alert_tx_o  ( alert_tx[45:45] ),
      .alert_rx_i  ( alert_rx[45:45] ),

      // Inter-module signals
      .sram_otp_key_o(otp_ctrl_sram_otp_key_req[0]),
      .sram_otp_key_i(otp_ctrl_sram_otp_key_rsp[0]),
      .cfg_i('0),
      .lc_escalate_en_i(lc_ctrl_lc_escalate_en),
      .lc_hw_debug_en_i(lc_ctrl_lc_hw_debug_en),
      .otp_en_sram_ifetch_i(sram_ctrl_main_otp_en_sram_ifetch),
      .regs_tl_i(sram_ctrl_main_regs_tl_req),
      .regs_tl_o(sram_ctrl_main_regs_tl_rsp),
      .ram_tl_i(sram_ctrl_main_ram_tl_req),
      .ram_tl_o(sram_ctrl_main_ram_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_infra),
      .clk_otp_i (clkmgr_aon_clocks.clk_io_div4_infra),
      .rst_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel]),
      .rst_otp_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::Domain0Sel])
  );
  rom_ctrl #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[46:46]),
    .BootRomInitFile(RomCtrlBootRomInitFile),
    .RndCnstScrNonce(RndCnstRomCtrlScrNonce),
    .RndCnstScrKey(RndCnstRomCtrlScrKey),
    .SecDisableScrambling(SecRomCtrlDisableScrambling)
  ) u_rom_ctrl (
      // [46]: fatal
      .alert_tx_o  ( alert_tx[46:46] ),
      .alert_rx_i  ( alert_rx[46:46] ),

      // Inter-module signals
      .rom_cfg_i(prim_rom_pkg::ROM_CFG_DEFAULT),
      .pwrmgr_data_o(rom_ctrl_pwrmgr_data),
      .keymgr_data_o(rom_ctrl_keymgr_data),
      .kmac_data_o(kmac_app_req[2]),
      .kmac_data_i(kmac_app_rsp[2]),
      .regs_tl_i(rom_ctrl_regs_tl_req),
      .regs_tl_o(rom_ctrl_regs_tl_rsp),
      .rom_tl_i(rom_ctrl_rom_tl_req),
      .rom_tl_o(rom_ctrl_rom_tl_rsp),

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_infra),
      .rst_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel])
  );
  rv_core_ibex #(
    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[50:47]),
    .RndCnstLfsrSeed(RndCnstRvCoreIbexLfsrSeed),
    .RndCnstLfsrPerm(RndCnstRvCoreIbexLfsrPerm),
    .RndCnstIbexKeyDefault(RndCnstRvCoreIbexIbexKeyDefault),
    .RndCnstIbexNonceDefault(RndCnstRvCoreIbexIbexNonceDefault),
    .PMPEnable(RvCoreIbexPMPEnable),
    .PMPGranularity(RvCoreIbexPMPGranularity),
    .PMPNumRegions(RvCoreIbexPMPNumRegions),
    .MHPMCounterNum(RvCoreIbexMHPMCounterNum),
    .MHPMCounterWidth(RvCoreIbexMHPMCounterWidth),
    .RV32E(RvCoreIbexRV32E),
    .RV32M(RvCoreIbexRV32M),
    .RV32B(RvCoreIbexRV32B),
    .RegFile(RvCoreIbexRegFile),
    .BranchTargetALU(RvCoreIbexBranchTargetALU),
    .WritebackStage(RvCoreIbexWritebackStage),
    .ICache(RvCoreIbexICache),
    .ICacheECC(RvCoreIbexICacheECC),
    .ICacheScramble(RvCoreIbexICacheScramble),
    .BranchPredictor(RvCoreIbexBranchPredictor),
    .DbgTriggerEn(RvCoreIbexDbgTriggerEn),
    .DbgHwBreakNum(RvCoreIbexDbgHwBreakNum),
    .SecureIbex(RvCoreIbexSecureIbex),
    .DmHaltAddr(RvCoreIbexDmHaltAddr),
    .DmExceptionAddr(RvCoreIbexDmExceptionAddr),
    .PipeLine(RvCoreIbexPipeLine)
  ) u_rv_core_ibex (
      // [47]: fatal_sw_err
      // [48]: recov_sw_err
      // [49]: fatal_hw_err
      // [50]: recov_hw_err
      .alert_tx_o  ( alert_tx[50:47] ),
      .alert_rx_i  ( alert_rx[50:47] ),

      // Inter-module signals
      .rst_cpu_n_o(),
      .ram_cfg_i(prim_ram_1p_pkg::RAM_1P_CFG_DEFAULT),
      .hart_id_i(rv_core_ibex_hart_id),
      .boot_addr_i(rv_core_ibex_boot_addr),
      .irq_software_i(rv_ot_plic_msip),
      .irq_timer_i(rv_core_ibex_irq_timer),
      .irq_external_i(rv_ot_plic_irq),
      .esc_tx_i(alert_handler_esc_tx[0]),
      .esc_rx_o(alert_handler_esc_rx[0]),
      .debug_req_i(rv_dm_debug_req),
      .crash_dump_o(rv_core_ibex_crash_dump),
      .lc_cpu_en_i(lc_ctrl_lc_cpu_en),
      .pwrmgr_cpu_en_i(pwrmgr_aon_fetch_en),
      .pwrmgr_o(rv_core_ibex_pwrmgr),
      .nmi_wdog_i(aon_timer_aon_nmi_wdog_timer_bark),
      .edn_o(edn0_edn_req[6]),
      .edn_i(edn0_edn_rsp[6]),
      .icache_otp_key_o(otp_ctrl_sram_otp_key_req[2]),
      .icache_otp_key_i(otp_ctrl_sram_otp_key_rsp[2]),
      .fpga_info_i('0),
      .corei_tl_h_o(main_tl_rv_core_ibex__corei_req),
      .corei_tl_h_i(main_tl_rv_core_ibex__corei_rsp),
      .cored_tl_h_o(main_tl_rv_core_ibex__cored_req),
      .cored_tl_h_i(main_tl_rv_core_ibex__cored_rsp),
      .cfg_tl_d_i(rv_core_ibex_cfg_tl_d_req),
      .cfg_tl_d_o(rv_core_ibex_cfg_tl_d_rsp),
      .scanmode_i,
      .scan_rst_ni,

      // Clock and reset connections
      .clk_i (clkmgr_aon_clocks.clk_main_infra),
      .clk_edn_i (clkmgr_aon_clocks.clk_main_infra),
      .clk_esc_i (clkmgr_aon_clocks.clk_io_div4_secure),
      .clk_otp_i (clkmgr_aon_clocks.clk_io_div4_secure),
      .rst_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel]),
      .rst_edn_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel]),
      .rst_esc_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::Domain0Sel]),
      .rst_otp_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::Domain0Sel])
  );
  // interrupt assignments
  assign intr_vector = {
      intr_edn1_edn_fatal_err, // IDs [71 +: 1]
      intr_edn1_edn_cmd_req_done, // IDs [70 +: 1]
      intr_edn0_edn_fatal_err, // IDs [69 +: 1]
      intr_edn0_edn_cmd_req_done, // IDs [68 +: 1]
      intr_entropy_src_es_fatal_err, // IDs [67 +: 1]
      intr_entropy_src_es_observe_fifo_ready, // IDs [66 +: 1]
      intr_entropy_src_es_health_test_failed, // IDs [65 +: 1]
      intr_entropy_src_es_entropy_valid, // IDs [64 +: 1]
      intr_csrng_cs_fatal_err, // IDs [63 +: 1]
      intr_csrng_cs_hw_inst_exc, // IDs [62 +: 1]
      intr_csrng_cs_entropy_req, // IDs [61 +: 1]
      intr_csrng_cs_cmd_req_done, // IDs [60 +: 1]
      intr_keymgr_op_done, // IDs [59 +: 1]
      intr_otbn_done, // IDs [58 +: 1]
      intr_kmac_kmac_err, // IDs [57 +: 1]
      intr_kmac_fifo_empty, // IDs [56 +: 1]
      intr_kmac_kmac_done, // IDs [55 +: 1]
      intr_hmac_hmac_err, // IDs [54 +: 1]
      intr_hmac_fifo_empty, // IDs [53 +: 1]
      intr_hmac_hmac_done, // IDs [52 +: 1]
      intr_flash_ctrl_corr_err, // IDs [51 +: 1]
      intr_flash_ctrl_op_done, // IDs [50 +: 1]
      intr_flash_ctrl_rd_lvl, // IDs [49 +: 1]
      intr_flash_ctrl_rd_full, // IDs [48 +: 1]
      intr_flash_ctrl_prog_lvl, // IDs [47 +: 1]
      intr_flash_ctrl_prog_empty, // IDs [46 +: 1]
      intr_aon_timer_aon_wdog_timer_bark, // IDs [45 +: 1]
      intr_aon_timer_aon_wkup_timer_expired, // IDs [44 +: 1]
      irq_ibex_i, //intr_sysrst_ctrl_aon_event_detected, // IDs [43 +: 1]
      intr_pwrmgr_aon_wakeup, // IDs [42 +: 1]
      intr_alert_handler_classd, // IDs [41 +: 1]
      intr_alert_handler_classc, // IDs [40 +: 1]
      intr_alert_handler_classb, // IDs [39 +: 1]
      intr_alert_handler_classa, // IDs [38 +: 1]
      intr_otp_ctrl_otp_error, // IDs [37 +: 1]
      intr_otp_ctrl_otp_operation_done, // IDs [36 +: 1]
      intr_rv_timer_timer_expired_hart0_timer0, // IDs [35 +: 1]
      intr_pattgen_done_ch1, // IDs [34 +: 1]
      intr_pattgen_done_ch0, // IDs [33 +: 1]
      intr_gpio_gpio, // IDs [1 +: 32]
      1'b 0 // ID [0 +: 1] is a special case and tied to zero.
  };

  // TL-UL Crossbar
  xbar_main u_xbar_main (
    .clk_main_i (clkmgr_aon_clocks.clk_main_infra),
    .clk_fixed_i (clkmgr_aon_clocks.clk_io_div4_infra),
    .rst_main_ni (rstmgr_aon_resets.rst_lc_n[rstmgr_pkg::Domain0Sel]),
    .rst_fixed_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::Domain0Sel]),

    // port: tl_rv_core_ibex__corei
    .tl_rv_core_ibex__corei_i(main_tl_rv_core_ibex__corei_req),
    .tl_rv_core_ibex__corei_o(main_tl_rv_core_ibex__corei_rsp),

    // port: tl_rv_core_ibex__cored
    .tl_rv_core_ibex__cored_i(main_tl_rv_core_ibex__cored_req),
    .tl_rv_core_ibex__cored_o(main_tl_rv_core_ibex__cored_rsp),

    // port: tl_rv_dm__sba
    .tl_rv_dm__sba_i(main_tl_rv_dm__sba_req),
    .tl_rv_dm__sba_o(main_tl_rv_dm__sba_rsp),

    // port: tl_rv_dm__regs
    .tl_rv_dm__regs_o(rv_dm_regs_tl_d_req),
    .tl_rv_dm__regs_i(rv_dm_regs_tl_d_rsp),

    // port: tl_rv_dm__mem
    .tl_rv_dm__mem_o(rv_dm_mem_tl_d_req),
    .tl_rv_dm__mem_i(rv_dm_mem_tl_d_rsp),

    // port: tl_rom_ctrl__rom
    .tl_rom_ctrl__rom_o(rom_ctrl_rom_tl_req),
    .tl_rom_ctrl__rom_i(rom_ctrl_rom_tl_rsp),

    // port: tl_rom_ctrl__regs
    .tl_rom_ctrl__regs_o(rom_ctrl_regs_tl_req),
    .tl_rom_ctrl__regs_i(rom_ctrl_regs_tl_rsp),

    // port: tl_peri
    .tl_peri_o(main_tl_peri_req),
    .tl_peri_i(main_tl_peri_rsp),

    // port: tl_tlul2axi
    .tl_tlul2axi_o(tlul2axi_tl_req),
    .tl_tlul2axi_i(tlul2axi_tl_rsp),

    // port: tl_flash_ctrl__core
    .tl_flash_ctrl__core_o(flash_ctrl_core_tl_req),
    .tl_flash_ctrl__core_i(flash_ctrl_core_tl_rsp),

    // port: tl_flash_ctrl__prim
    .tl_flash_ctrl__prim_o(flash_ctrl_prim_tl_req),
    .tl_flash_ctrl__prim_i(flash_ctrl_prim_tl_rsp),

    // port: tl_flash_ctrl__mem
    .tl_flash_ctrl__mem_o(flash_ctrl_mem_tl_req),
    .tl_flash_ctrl__mem_i(flash_ctrl_mem_tl_rsp),

    // port: tl_hmac
    .tl_hmac_o(hmac_tl_req),
    .tl_hmac_i(hmac_tl_rsp),

    // port: tl_kmac
    .tl_kmac_o(kmac_tl_req),
    .tl_kmac_i(kmac_tl_rsp),

    // port: tl_aes
    .tl_aes_o(aes_tl_req),
    .tl_aes_i(aes_tl_rsp),

    // port: tl_entropy_src
    .tl_entropy_src_o(entropy_src_tl_req),
    .tl_entropy_src_i(entropy_src_tl_rsp),

    // port: tl_csrng
    .tl_csrng_o(csrng_tl_req),
    .tl_csrng_i(csrng_tl_rsp),

    // port: tl_edn0
    .tl_edn0_o(edn0_tl_req),
    .tl_edn0_i(edn0_tl_rsp),

    // port: tl_edn1
    .tl_edn1_o(edn1_tl_req),
    .tl_edn1_i(edn1_tl_rsp),

    // port: tl_rv_ot_plic
    .tl_rv_ot_plic_o(rv_ot_plic_tl_req),
    .tl_rv_ot_plic_i(rv_ot_plic_tl_rsp),

    // port: tl_otbn
    .tl_otbn_o(otbn_tl_req),
    .tl_otbn_i(otbn_tl_rsp),

    // port: tl_keymgr
    .tl_keymgr_o(keymgr_tl_req),
    .tl_keymgr_i(keymgr_tl_rsp),

    // port: tl_rv_core_ibex__cfg
    .tl_rv_core_ibex__cfg_o(rv_core_ibex_cfg_tl_d_req),
    .tl_rv_core_ibex__cfg_i(rv_core_ibex_cfg_tl_d_rsp),

    // port: tl_sram_ctrl_main__regs
    .tl_sram_ctrl_main__regs_o(sram_ctrl_main_regs_tl_req),
    .tl_sram_ctrl_main__regs_i(sram_ctrl_main_regs_tl_rsp),

    // port: tl_sram_ctrl_main__ram
    .tl_sram_ctrl_main__ram_o(sram_ctrl_main_ram_tl_req),
    .tl_sram_ctrl_main__ram_i(sram_ctrl_main_ram_tl_rsp),


    .scanmode_i
  );
  xbar_peri u_xbar_peri (
    .clk_peri_i (clkmgr_aon_clocks.clk_io_div4_infra),
    .rst_peri_ni (rstmgr_aon_resets.rst_lc_io_div4_n[rstmgr_pkg::Domain0Sel]),

    // port: tl_main
    .tl_main_i(main_tl_peri_req),
    .tl_main_o(main_tl_peri_rsp),

    // port: tl_pattgen
    .tl_pattgen_o(pattgen_tl_req),
    .tl_pattgen_i(pattgen_tl_rsp),

    // port: tl_pwm_aon
    .tl_pwm_aon_o(pwm_aon_tl_req),
    .tl_pwm_aon_i(pwm_aon_tl_rsp),

    // port: tl_gpio
    .tl_gpio_o(gpio_tl_req),
    .tl_gpio_i(gpio_tl_rsp),

    // port: tl_rv_timer
    .tl_rv_timer_o(rv_timer_tl_req),
    .tl_rv_timer_i(rv_timer_tl_rsp),

    // port: tl_pwrmgr_aon
    .tl_pwrmgr_aon_o(pwrmgr_aon_tl_req),
    .tl_pwrmgr_aon_i(pwrmgr_aon_tl_rsp),

    // port: tl_rstmgr_aon
    .tl_rstmgr_aon_o(rstmgr_aon_tl_req),
    .tl_rstmgr_aon_i(rstmgr_aon_tl_rsp),

    // port: tl_clkmgr_aon
    .tl_clkmgr_aon_o(clkmgr_aon_tl_req),
    .tl_clkmgr_aon_i(clkmgr_aon_tl_rsp),

    // port: tl_pinmux_aon
    .tl_pinmux_aon_o(pinmux_aon_tl_req),
    .tl_pinmux_aon_i(pinmux_aon_tl_rsp),

    // port: tl_otp_ctrl__core
    .tl_otp_ctrl__core_o(otp_ctrl_core_tl_req),
    .tl_otp_ctrl__core_i(otp_ctrl_core_tl_rsp),

    // port: tl_otp_ctrl__prim
    .tl_otp_ctrl__prim_o(otp_ctrl_prim_tl_req),
    .tl_otp_ctrl__prim_i(otp_ctrl_prim_tl_rsp),

    // port: tl_lc_ctrl
    .tl_lc_ctrl_o(lc_ctrl_tl_req),
    .tl_lc_ctrl_i(lc_ctrl_tl_rsp),

    // port: tl_alert_handler
    .tl_alert_handler_o(alert_handler_tl_req),
    .tl_alert_handler_i(alert_handler_tl_rsp),

    // port: tl_sram_ctrl_ret_aon__regs
    .tl_sram_ctrl_ret_aon__regs_o(sram_ctrl_ret_aon_regs_tl_req),
    .tl_sram_ctrl_ret_aon__regs_i(sram_ctrl_ret_aon_regs_tl_rsp),

    // port: tl_sram_ctrl_ret_aon__ram
    .tl_sram_ctrl_ret_aon__ram_o(sram_ctrl_ret_aon_ram_tl_req),
    .tl_sram_ctrl_ret_aon__ram_i(sram_ctrl_ret_aon_ram_tl_rsp),

    // port: tl_aon_timer_aon
    .tl_aon_timer_aon_o(aon_timer_aon_tl_req),
    .tl_aon_timer_aon_i(aon_timer_aon_tl_rsp),

    // port: tl_sysrst_ctrl_aon
    .tl_sysrst_ctrl_aon_o(sysrst_ctrl_aon_tl_req),
    .tl_sysrst_ctrl_aon_i(sysrst_ctrl_aon_tl_rsp),


    .scanmode_i
  );

  // Pinmux connections
  // All muxed inputs
  assign cio_gpio_gpio_p2d[0] = mio_p2d[MioInGpioGpio0];
  assign cio_gpio_gpio_p2d[1] = mio_p2d[MioInGpioGpio1];
  assign cio_gpio_gpio_p2d[2] = mio_p2d[MioInGpioGpio2];
  assign cio_gpio_gpio_p2d[3] = mio_p2d[MioInGpioGpio3];
  assign cio_gpio_gpio_p2d[4] = mio_p2d[MioInGpioGpio4];
  assign cio_gpio_gpio_p2d[5] = mio_p2d[MioInGpioGpio5];
  assign cio_gpio_gpio_p2d[6] = mio_p2d[MioInGpioGpio6];
  assign cio_gpio_gpio_p2d[7] = mio_p2d[MioInGpioGpio7];
  assign cio_gpio_gpio_p2d[8] = mio_p2d[MioInGpioGpio8];
  assign cio_gpio_gpio_p2d[9] = mio_p2d[MioInGpioGpio9];
  assign cio_gpio_gpio_p2d[10] = mio_p2d[MioInGpioGpio10];
  assign cio_gpio_gpio_p2d[11] = mio_p2d[MioInGpioGpio11];
  assign cio_gpio_gpio_p2d[12] = mio_p2d[MioInGpioGpio12];
  assign cio_gpio_gpio_p2d[13] = mio_p2d[MioInGpioGpio13];
  assign cio_gpio_gpio_p2d[14] = mio_p2d[MioInGpioGpio14];
  assign cio_gpio_gpio_p2d[15] = mio_p2d[MioInGpioGpio15];
  assign cio_gpio_gpio_p2d[16] = mio_p2d[MioInGpioGpio16];
  assign cio_gpio_gpio_p2d[17] = mio_p2d[MioInGpioGpio17];
  assign cio_gpio_gpio_p2d[18] = mio_p2d[MioInGpioGpio18];
  assign cio_gpio_gpio_p2d[19] = mio_p2d[MioInGpioGpio19];
  assign cio_gpio_gpio_p2d[20] = mio_p2d[MioInGpioGpio20];
  assign cio_gpio_gpio_p2d[21] = mio_p2d[MioInGpioGpio21];
  assign cio_gpio_gpio_p2d[22] = mio_p2d[MioInGpioGpio22];
  assign cio_gpio_gpio_p2d[23] = mio_p2d[MioInGpioGpio23];
  assign cio_gpio_gpio_p2d[24] = mio_p2d[MioInGpioGpio24];
  assign cio_gpio_gpio_p2d[25] = mio_p2d[MioInGpioGpio25];
  assign cio_gpio_gpio_p2d[26] = mio_p2d[MioInGpioGpio26];
  assign cio_gpio_gpio_p2d[27] = mio_p2d[MioInGpioGpio27];
  assign cio_gpio_gpio_p2d[28] = mio_p2d[MioInGpioGpio28];
  assign cio_gpio_gpio_p2d[29] = mio_p2d[MioInGpioGpio29];
  assign cio_gpio_gpio_p2d[30] = mio_p2d[MioInGpioGpio30];
  assign cio_gpio_gpio_p2d[31] = mio_p2d[MioInGpioGpio31];
  assign cio_flash_ctrl_tck_p2d = mio_p2d[MioInFlashCtrlTck];
  assign cio_flash_ctrl_tms_p2d = mio_p2d[MioInFlashCtrlTms];
  assign cio_flash_ctrl_tdi_p2d = mio_p2d[MioInFlashCtrlTdi];
  assign cio_sysrst_ctrl_aon_ac_present_p2d = mio_p2d[MioInSysrstCtrlAonAcPresent];
  assign cio_sysrst_ctrl_aon_key0_in_p2d = mio_p2d[MioInSysrstCtrlAonKey0In];
  assign cio_sysrst_ctrl_aon_key1_in_p2d = mio_p2d[MioInSysrstCtrlAonKey1In];
  assign cio_sysrst_ctrl_aon_key2_in_p2d = mio_p2d[MioInSysrstCtrlAonKey2In];
  assign cio_sysrst_ctrl_aon_pwrb_in_p2d = mio_p2d[MioInSysrstCtrlAonPwrbIn];
  assign cio_sysrst_ctrl_aon_lid_open_p2d = mio_p2d[MioInSysrstCtrlAonLidOpen];

  // All muxed outputs
  assign mio_d2p[MioOutGpioGpio0] = cio_gpio_gpio_d2p[0];
  assign mio_d2p[MioOutGpioGpio1] = cio_gpio_gpio_d2p[1];
  assign mio_d2p[MioOutGpioGpio2] = cio_gpio_gpio_d2p[2];
  assign mio_d2p[MioOutGpioGpio3] = cio_gpio_gpio_d2p[3];
  assign mio_d2p[MioOutGpioGpio4] = cio_gpio_gpio_d2p[4];
  assign mio_d2p[MioOutGpioGpio5] = cio_gpio_gpio_d2p[5];
  assign mio_d2p[MioOutGpioGpio6] = cio_gpio_gpio_d2p[6];
  assign mio_d2p[MioOutGpioGpio7] = cio_gpio_gpio_d2p[7];
  assign mio_d2p[MioOutGpioGpio8] = cio_gpio_gpio_d2p[8];
  assign mio_d2p[MioOutGpioGpio9] = cio_gpio_gpio_d2p[9];
  assign mio_d2p[MioOutGpioGpio10] = cio_gpio_gpio_d2p[10];
  assign mio_d2p[MioOutGpioGpio11] = cio_gpio_gpio_d2p[11];
  assign mio_d2p[MioOutGpioGpio12] = cio_gpio_gpio_d2p[12];
  assign mio_d2p[MioOutGpioGpio13] = cio_gpio_gpio_d2p[13];
  assign mio_d2p[MioOutGpioGpio14] = cio_gpio_gpio_d2p[14];
  assign mio_d2p[MioOutGpioGpio15] = cio_gpio_gpio_d2p[15];
  assign mio_d2p[MioOutGpioGpio16] = cio_gpio_gpio_d2p[16];
  assign mio_d2p[MioOutGpioGpio17] = cio_gpio_gpio_d2p[17];
  assign mio_d2p[MioOutGpioGpio18] = cio_gpio_gpio_d2p[18];
  assign mio_d2p[MioOutGpioGpio19] = cio_gpio_gpio_d2p[19];
  assign mio_d2p[MioOutGpioGpio20] = cio_gpio_gpio_d2p[20];
  assign mio_d2p[MioOutGpioGpio21] = cio_gpio_gpio_d2p[21];
  assign mio_d2p[MioOutGpioGpio22] = cio_gpio_gpio_d2p[22];
  assign mio_d2p[MioOutGpioGpio23] = cio_gpio_gpio_d2p[23];
  assign mio_d2p[MioOutGpioGpio24] = cio_gpio_gpio_d2p[24];
  assign mio_d2p[MioOutGpioGpio25] = cio_gpio_gpio_d2p[25];
  assign mio_d2p[MioOutGpioGpio26] = cio_gpio_gpio_d2p[26];
  assign mio_d2p[MioOutGpioGpio27] = cio_gpio_gpio_d2p[27];
  assign mio_d2p[MioOutGpioGpio28] = cio_gpio_gpio_d2p[28];
  assign mio_d2p[MioOutGpioGpio29] = cio_gpio_gpio_d2p[29];
  assign mio_d2p[MioOutGpioGpio30] = cio_gpio_gpio_d2p[30];
  assign mio_d2p[MioOutGpioGpio31] = cio_gpio_gpio_d2p[31];
  assign mio_d2p[MioOutPattgenPda0Tx] = cio_pattgen_pda0_tx_d2p;
  assign mio_d2p[MioOutPattgenPcl0Tx] = cio_pattgen_pcl0_tx_d2p;
  assign mio_d2p[MioOutPattgenPda1Tx] = cio_pattgen_pda1_tx_d2p;
  assign mio_d2p[MioOutPattgenPcl1Tx] = cio_pattgen_pcl1_tx_d2p;
  assign mio_d2p[MioOutFlashCtrlTdo] = cio_flash_ctrl_tdo_d2p;
  assign mio_d2p[MioOutPwmAonPwm0] = cio_pwm_aon_pwm_d2p[0];
  assign mio_d2p[MioOutPwmAonPwm1] = cio_pwm_aon_pwm_d2p[1];
  assign mio_d2p[MioOutPwmAonPwm2] = cio_pwm_aon_pwm_d2p[2];
  assign mio_d2p[MioOutPwmAonPwm3] = cio_pwm_aon_pwm_d2p[3];
  assign mio_d2p[MioOutPwmAonPwm4] = cio_pwm_aon_pwm_d2p[4];
  assign mio_d2p[MioOutPwmAonPwm5] = cio_pwm_aon_pwm_d2p[5];
  assign mio_d2p[MioOutOtpCtrlTest0] = cio_otp_ctrl_test_d2p[0];
  assign mio_d2p[MioOutSysrstCtrlAonBatDisable] = cio_sysrst_ctrl_aon_bat_disable_d2p;
  assign mio_d2p[MioOutSysrstCtrlAonKey0Out] = cio_sysrst_ctrl_aon_key0_out_d2p;
  assign mio_d2p[MioOutSysrstCtrlAonKey1Out] = cio_sysrst_ctrl_aon_key1_out_d2p;
  assign mio_d2p[MioOutSysrstCtrlAonKey2Out] = cio_sysrst_ctrl_aon_key2_out_d2p;
  assign mio_d2p[MioOutSysrstCtrlAonPwrbOut] = cio_sysrst_ctrl_aon_pwrb_out_d2p;
  assign mio_d2p[MioOutSysrstCtrlAonZ3Wakeup] = cio_sysrst_ctrl_aon_z3_wakeup_d2p;

  // All muxed output enables
  assign mio_en_d2p[MioOutGpioGpio0] = cio_gpio_gpio_en_d2p[0];
  assign mio_en_d2p[MioOutGpioGpio1] = cio_gpio_gpio_en_d2p[1];
  assign mio_en_d2p[MioOutGpioGpio2] = cio_gpio_gpio_en_d2p[2];
  assign mio_en_d2p[MioOutGpioGpio3] = cio_gpio_gpio_en_d2p[3];
  assign mio_en_d2p[MioOutGpioGpio4] = cio_gpio_gpio_en_d2p[4];
  assign mio_en_d2p[MioOutGpioGpio5] = cio_gpio_gpio_en_d2p[5];
  assign mio_en_d2p[MioOutGpioGpio6] = cio_gpio_gpio_en_d2p[6];
  assign mio_en_d2p[MioOutGpioGpio7] = cio_gpio_gpio_en_d2p[7];
  assign mio_en_d2p[MioOutGpioGpio8] = cio_gpio_gpio_en_d2p[8];
  assign mio_en_d2p[MioOutGpioGpio9] = cio_gpio_gpio_en_d2p[9];
  assign mio_en_d2p[MioOutGpioGpio10] = cio_gpio_gpio_en_d2p[10];
  assign mio_en_d2p[MioOutGpioGpio11] = cio_gpio_gpio_en_d2p[11];
  assign mio_en_d2p[MioOutGpioGpio12] = cio_gpio_gpio_en_d2p[12];
  assign mio_en_d2p[MioOutGpioGpio13] = cio_gpio_gpio_en_d2p[13];
  assign mio_en_d2p[MioOutGpioGpio14] = cio_gpio_gpio_en_d2p[14];
  assign mio_en_d2p[MioOutGpioGpio15] = cio_gpio_gpio_en_d2p[15];
  assign mio_en_d2p[MioOutGpioGpio16] = cio_gpio_gpio_en_d2p[16];
  assign mio_en_d2p[MioOutGpioGpio17] = cio_gpio_gpio_en_d2p[17];
  assign mio_en_d2p[MioOutGpioGpio18] = cio_gpio_gpio_en_d2p[18];
  assign mio_en_d2p[MioOutGpioGpio19] = cio_gpio_gpio_en_d2p[19];
  assign mio_en_d2p[MioOutGpioGpio20] = cio_gpio_gpio_en_d2p[20];
  assign mio_en_d2p[MioOutGpioGpio21] = cio_gpio_gpio_en_d2p[21];
  assign mio_en_d2p[MioOutGpioGpio22] = cio_gpio_gpio_en_d2p[22];
  assign mio_en_d2p[MioOutGpioGpio23] = cio_gpio_gpio_en_d2p[23];
  assign mio_en_d2p[MioOutGpioGpio24] = cio_gpio_gpio_en_d2p[24];
  assign mio_en_d2p[MioOutGpioGpio25] = cio_gpio_gpio_en_d2p[25];
  assign mio_en_d2p[MioOutGpioGpio26] = cio_gpio_gpio_en_d2p[26];
  assign mio_en_d2p[MioOutGpioGpio27] = cio_gpio_gpio_en_d2p[27];
  assign mio_en_d2p[MioOutGpioGpio28] = cio_gpio_gpio_en_d2p[28];
  assign mio_en_d2p[MioOutGpioGpio29] = cio_gpio_gpio_en_d2p[29];
  assign mio_en_d2p[MioOutGpioGpio30] = cio_gpio_gpio_en_d2p[30];
  assign mio_en_d2p[MioOutGpioGpio31] = cio_gpio_gpio_en_d2p[31];
  assign mio_en_d2p[MioOutPattgenPda0Tx] = cio_pattgen_pda0_tx_en_d2p;
  assign mio_en_d2p[MioOutPattgenPcl0Tx] = cio_pattgen_pcl0_tx_en_d2p;
  assign mio_en_d2p[MioOutPattgenPda1Tx] = cio_pattgen_pda1_tx_en_d2p;
  assign mio_en_d2p[MioOutPattgenPcl1Tx] = cio_pattgen_pcl1_tx_en_d2p;
  assign mio_en_d2p[MioOutFlashCtrlTdo] = cio_flash_ctrl_tdo_en_d2p;
  assign mio_en_d2p[MioOutPwmAonPwm0] = cio_pwm_aon_pwm_en_d2p[0];
  assign mio_en_d2p[MioOutPwmAonPwm1] = cio_pwm_aon_pwm_en_d2p[1];
  assign mio_en_d2p[MioOutPwmAonPwm2] = cio_pwm_aon_pwm_en_d2p[2];
  assign mio_en_d2p[MioOutPwmAonPwm3] = cio_pwm_aon_pwm_en_d2p[3];
  assign mio_en_d2p[MioOutPwmAonPwm4] = cio_pwm_aon_pwm_en_d2p[4];
  assign mio_en_d2p[MioOutPwmAonPwm5] = cio_pwm_aon_pwm_en_d2p[5];
  assign mio_en_d2p[MioOutOtpCtrlTest0] = cio_otp_ctrl_test_en_d2p[0];
  assign mio_en_d2p[MioOutSysrstCtrlAonBatDisable] = cio_sysrst_ctrl_aon_bat_disable_en_d2p;
  assign mio_en_d2p[MioOutSysrstCtrlAonKey0Out] = cio_sysrst_ctrl_aon_key0_out_en_d2p;
  assign mio_en_d2p[MioOutSysrstCtrlAonKey1Out] = cio_sysrst_ctrl_aon_key1_out_en_d2p;
  assign mio_en_d2p[MioOutSysrstCtrlAonKey2Out] = cio_sysrst_ctrl_aon_key2_out_en_d2p;
  assign mio_en_d2p[MioOutSysrstCtrlAonPwrbOut] = cio_sysrst_ctrl_aon_pwrb_out_en_d2p;
  assign mio_en_d2p[MioOutSysrstCtrlAonZ3Wakeup] = cio_sysrst_ctrl_aon_z3_wakeup_en_d2p;

  // All dedicated inputs
  logic [1:0] unused_dio_p2d;
  assign unused_dio_p2d = dio_p2d;
  assign cio_sysrst_ctrl_aon_ec_rst_l_p2d = dio_p2d[DioSysrstCtrlAonEcRstL];
  assign cio_sysrst_ctrl_aon_flash_wp_l_p2d = dio_p2d[DioSysrstCtrlAonFlashWpL];

    // All dedicated outputs
  assign dio_d2p[DioSysrstCtrlAonEcRstL] = cio_sysrst_ctrl_aon_ec_rst_l_d2p;
  assign dio_d2p[DioSysrstCtrlAonFlashWpL] = cio_sysrst_ctrl_aon_flash_wp_l_d2p;

  // All dedicated output enables
  assign dio_en_d2p[DioSysrstCtrlAonEcRstL] = cio_sysrst_ctrl_aon_ec_rst_l_en_d2p;
  assign dio_en_d2p[DioSysrstCtrlAonFlashWpL] = cio_sysrst_ctrl_aon_flash_wp_l_en_d2p;


  // make sure scanmode_i is never X (including during reset)
  `ASSERT_KNOWN(scanmodeKnown, scanmode_i, clk_main_i, 0)

endmodule
