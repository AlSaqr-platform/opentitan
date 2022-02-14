// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// VCS does not support overriding enum and string parameters via command line. Instead, a `define
// is used that can be set from the command line. If no value has been specified, this gives a
// default. Other simulators don't take the detour via `define and can override the corresponding
// parameters directly.
`ifndef RV32M
  `define RV32M ibex_pkg::RV32MFast
`endif

`ifndef RV32B
  `define RV32B ibex_pkg::RV32BNone
`endif

`ifndef RegFile
  `define RegFile ibex_pkg::RegFileFF
`endif

/**
 * Ibex simple system
 *
 * This is a basic system consisting of an ibex, a 1 MB sram for instruction/data
 * and a small memory mapped control module for outputting ASCII text and
 * controlling/halting the simulation from the software running on the ibex.
 *
 * It is designed to be used with verilator but should work with other
 * simulators, a small amount of work may be required to support the
 * simulator_ctrl module.
 */

module ibex_simple_system (
  input IO_CLK,
  input IO_RST_N
);  

  // parameters for rv_core_ibex
   
  parameter bit RvCoreIbexPMPEnable = 1'b0;
  parameter int unsigned RvCoreIbexPMPGranularity = 1'b0;
  parameter int unsigned RvCoreIbexPMPNumRegions = 4;
  parameter int unsigned RvCoreIbexMHPMCounterNum = 29;
  parameter int unsigned RvCoreIbexMHPMCounterWidth = 32;
  parameter bit RvCoreIbexRV32E = 1'b0;
  parameter ibex_pkg::rv32m_e RvCoreIbexRV32M = `RV32M;
  parameter ibex_pkg::rv32b_e RvCoreIbexRV32B = `RV32B;
  parameter ibex_pkg::regfile_e RvCoreIbexRegFile = `RegFile;
  parameter bit RvCoreIbexBranchTargetALU = 1'b0;
  parameter bit RvCoreIbexWritebackStage = 1'b0;
  parameter bit RvCoreIbexICache = 1'b0;
  parameter bit RvCoreIbexICacheECC = 1'b0;
  parameter bit RvCoreIbexBranchPredictor = 1'b0;
  parameter bit RvCoreIbexDbgTriggerEn = 1;
  parameter bit RvCoreIbexSecureIbex = 1'b0;
  parameter int unsigned RvCoreIbexDmHaltAddr = 32'h00100000;
  parameter int unsigned RvCoreIbexDmExceptionAddr  =32'h00100000;
  parameter bit RvCoreIbexPipeLine = 1'b0;
  parameter SRAMInitFile = "/scratch/ciani/opentitan/hw/top_titangrey/examples/sw/simple_system/hello_test/hello_test.vmem";

  

  localparam int NrDevices = 3;
  localparam int NrHosts = 1;
    
  logic clk_sys = 1'b0, rst_sys_n;
 
 // interfaces definitions

  tlul_pkg::tl_h2d_t  main_tl_rv_core_ibex__corei_req;
  tlul_pkg::tl_d2h_t  main_tl_rv_core_ibex__corei_rsp;
  tlul_pkg::tl_h2d_t  main_tl_rv_core_ibex__cored_req;
  tlul_pkg::tl_d2h_t  main_tl_rv_core_ibex__cored_rsp;

  tlul_pkg::tl_h2d_t  core2ram;
  tlul_pkg::tl_d2h_t  ram2core;

  tlul_pkg::tl_h2d_t  core2simctrl;
  tlul_pkg::tl_d2h_t  simctrl2core;

  tlul_pkg::tl_h2d_t  core2romctrl;
  tlul_pkg::tl_d2h_t  romctrl2core;

  tlul_pkg::tl_h2d_t  core2kmac;
  tlul_pkg::tl_d2h_t  kmac2core;

  tlul_pkg::tl_h2d_t  core2keymgr;
  tlul_pkg::tl_d2h_t  keymgr2core;
   
  tlul_pkg::tl_h2d_t  core2instr;
  tlul_pkg::tl_d2h_t  instr2core;

  tlul_pkg::tl_h2d_t  core2otp;
  tlul_pkg::tl_d2h_t  otp2core;
   
  tlul_pkg::tl_h2d_t  core2hmac;
  tlul_pkg::tl_d2h_t  hmac2core;

  tlul_pkg::tl_h2d_t  core2lc;
  tlul_pkg::tl_d2h_t  lc2core;

  tlul_pkg::tl_h2d_t  core2sramctrl;
  tlul_pkg::tl_d2h_t  sramctrl2core;

  tlul_pkg::tl_h2d_t  core2flashctrl;
  tlul_pkg::tl_d2h_t  flashctrl2core;
   
  tlul_pkg::tl_h2d_t  core2uart;
  tlul_pkg::tl_d2h_t  uart2core;

  tlul_pkg::tl_h2d_t  core2clkmgr;
  tlul_pkg::tl_d2h_t  clkmgr2core;

  tlul_pkg::tl_h2d_t  core2sysrst;
  tlul_pkg::tl_d2h_t  sysrst2core;

  tlul_pkg::tl_h2d_t  core2rstmgr;
  tlul_pkg::tl_d2h_t  rstmgr2core;
   
  tlul_pkg::tl_h2d_t  core2pwrmgr;
  tlul_pkg::tl_d2h_t  pwrmgr2core;

  tlul_pkg::tl_h2d_t  core2alert;
  tlul_pkg::tl_d2h_t  alert2core;

  tlul_pkg::tl_h2d_t  core2dm;
  tlul_pkg::tl_d2h_t  dm2core;
   

  tlul_pkg::tl_h2d_t  core2plic;
  tlul_pkg::tl_d2h_t  plic2core;
   
  tlul_pkg::tl_h2d_t  core2edn;
  tlul_pkg::tl_d2h_t  edn2core;
      
  tlul_pkg::tl_h2d_t  core2otbn;
  tlul_pkg::tl_d2h_t  otbn2core;
         
  tlul_pkg::tl_h2d_t  core2aes;
  tlul_pkg::tl_d2h_t  aes2core;
          
  tlul_pkg::tl_h2d_t  core2csrng;
  tlul_pkg::tl_d2h_t  csrng2core;
         
  tlul_pkg::tl_h2d_t  core2entropy;
  tlul_pkg::tl_d2h_t  entropy2core;
           
  tlul_pkg::tl_h2d_t  core2gpio;
  tlul_pkg::tl_d2h_t  gpio2core;
             
  tlul_pkg::tl_h2d_t  core2sdevice;
  tlul_pkg::tl_d2h_t  sdevice2core;
   
              
  tlul_pkg::tl_h2d_t  core2shost;
  tlul_pkg::tl_d2h_t  shost2core;
   
   
  typedef enum logic[1:0] {
    Ram,
    SimCtrl,
    Timer
  } bus_device_e;

 
   

  // interrupts
  logic timer_irq;

  // host and device signals
  logic           host_req    [NrHosts]; 
  logic           host_gnt    [NrHosts];
  logic [31:0]    host_addr   [NrHosts]; 
  logic           host_we     [NrHosts];
  logic [ 3:0]    host_be     [NrHosts];
  logic [31:0]    host_wdata  [NrHosts];
  logic           host_rvalid [NrHosts];
  logic [31:0]    host_rdata  [NrHosts];
  logic           host_err    [NrHosts];

  // devices (slaves)
  logic           device_req    [NrDevices];
  logic [31:0]    device_addr   [NrDevices];
  logic           device_we     [NrDevices];
  logic [ 3:0]    device_be     [NrDevices];
  logic [31:0]    device_wdata  [NrDevices];
  logic           device_rvalid [NrDevices];
  logic [31:0]    device_rdata  [NrDevices];
  logic           device_err    [NrDevices];
   

  // Instruction fetch signals
  logic instr_req;
  logic instr_gnt;
  logic instr_rvalid;
  logic [31:0] instr_addr;
  logic [31:0] instr_rdata;
  logic instr_err;

  assign instr_gnt = instr_req;
  assign instr_err = '0;

 

  // Tie-off unused error signals
  assign device_err[Ram] = 1'b0;
  assign device_err[SimCtrl] = 1'b0;

  // Clock generation
   
 
  initial begin
     
   
    rst_sys_n = 1'b0;
    #8
    rst_sys_n = 1'b1;
  end

   
  always begin
    #1 clk_sys = 1'b0;
    #1 clk_sys = 1'b1;
  end
   
 

  // rv_core_ibex instantiation

    rv_core_ibex #(
//    .AlertAsyncOn(alert_handler_reg_pkg::AsyncOn[69:66]),
//    .RndCnstLfsrSeed(RndCnstRvCoreIbexLfsrSeed),
//    .RndCnstLfsrPerm(RndCnstRvCoreIbexLfsrPerm),
    .AlertAsyncOn(),
    .RndCnstLfsrSeed(),
    .RndCnstLfsrPerm(),  
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
    .BranchPredictor(RvCoreIbexBranchPredictor),
    .DbgTriggerEn(RvCoreIbexDbgTriggerEn),
    .SecureIbex(RvCoreIbexSecureIbex),
    .DmHaltAddr(RvCoreIbexDmHaltAddr),
    .DmExceptionAddr(RvCoreIbexDmExceptionAddr),
    .PipeLine(RvCoreIbexPipeLine)
  ) u_rv_core_ibex (
      // [66]: fatal_sw_err
      // [67]: recov_sw_err
      // [68]: fatal_hw_err
      // [69]: recov_hw_err
      .alert_tx_o  (),
      .alert_rx_i  (),

      // Inter-module signals
      .rst_cpu_n_o(),
      .ram_cfg_i(10'b0),
      .hart_id_i(32'b0),
      .boot_addr_i(32'h00100000),
      .irq_software_i(1'b0),
      .irq_timer_i(timer_irq),
      .irq_external_i(1'b0),
      .esc_tx_i(),
      .esc_rx_o(),
      .debug_req_i(1'b0),
      .crash_dump_o(),
      .lc_cpu_en_i(),
      .pwrmgr_cpu_en_i(),
      .pwrmgr_o(),
      .nmi_wdog_i(),
      .corei_tl_h_o(main_tl_rv_core_ibex__corei_req),
      .corei_tl_h_i(main_tl_rv_core_ibex__corei_rsp),
      .cored_tl_h_o(main_tl_rv_core_ibex__cored_req),
      .cored_tl_h_i(main_tl_rv_core_ibex__cored_rsp),
      .cfg_tl_d_i(),
      .cfg_tl_d_o(),
      .scanmode_i(4'b1010),
      .scan_rst_ni(rst_sys_n),

      // Clock and reset connections
      .clk_i (clk_sys),
      .clk_esc_i (clk_sys),
      .rst_ni (rst_sys_n),
      .rst_esc_ni (rst_sys_n)
      
  );

     ram_2p #(
      .Depth(1024*1024/4),
      .MemInitFile(SRAMInitFile)
    ) u_ram (
      .clk_i       (clk_sys),
      .rst_ni      (rst_sys_n),

      .a_req_i     (device_req[Ram]),
      .a_we_i      (device_we[Ram]),
      .a_be_i      (device_be[Ram]),
      .a_addr_i    (device_addr[Ram]),
      .a_wdata_i   (device_wdata[Ram]),
      .a_rvalid_o  (device_rvalid[Ram]),
      .a_rdata_o   (device_rdata[Ram]),

      .b_req_i     (instr_req),
      .b_we_i      (1'b0),
      .b_be_i      (4'b0),
      .b_addr_i    (instr_addr),
      .b_wdata_i   (32'b0),
      .b_rvalid_o  (instr_rvalid),
      .b_rdata_o   (instr_rdata)
    );
 
  simulator_ctrl #(
    .LogName("ibex_simple_system.log")
    ) u_simulator_ctrl (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),

      .req_i     (device_req[SimCtrl]),
      .we_i      (device_we[SimCtrl]),
      .be_i      (device_be[SimCtrl]),
      .addr_i    (device_addr[SimCtrl]),
      .wdata_i   (device_wdata[SimCtrl]),
      .rvalid_o  (device_rvalid[SimCtrl]),
      .rdata_o   (device_rdata[SimCtrl])
    );

  rom_ctrl u_rom (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .regs_tl_i (core2romctrl),
      .regs_tl_o (romctrl2core)
    );

  kmac u_kmac (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2kmac),
      .tl_o      (kmac2core)
   );

  keymgr u_keymgr (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2keymgr),
      .tl_o      (keymgr2core)   
   );

  otp_ctrl u_otp_ctrl (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .core_tl_i (core2otp),
      .core_tl_o (otp2core)
   );
   
  hmac u_hmac (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2hmac),
      .tl_o      (hmac2core)
   );

  lc_ctrl u_lc_ctrl (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2lc),
      .tl_o      (lc2core)
   );

  sram_ctrl u_sram_ctrl (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .regs_tl_i (core2sramctrl),
      .regs_tl_o (sramctrl2core)
   );
 flash_ctrl u_flash_ctrl (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .core_tl_i (core2flashctrl),
      .core_tl_o (flashctrl2core)
   );

 uart u_uart (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2uart),
      .tl_o      (uart2core)
   );

 clkmgr u_clkmgr (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2clkmgr),
      .tl_o      (clkmgr2core)
   );

 sysrst_ctrl u_sysrst_ctrl (
      .clk_i     (clk_sys),
      .clk_aon_i (clk_sys),                    
      .rst_ni    (rst_sys_n),
      .rst_aon_ni(rst_sys_n),
      .tl_i      (core2sysrst),
      .tl_o      (sysrst2core)
   );

 rstmgr u_rstmgr (
      .clk_i     (clk_sys),
      .clk_main_i(clk_sys),
      .clk_aon_i (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2rstmgr),
      .tl_o      (rstmgr2core)
   );
 
 pwrmgr u_pwrmgr (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2pwrmgr),
      .tl_o      (pwrmgr2core)
   );
   
 alert_handler u_alert (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2alert),
      .tl_o      (alert2core)
   );
      
 rv_dm u_dm (
      .clk_i       (clk_sys),
      .rst_ni      (rst_sys_n),
      .regs_tl_d_i (core2dm),
      .regs_tl_d_o (dm2core)
   );

 rv_plic u_rv_plic (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2plic),
      .tl_o      (plic2core)
   );

 edn u_edn (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2edn),
      .tl_o      (edn2core)
   );

 otbn u_otbn (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2otbn),
      .tl_o      (otbn2core)
   );

 aes u_aes (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2aes),
      .tl_o      (aes2core)
   );

 csrng u_csrng (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2csrng),
      .tl_o      (csrng2core)
   );

 entropy_src u_entropy(
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2entropy),
      .tl_o      (entropy2core)
   );
   
 gpio u_gpio (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2gpio),
      .tl_o      (gpio2core)
   );
   
 spi_device u_sdevice (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2sdevice),
      .tl_o      (sdevice2core)
   );

 spi_host u_shost (
      .clk_i     (clk_sys),
      .rst_ni    (rst_sys_n),
      .tl_i      (core2shost),
      .tl_o      (shost2core)
   );
                  
                  
  xbar_main u_xbar (
            
      .clk_main_i         (clk_sys),
      .rst_main_ni        (rst_sys_n),
               
      .tl_core_data_i     (main_tl_rv_core_ibex__cored_req),
      .tl_core_data_o     (main_tl_rv_core_ibex__cored_rsp),
               
      .tl_core_instr_i    (main_tl_rv_core_ibex__corei_req),
      .tl_core_instr_o    (main_tl_rv_core_ibex__corei_rsp),
              
      .tl_data_mem_o      (core2ram),
      .tl_data_mem_i      (ram2core),

      .tl_instr_mem_o     (core2instr),
      .tl_instr_mem_i     (instr2core),
                
      .tl_sim_ctrl_o      (core2simctrl),
      .tl_sim_ctrl_i      (simctrl2core),
            
      .tl_rom_ctrl_o      (core2romctrl),
      .tl_rom_ctrl_i      (romctrl2core),

      .tl_kmac_o          (core2kmac),
      .tl_kmac_i          (kmac2core),

      .tl_keymgr_o        (core2keymgr),
      .tl_keymgr_i        (keymgr2core),

      .tl_otp_ctrl_o      (core2otp),
      .tl_otp_ctrl_i      (otp2core),

      .tl_hmac_o          (core2hmac),
      .tl_hmac_i          (hmac2core),

      .tl_lc_ctrl_o       (core2lc),
      .tl_lc_ctrl_i       (lc2core),

      .tl_sram_ctrl_o     (core2sramctrl),
      .tl_sram_ctrl_i     (sramctrl2core),

      .tl_flash_ctrl_o    (core2flashctrl),
      .tl_flash_ctrl_i    (flashctrl2core),

      .tl_uart_o          (core2uart),
      .tl_uart_i          (uart2core),

      .tl_clkmgr_o        (core2clkmgr),
      .tl_clkmgr_i        (clkmgr2core),

      .tl_sysrst_ctrl_o   (core2sysrst),
      .tl_sysrst_ctrl_i   (sysrst2core),

      .tl_rstmgr_o        (core2rstmgr),
      .tl_rstmgr_i        (rstmgr2core),
                    
      .tl_pwrmgr_o        (core2pwrmgr),
      .tl_pwrmgr_i        (pwrmgr2core),

      .tl_alert_handler_o (core2alert),
      .tl_alert_handler_i (alert2core),

      .tl_rv_dm_o         (core2dm),
      .tl_rv_dm_i         (dm2core),
                    
      .tl_rv_plic_o       (core2plic),
      .tl_rv_plic_i       (plic2core),
                    
      .tl_edn_o           (core2edn),
      .tl_edn_i           (edn2core), 

      .tl_otbn_o          (core2otbn),
      .tl_otbn_i          (otbn2core),          
              
      .tl_aes_o           (core2aes),
      .tl_aes_i           (aes2core),

      .tl_csrng_o         (core2csrng),
      .tl_csrng_i         (csrng2core),

      .tl_entropy_src_o   (core2entropy),
      .tl_entropy_src_i   (entropy2core),
                    
      .tl_gpio_o          (core2gpio),
      .tl_gpio_i          (gpio2core),
                          
      .tl_spi_device_o    (core2sdevice),
      .tl_spi_device_i    (sdevice2core),

      .tl_spi_host_o      (core2shost),
      .tl_spi_host_i      (shost2core),

          
                   
      .scanmode_i         ()
       );
   

// instructions interface
   
    assign instr_req                       = core2instr.a_valid;
    assign instr_addr                      = core2instr.a_address;
    assign instr2core.d_valid              = instr_rvalid; 
    assign instr2core.d_data               = instr_rdata;
    assign instr2core.a_ready              = 1'b1;
    assign instr2core.d_error              = instr_err;
 // assign instr2core.d_opcode             = core2instr.a_opcode;  
    assign instr2core.d_param              = core2instr.a_param;
    assign instr2core.d_size               = core2instr.a_size;
    assign instr2core.d_source             = core2instr.a_source;
 // assign instr2core.d_sink               = core2instr.a_sink;
 // assign instr2core.d_user               = core2instr.a_user;
 // assign instr2core.d_user.data_intg     = 'b0;


  
// simcontrol ibexprot2tlul
   
    assign device_req[SimCtrl]             = core2simctrl.a_valid;
    assign device_addr[SimCtrl]            = core2simctrl.a_address;
    assign device_be[SimCtrl]              = core2simctrl.a_mask;
    assign device_we[SimCtrl]              =  ~(core2simctrl.a_opcode[2] || core2simctrl.a_opcode[0]);
    assign device_wdata[SimCtrl]           = core2simctrl.a_data;
    assign simctrl2core.d_valid            = device_rvalid[SimCtrl]; 
    assign simctrl2core.a_ready            = 1'b1; 
    assign simctrl2core.d_data             = device_rdata[SimCtrl];
    assign simctrl2core.d_opcode           = tlul_pkg::AccessAckData;
    assign simctrl2core.d_error            = device_err[SimCtrl];
    assign simctrl2core.d_param            = core2simctrl.a_param;
    assign simctrl2core.d_size             = core2simctrl.a_size;
    assign simctrl2core.d_source           = core2simctrl.a_source;
//  assign simctrl2core.d_user             = core2simctrl.a_user;
 


// ram ibexprot2tlul
   
    assign device_req[Ram]                 = core2ram.a_valid;
    assign device_addr[Ram]                = core2ram.a_address;
    assign device_be[Ram]                  = core2ram.a_mask;
    assign device_we[Ram]                  =  ~(core2ram.a_opcode[2] ||  core2ram.a_opcode[0]);
    assign device_wdata[Ram]               = core2ram.a_data;
    assign ram2core.d_valid                = device_rvalid[Ram]; 
    assign ram2core.a_ready                = 1'b1; 
    assign ram2core.d_data                 = device_rdata[Ram];
    assign ram2core.d_opcode               = tlul_pkg::AccessAckData;
    assign ram2core.d_error                = device_err[Ram];
    assign ram2core.d_param                = core2ram.a_param;
    assign ram2core.d_size                 = core2ram.a_size;
    assign ram2core.d_source               = core2ram.a_source;
 // assign ram2core.d_user                 = core2ram.a_user;

endmodule
