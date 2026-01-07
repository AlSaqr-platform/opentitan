// Copyright 2022 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Maicol Ciani <maicol.ciani@unibo.it>
//

`include "axi_assign.svh"
`include "axi_typedef.svh"

module testbench_asynch_astral ();

   import axi_pkg::*;
   import lc_ctrl_pkg::*;
   import jtag_ot_pkg::*;
   import jtag_ot_test::*;
   import dm_ot::*;
   import tlul2axi_pkg::*;
   import top_earlgrey_pkg::*;
   import secure_subsystem_synth_astral_pkg::*;
   import "DPI-C" function read_elf(input string filename);
   import "DPI-C" function byte get_section(output longint address, output longint len);
   import "DPI-C" context function byte read_section(input longint address, inout byte buffer[], input longint len);

// -----------------------------------------------------------------------------------
// Defines
// -----------------------------------------------------------------------------------


   localparam AxiWideBeWidth    = 4;
   localparam AxiWideByteOffset = $clog2(AxiWideBeWidth);

   localparam time TA   = 1ns;
   localparam time TT   = 2ns;

   localparam int unsigned AxiAddrWidth          = SynthAxiAddrWidth;
   localparam int unsigned AxiDataWidth          = SynthAxiDataWidth;
   localparam int unsigned AxiUserWidth          = SynthAxiUserWidth;
   localparam int unsigned AxiExtIdWidth         = SynthAxiExtIdWidth;

   localparam int  unsigned LogDepth             = SynthLogDepth;
   localparam int  unsigned CdcSyncStages        = SynthCdcSyncStages;

   localparam int unsigned AsyncAxiExtAwWidth = (2**LogDepth)*axi_pkg::aw_width(AxiAddrWidth, AxiExtIdWidth, AxiUserWidth);
   localparam int unsigned AsyncAxiExtWWidth = (2**LogDepth)*axi_pkg::w_width(AxiDataWidth, AxiUserWidth);
   localparam int unsigned AsyncAxiExtBWidth = (2**LogDepth)*axi_pkg::b_width(AxiExtIdWidth, AxiUserWidth);
   localparam int unsigned AsyncAxiExtArWidth = (2**LogDepth)*axi_pkg::ar_width(AxiAddrWidth, AxiExtIdWidth, AxiUserWidth);
   localparam int unsigned AsyncAxiExtRWidth = (2**LogDepth)*axi_pkg::r_width(AxiDataWidth, AxiExtIdWidth, AxiUserWidth);

   localparam type         axi_ext_aw_chan_t     = synth_axi_ext_aw_chan_t;
   localparam type         axi_ext_w_chan_t      = synth_axi_ext_w_chan_t;
   localparam type         axi_ext_b_chan_t      = synth_axi_ext_b_chan_t;
   localparam type         axi_ext_ar_chan_t     = synth_axi_ext_ar_chan_t;
   localparam type         axi_ext_r_chan_t      = synth_axi_ext_r_chan_t;
   localparam type         axi_ext_req_t         = synth_axi_ext_req_t;
   localparam type         axi_ext_resp_t        = synth_axi_ext_resp_t;

   localparam int  Depth = 512*1024;
   localparam int  Aw    = $clog2(Depth);

   localparam int unsigned DataWidth = 32;
   localparam int unsigned StrbWidth = DataWidth/8;

   localparam int unsigned RTC_CLOCK_PERIOD = 10ns;
   localparam int unsigned RTC_CLOCK_CL_PERIOD = 10ns;

   int                   secd_sections [bit [DataWidth-1:0]];
   logic [DataWidth-1:0] secd_memory[bit [DataWidth-1:0]];
   logic           [1:0] boot_mode;

   string       sram;
   string       ot_cluster;

   logic [1:0]  bootmode;

   logic        clk_cluster = 1'b0;

   logic clk_sys = 1'b0;
   logic rst_sys_n;
   logic es_rng_fips;
   logic SCK, CSNeg;

   logic [StrbWidth-1:0] SPIdata_i, SPIdata_o, SPIdata_oe_o;

   wire  I0, I1, I2, I3, WPNeg, RESETNeg;
   wire  PWROK_S, IOPWROK_S, BIAS_S, RETC_S;
   wire  ibex_uart_rx, ibex_uart_tx;

   logic [AsyncAxiExtAwWidth-1:0] async_axi_ext_aw_data_o;
   logic             [LogDepth:0] async_axi_ext_aw_wptr_o;
   logic             [LogDepth:0] async_axi_ext_aw_rptr_i;
   logic [ AsyncAxiExtWWidth-1:0] async_axi_ext_w_data_o;
   logic             [LogDepth:0] async_axi_ext_w_wptr_o;
   logic             [LogDepth:0] async_axi_ext_w_rptr_i;
   logic [ AsyncAxiExtBWidth-1:0] async_axi_ext_b_data_i;
   logic             [LogDepth:0] async_axi_ext_b_wptr_i;
   logic             [LogDepth:0] async_axi_ext_b_rptr_o;
   logic [AsyncAxiExtArWidth-1:0] async_axi_ext_ar_data_o;
   logic             [LogDepth:0] async_axi_ext_ar_wptr_o;
   logic             [LogDepth:0] async_axi_ext_ar_rptr_i;
   logic [ AsyncAxiExtRWidth-1:0] async_axi_ext_r_data_i;
   logic             [LogDepth:0] async_axi_ext_r_wptr_i;
   logic             [LogDepth:0] async_axi_ext_r_rptr_o;


   logic                      mem_mst_req;
   logic [AxiAddrWidth-1:0]   mem_mst_add;
   logic                      mem_mst_wen;
   logic [DataWidth-1:0]      mem_mst_wdata;
   logic                      mem_mst_gnt;
   logic                      mem_mst_r_valid;
   logic [DataWidth-1:0]      mem_mst_r_rdata;
   logic [StrbWidth-1:0]      mem_mst_be;
   logic                      mem_rvalid_d, rvalid_d, rvalid_q;

   typedef logic [DataWidth-1:0]  axi32_data_t;
   typedef logic [StrbWidth-1:0]  axi32_strb_t;

   `AXI_TYPEDEF_ALL(axi_out32, synth_axi_addr_t, synth_axi_ext_id_t, axi32_data_t, axi32_strb_t, synth_axi_user_t)

   axi_out32_req_t   tlul2axi32_req;
   axi_out32_resp_t  tlul2axi32_resp;

   uart_bus #(.BAUD_RATE(1250000), .PARITY_EN(0)) i_uart0_bus (.rx(ibex_uart_tx), .tx(ibex_uart_rx), .rx_en(1'b1)); //1470588 magic numbers

// -----------------------------------------------------------------------------------
// JTAG Driver
// -----------------------------------------------------------------------------------

   typedef jtag_ot_test::riscv_dbg #(
      .IrLength (5 ),
      .TA       (TA),
      .TT       (TT)
   ) riscv_dbg_t;

   JTAG_DV jtag_mst (clk_sys);

   jtag_ot_pkg::jtag_req_t jtag_i;
   jtag_ot_pkg::jtag_rsp_t jtag_o;

   axi_ext_req_t   tlul2axi_req;
   axi_ext_resp_t  tlul2axi_rsp;

   entropy_src_pkg::entropy_src_rng_req_t es_rng_req;
   entropy_src_pkg::entropy_src_rng_rsp_t es_rng_rsp;

   riscv_dbg_t::jtag_driver_t jtag_driver = new(jtag_mst);
   riscv_dbg_t riscv_dbg = new(jtag_driver);

   assign jtag_i.tck        = clk_sys;
   assign jtag_i.trst_n     = jtag_mst.trst_n;
   assign jtag_i.tms        = jtag_mst.tms;
   assign jtag_i.tdi        = jtag_mst.tdi;
   assign jtag_mst.tdo      = jtag_o.tdo;

   assign RESETNeg = 1'b1;
   assign WPNeg    = 1'b0;

   assign ibex_uart_rx = '0;

// -----------------------------------------------------------------------------------
// Flash VIP
// -----------------------------------------------------------------------------------

`ifdef VIPS
   pad_alsaqr i_I0 ( .OEN(~SPIdata_oe_o[0]), .I(SPIdata_o[0]), .O(), .PUEN(1'b1), .PAD(I0),
                     .DRV(2'b00), .SLW(1'b0), .SMT(1'b0), .PWROK(PWROK_S),
                     .IOPWROK(IOPWROK_S), .BIAS(BIAS_S), .RETC(RETC_S)   );
   pad_alsaqr i_I1 ( .OEN(~SPIdata_oe_o[1]), .I(), .O(SPIdata_i[1]), .PUEN(1'b1), .PAD(I1),
                     .DRV(2'b00), .SLW(1'b0), .SMT(1'b0), .PWROK(PWROK_S), .IOPWROK(IOPWROK_S),
                     .BIAS(BIAS_S), .RETC(RETC_S)   );
   s25fs256s #(
    .TimingModel   ( "S25FS256SAGMFI000_F_30pF" ),
    .mem_file_name ( "./sw/tests/opentitan/flash_hmac_smoketest/bazel-out/flash_hmac_smoketest_signed8.vmem" ),
    .UserPreload   ( 1 )
   ) i_spi_flash_csn0 (
    .SI       ( I0 ),
    .SO       ( I1 ),
    .SCK,
    .CSNeg,
    .WPNeg    (    ),
    .RESETNeg (    )
   );
`endif //  `ifdef VIPS

// -----------------------------------------------------------------------------------
// Simulation Memory
// -----------------------------------------------------------------------------------

  axi_cdc_dst #(
    .LogDepth   ( LogDepth          ),
    .SyncStages ( CdcSyncStages     ),
    .aw_chan_t  ( axi_ext_aw_chan_t ),
    .w_chan_t   ( axi_ext_w_chan_t  ),
    .b_chan_t   ( axi_ext_b_chan_t  ),
    .ar_chan_t  ( axi_ext_ar_chan_t ),
    .r_chan_t   ( axi_ext_r_chan_t  ),
    .axi_req_t  ( axi_ext_req_t     ),
    .axi_resp_t ( axi_ext_resp_t    )
  ) i_cdc_in_tlul2axi (
    .async_data_slave_aw_data_i( async_axi_ext_aw_data_o ),
    .async_data_slave_aw_wptr_i( async_axi_ext_aw_wptr_o ),
    .async_data_slave_aw_rptr_o( async_axi_ext_aw_rptr_i ),
    .async_data_slave_w_data_i ( async_axi_ext_w_data_o  ),
    .async_data_slave_w_wptr_i ( async_axi_ext_w_wptr_o  ),
    .async_data_slave_w_rptr_o ( async_axi_ext_w_rptr_i  ),
    .async_data_slave_b_data_o ( async_axi_ext_b_data_i  ),
    .async_data_slave_b_wptr_o ( async_axi_ext_b_wptr_i  ),
    .async_data_slave_b_rptr_i ( async_axi_ext_b_rptr_o  ),
    .async_data_slave_ar_data_i( async_axi_ext_ar_data_o ),
    .async_data_slave_ar_wptr_i( async_axi_ext_ar_wptr_o ),
    .async_data_slave_ar_rptr_o( async_axi_ext_ar_rptr_i ),
    .async_data_slave_r_data_o ( async_axi_ext_r_data_i  ),
    .async_data_slave_r_wptr_o ( async_axi_ext_r_wptr_i  ),
    .async_data_slave_r_rptr_i ( async_axi_ext_r_rptr_o  ),
    .dst_clk_i                 ( clk_sys      ),
    .dst_rst_ni                ( rst_sys_n    ),
    .dst_req_o                 ( tlul2axi_req ),
    .dst_resp_i                ( tlul2axi_rsp )
  );

  AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth  ),
    .AXI_DATA_WIDTH ( DataWidth     ),
    .AXI_ID_WIDTH   ( AxiExtIdWidth ),
    .AXI_USER_WIDTH ( AxiUserWidth  )
  ) axi2mem_bus();

  AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth  ),
    .AXI_DATA_WIDTH ( DataWidth     ),
    .AXI_ID_WIDTH   ( AxiExtIdWidth ),
    .AXI_USER_WIDTH ( AxiUserWidth  )
  ) axi2uart_bus();

  axi_out32_req_t   axi_uart_req, axi_mbox_req, axi_mem_req;
  axi_out32_resp_t  axi_uart_rsp, axi_mbox_rsp, axi_mem_rsp;

  `AXI_ASSIGN_FROM_REQ(axi2mem_bus, axi_mem_req)
  `AXI_ASSIGN_TO_RESP(axi_mem_rsp, axi2mem_bus)
  `AXI_ASSIGN_FROM_REQ(axi2uart_bus, axi_uart_req)
  `AXI_ASSIGN_TO_RESP(axi_uart_rsp, axi2uart_bus)

  axi_dw_converter #(
    .AxiMaxReads         ( 8                  ),
    .AxiSlvPortDataWidth ( AxiDataWidth       ),
    .AxiMstPortDataWidth ( DataWidth          ),
    .AxiAddrWidth        ( AxiAddrWidth       ),
    .AxiIdWidth          ( AxiExtIdWidth      ),
    .aw_chan_t           ( axi_ext_aw_chan_t  ),
    .mst_w_chan_t        ( axi_out32_w_chan_t ),
    .slv_w_chan_t        ( axi_ext_w_chan_t   ),
    .b_chan_t            ( axi_ext_b_chan_t   ),
    .ar_chan_t           ( axi_ext_ar_chan_t  ),
    .mst_r_chan_t        ( axi_out32_r_chan_t ),
    .slv_r_chan_t        ( axi_ext_r_chan_t   ),
    .axi_mst_req_t       ( axi_out32_req_t    ),
    .axi_mst_resp_t      ( axi_out32_resp_t   ),
    .axi_slv_req_t       ( axi_ext_req_t      ),
    .axi_slv_resp_t      ( axi_ext_resp_t     )
  )  i_axi_dw_converter_tlul2axi (
    .clk_i   ( clk_sys   ),
    .rst_ni  ( rst_sys_n ),
    // slave port
    .slv_req_i  ( tlul2axi_req ),
    .slv_resp_o ( tlul2axi_rsp ),
    // master port
    .mst_req_o  ( tlul2axi32_req  ),
    .mst_resp_i ( tlul2axi32_resp )
  );


axi_sim_mem_intf #(
  .AXI_ADDR_WIDTH (AxiAddrWidth),
  .AXI_DATA_WIDTH (DataWidth),
  .AXI_ID_WIDTH   (AxiExtIdWidth),
  .AXI_USER_WIDTH (AxiUserWidth),
  .UNINITIALIZED_DATA ("zeros"),
  .APPL_DELAY (2ns),
  .ACQ_DELAY  (8ns)
) sim_ram (
  .clk_i (clk_sys),
  .rst_ni (rst_sys_n),
  .axi_slv (axi2mem_bus),
  .mon_w_valid_o (),
  .mon_w_addr_o (),
  .mon_w_data_o (),
  .mon_w_id_o (),
  .mon_w_user_o (),
  .mon_w_beat_count_o (),
  .mon_w_last_o (),
  .mon_r_valid_o (),
  .mon_r_addr_o (),
  .mon_r_data_o (),
  .mon_r_id_o (),
  .mon_r_user_o (),
  .mon_r_beat_count_o (),
  .mon_r_last_o ()
);

  ////////////////////////////////////////////////////
  // ------------------------------------------------------
  // AXI connection
  // ------------------------------------------------------

  logic s_doorbell_irq;

  // xbar
  localparam int unsigned NumRules = 3;
  typedef struct packed {
    int unsigned idx;
    logic [AxiAddrWidth-1:0] start_addr;
    logic [AxiAddrWidth-1:0] end_addr;
  } xbar_rule_t;
  xbar_rule_t [NumRules-1:0] addr_map;
  logic [AxiAddrWidth-1:0] mem_base_addr;
  logic [AxiAddrWidth-1:0] mem_end_addr;
  logic [AxiAddrWidth-1:0] mbox_base_addr;
  logic [AxiAddrWidth-1:0] mbox_end_addr;
  logic [AxiAddrWidth-1:0] uart_base_addr;
  logic [AxiAddrWidth-1:0] uart_end_addr;
  assign mem_base_addr = 'h1C00_0000;
  assign mem_end_addr = 'hC000_0000;
  assign mbox_base_addr = 'h1040_4000;
  assign mbox_end_addr = 'h1040_4FFF;
  assign uart_base_addr = 'h1A22_2000;
  assign uart_end_addr = 'h1B22_2000;
  assign addr_map = '{
    '{ // SRAM
      start_addr: mem_base_addr,
      end_addr:   mem_end_addr,
      idx:        0
    },
    '{ // MBOX
      start_addr: mbox_base_addr,
      end_addr:   mbox_end_addr,
      idx:        1
    },
    '{ // UART
      start_addr: uart_base_addr,
      end_addr:   uart_end_addr,
      idx:        2
    }
  };
  localparam int unsigned NumSlvPorts = 1;
  localparam int unsigned NumMstPorts = 3;

  localparam axi_pkg::xbar_cfg_t TbXbarCfg = '{
    NoSlvPorts:                     NumSlvPorts,
    NoMstPorts:                     NumMstPorts,
    MaxMstTrans:                              1,
    MaxSlvTrans:                              1,
    FallThrough:                           1'b0,
    LatencyMode:         axi_pkg::CUT_ALL_PORTS,
    PipelineStages:                         'd0,
    AxiIdWidthSlvPorts:           AxiExtIdWidth,
    AxiIdUsedSlvPorts:            AxiExtIdWidth,
    UniqueIds:                             1'b0,
    AxiAddrWidth:                  AxiAddrWidth,
    AxiDataWidth:                     DataWidth,
    NoAddrRules:                       NumRules
  };

  axi_xbar #(
    .Cfg           ( TbXbarCfg           ),
    .w_chan_t      ( axi_out32_w_chan_t  ),
    .mst_aw_chan_t ( axi_out32_aw_chan_t ),
    .mst_b_chan_t  ( axi_out32_b_chan_t  ),
    .mst_ar_chan_t ( axi_out32_ar_chan_t ),
    .mst_r_chan_t  ( axi_out32_r_chan_t  ),
    .mst_req_t     ( axi_out32_req_t     ),
    .mst_resp_t    ( axi_out32_resp_t    ),
    .slv_aw_chan_t ( axi_out32_aw_chan_t ),
    .slv_ar_chan_t ( axi_out32_ar_chan_t ),
    .slv_b_chan_t  ( axi_out32_b_chan_t  ),
    .slv_r_chan_t  ( axi_out32_r_chan_t  ),
    .slv_req_t     ( axi_out32_req_t     ),
    .slv_resp_t    ( axi_out32_resp_t    ),
    .rule_t        ( xbar_rule_t         )
  ) i_tb_axi_xbar (
    .clk_i                  ( clk_sys                       ),
    .rst_ni                 ( rst_sys_n                     ),
    .test_i                 ( '0                            ),
    .slv_ports_req_i        ( tlul2axi32_req                ),
    .slv_ports_resp_o       ( tlul2axi32_resp               ),
    .mst_ports_req_o        ( { axi_uart_req, axi_mbox_req, axi_mem_req } ),
    .mst_ports_resp_i       ( { axi_uart_rsp, axi_mbox_rsp, axi_mem_rsp } ),
    .addr_map_i             ( addr_map                      ),
    .en_default_mst_port_i  ( '0                            ),
    .default_mst_port_i     ( '0                            )
  );

  axi_scmi_mailbox #(
    .AXI_MST_DATA_WIDTH ( DataWidth ),
    .AXI_ID_WIDTH       ( AxiExtIdWidth ),
    .AXI_ADDR_WIDTH     ( AxiAddrWidth ),
    .AXI_USER_WIDTH     ( AxiUserWidth ),
    .axi_req_t          ( axi_out32_req_t  ),
    .axi_resp_t         ( axi_out32_resp_t )
  ) i_scmi_tb_mailbox (
    .clk_i            ( clk_sys        ),
    .rst_ni           ( rst_sys_n      ),
    .axi_mbox_req     ( axi_mbox_req   ),
    .axi_mbox_rsp     ( axi_mbox_rsp   ),
    .doorbell_irq_o   ( s_doorbell_irq ),
    .completion_irq_o ()
  );

  mock_uart_axi #(
    .AxiIw    ( AxiExtIdWidth ),
    .AxiAw    ( AxiAddrWidth  ),
    .AxiDw    ( DataWidth     ),
    .AxiUw    ( AxiUserWidth  ),
    .BaseAddr ( 'h1A222000    )
  ) i_mock_uart_axi (
    .clk_i  ( clk_sys      ),
    .rst_ni ( rst_sys_n    ),
    .test_i ( '0           ),
    .uart   ( axi2uart_bus )
  );

// -----------------------------------------------------------------------------------
// DUT
// -----------------------------------------------------------------------------------
`ifdef TECH_SIM
   security_island dut (
`else
   security_island #(.HartIdOffs(0)) dut (
`endif
    .clk_i               ( clk_sys        ),
    .clk_cluster_i       ( clk_cluster    ),
    .clk_ref_i           ( clk_sys        ),
    .rst_ni              ( rst_sys_n      ),
    .pwr_on_rst_ni       ( rst_sys_n      ),
    .fetch_en_i          ( '0             ),
    .bootmode_i          ( bootmode       ),
    .test_enable_i       ( '0             ),
    .irq_ibex_i          ( s_doorbell_irq ),
    .cfi_req_irq_i       ( '0             ),
    .cfi_watermark_irq_i ( '0             ),

    // JTAG port
    .jtag_tck_i       ( jtag_i.tck    ),
    .jtag_tms_i       ( jtag_i.tms    ),
    .jtag_trst_n_i    ( jtag_i.trst_n ),
    .jtag_tdi_i       ( jtag_i.tdi    ),
    .jtag_tdo_o       ( jtag_o.tdo    ),
    .jtag_tdo_oe_o    (               ),
    // Axi Isolate
    .axi_isolate_i ( '0 ),
    .axi_isolated_o ( ),
    // Asynch axi port
    .async_axi_ext_aw_data_o,
    .async_axi_ext_aw_wptr_o,
    .async_axi_ext_aw_rptr_i,
    .async_axi_ext_w_data_o,
    .async_axi_ext_w_wptr_o,
    .async_axi_ext_w_rptr_i,
    .async_axi_ext_b_data_i,
    .async_axi_ext_b_wptr_i,
    .async_axi_ext_b_rptr_o,
    .async_axi_ext_ar_data_o,
    .async_axi_ext_ar_wptr_o,
    .async_axi_ext_ar_rptr_i,
    .async_axi_ext_r_data_i,
    .async_axi_ext_r_wptr_i,
    .async_axi_ext_r_rptr_o,
    // Uart
    .ibex_uart_rx_i   ( ibex_uart_rx  ),
    .ibex_uart_tx_o   ( ibex_uart_tx  ),
    // SPI host
`ifdef VIPS
    .spi_host_SCK_o   ( SCK           ),
    .spi_host_SCK_en_o(               ),
    .spi_host_CSB_o   ( CSNeg         ),
    .spi_host_CSB_en_o(               ),
    .spi_host_SD_o    ( SPIdata_o     ),
    .spi_host_SD_i    ( SPIdata_i     ),
    .spi_host_SD_en_o ( SPIdata_oe_o  ),
`else
    .spi_host_SCK_o   (               ),
    .spi_host_SCK_en_o(               ),
    .spi_host_CSB_o   (               ),
    .spi_host_CSB_en_o(               ),
    .spi_host_SD_o    (               ),
    .spi_host_SD_i    ( '0            ),
    .spi_host_SD_en_o (               ),
`endif
    .gpio_0_i         ( '0            ),
    .gpio_1_i         ( '0            ),
    .gpio_0_o         (               ),
    .gpio_1_o         (               ),
    .gpio_0_oe_o      (               ),
    .gpio_1_oe_o      (               )
   );


// -----------------------------------------------------------------------------------
// Tasks
// -----------------------------------------------------------------------------------


  initial begin  : main_clock_rst_process
    clk_sys   = 1'b0;
    rst_sys_n = 1'b0;
    jtag_mst.trst_n = 1'b0;

    repeat (2)
     #(RTC_CLOCK_PERIOD/2) clk_sys = 1'b0;
     rst_sys_n = 1'b1;

    forever
      #(RTC_CLOCK_PERIOD/2) clk_sys = ~clk_sys;
  end

  initial begin : cluster_clock
     clk_cluster = 1'b0;
     repeat(2)
     #(RTC_CLOCK_CL_PERIOD/2) clk_cluster = 1'b0;
     forever
     #(RTC_CLOCK_CL_PERIOD/2) clk_cluster = ~clk_cluster;
  end

  initial  begin : bootmodes

    if(!$value$plusargs("BOOTMODE=%d", boot_mode)) begin
       boot_mode=0;
       $display("BOOTMODE: %d", boot_mode);
    end
    if(!$value$plusargs("SRAM=%s", sram)) begin
       sram="";
       $display("Loading to SRAM: %s", sram);
    end
    if(!$value$plusargs("OT_CLUSTER=%s", ot_cluster)) begin
       ot_cluster="";
       $display("Loading cluster binary: %s", ot_cluster);
    end

    case(boot_mode)
        0:begin
          bootmode = 2'b00;
          riscv_dbg.reset_master();
          if (sram != "") begin
               repeat(10000)
                 @(posedge clk_sys);
               debug_secd_module_init();
               load_secd_binary(sram);
                if(ot_cluster != "none") begin
                   load_secd_binary(ot_cluster);
                end
               jtag_secd_data_preload();
               jtag_secd_wakeup('h e0000080); //preload the flashif
          `ifdef JTAG_SEC_BOOT
               repeat(250000)
                 @(posedge clk_sys);
               jtag_secd_wakeup('h d0008080); //secure boot
          `endif
               jtag_secd_wait_eoc();
          end
        end
        1:begin
          bootmode = 2'b01;
          riscv_dbg.reset_master();
          jtag_secd_wait_eoc();
        end
        default:begin
          $fatal("Unsupported bootmode");
        end
    endcase // case (boot_mode)
  end // block: bootmodes

  task debug_secd_module_init;
     logic [DataWidth-1:0]  idcode;
     automatic dm_ot::sbcs_t sbcs = '{
       sbautoincrement: 1'b1,
       sbreadondata   : 1'b1,
       sbaccess       : 3'h2,
       default        : 1'b0
     };
     //dm_ot::dtm_op_status_e op;
     automatic int dmi_wait_cycles = 10;
     $display("[JTAG SECD] JTAG Preloading Starting");
     riscv_dbg.wait_idle(300);
     riscv_dbg.get_idcode(idcode);
     // Check Idcode
     $display("[JTAG SECD] IDCode = %h", idcode);
     // Activate Debug Module
     riscv_dbg.write_dmi(dm_ot::DMControl, 'h0000_0001);
     do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
     while (sbcs.sbbusy);

  endtask

  task jtag_secd_data_preload;
     logic [DataWidth-1:0] rdata;
     automatic dm_ot::sbcs_t sbcs = '{
       sbautoincrement: 1'b1,
       sbreadondata   : 1'b1,
       sbaccess       : 3'h2,
       default        : 1'b0
     };
     automatic int dmi_wait_cycles = 10;
     debug_secd_module_init();
     riscv_dbg.write_dmi(dm_ot::SBCS, sbcs);
     do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
     while (sbcs.sbbusy);
     // Start writing to SRAM
     foreach (secd_sections[addr]) begin
       $display("[JTAG SECD] Writing %h with %0d words", addr << 2, secd_sections[addr]); // word = 8 bytes here
       riscv_dbg.write_dmi(dm_ot::SBAddress0, (addr << 2));
       do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
       while (sbcs.sbbusy);
       for (int i = 0; i < secd_sections[addr]; i++) begin
         if (i%100 == 0)
           $display("[JTAG SECD] loading: %0d/100%%", i*100/secd_sections[addr]);
         riscv_dbg.write_dmi(dm_ot::SBData0, secd_memory[addr + i]);
         // Wait until SBA is free to write next 32 bits
         do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
         while (sbcs.sbbusy);
       end
       $display("[JTAG SECD] loading: 100/100%%");
     end
    $display("[JTAG SECD] Preloading finished");
    // Preloading finished. Can now start executing
    sbcs.sbreadonaddr = 0;
    sbcs.sbreadondata = 0;
    riscv_dbg.write_dmi(dm_ot::SBCS, sbcs);

  endtask

  task jtag_secd_wakeup;
    input logic [DataWidth-1:0] start_addr;
    logic [DataWidth-1:0] dm_status;

    automatic dm_ot::sbcs_t sbcs = '{
      sbautoincrement: 1'b1,
      sbreadondata   : 1'b1,
      sbaccess       : 3'h2,
      default        : 1'b0
    };
    //dm_ot::dtm_op_status_e op;
    automatic int dmi_wait_cycles = 10;
    $display("[JTAG SECD] Waking up Secd");
    // Initialize the dm module again, otherwise it will not work
    debug_secd_module_init();
    do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
    while (sbcs.sbbusy);
    // Write PC to Data0 and Data1
    riscv_dbg.write_dmi(dm_ot::Data0, start_addr);
    do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
    while (sbcs.sbbusy);
    // Halt Req
    riscv_dbg.write_dmi(dm_ot::DMControl, 'h8000_0001);
    do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
    while (sbcs.sbbusy);
    // Wait for CVA6 to be halted
    do riscv_dbg.read_dmi(dm_ot::DMStatus, dm_status, dmi_wait_cycles);
    while (!dm_status[8]);
    // Ensure haltreq, resumereq and ackhavereset all equal to 0
    riscv_dbg.write_dmi(dm_ot::DMControl, 'h0000_0001);
    do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
    while (sbcs.sbbusy);
    // Register Access Abstract Command
    riscv_dbg.write_dmi(dm_ot::Command, {8'h0,1'b0,3'h2,1'b0,1'b0,1'b1,1'b1,4'h0,dm_ot::CSR_DPC});
    do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
    while (sbcs.sbbusy);
    // Resume req. Exiting from debug mode Secd CVA6 will jump at the DPC address.
    // Ensure haltreq, resumereq and ackhavereset all equal to 0
    riscv_dbg.write_dmi(dm_ot::DMControl, 'h4000_0001);
    do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
    while (sbcs.sbbusy);
    riscv_dbg.write_dmi(dm_ot::DMControl, 'h0000_0001);
    do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);

    while (sbcs.sbbusy);
    $display("[JTAG SECD] Wait for Completion");
  endtask

  task load_secd_binary;
    input string binary;                   // File name
    logic [DataWidth-1:0] section_addr, section_len;
    byte         buffer[];

    // Read ELF
    void'(read_elf(binary));
    $display("[JTAG SECD] Reading %s", binary);

    while (get_section(section_addr, section_len)) begin
      // Read Sections
      automatic int num_words = (section_len + AxiWideBeWidth - 1)/AxiWideBeWidth;
      $display("[JTAG SECD] Reading section %x with %0d words", section_addr, num_words);

      secd_sections[section_addr >> AxiWideByteOffset] = num_words;
      buffer = new[num_words * AxiWideBeWidth];
      void'(read_section(section_addr, buffer, section_len));
      for (int i = 0; i < num_words; i++) begin
        automatic logic [AxiWideBeWidth-1:0][7:0] word = '0;
        for (int j = 0; j < AxiWideBeWidth; j++) begin
          word[j] = buffer[i * AxiWideBeWidth + j];
        end
        secd_memory[section_addr/AxiWideBeWidth + i] = word;
      end
    end

  endtask // load_secd_binary

  task jtag_secd_wait_eoc;
    automatic dm_ot::sbcs_t sbcs = '{
      sbautoincrement: 1'b1,
      sbreadondata   : 1'b1,
      default        : 1'b0
    };
    logic [DataWidth-1:0] retval;
    logic [DataWidth-1:0] to_host_addr;
    to_host_addr = 'h c11c0018;

    // Initialize the dm module again, otherwise it will not work
    debug_secd_module_init();
    sbcs.sbreadonaddr = 1;
    sbcs.sbautoincrement = 0;
    riscv_dbg.write_dmi(dm_ot::SBCS, sbcs);
    do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs);
    while (sbcs.sbbusy);

    riscv_dbg.write_dmi(dm_ot::SBAddress0, to_host_addr); // tohost address
    riscv_dbg.wait_idle(10);
    do begin
	     do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs);
	     while (sbcs.sbbusy);
       riscv_dbg.write_dmi(dm_ot::SBAddress0, to_host_addr); // tohost address
	     do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs);
	     while (sbcs.sbbusy);
       riscv_dbg.read_dmi(dm_ot::SBData0, retval);
       # 400ns;
    end while (~retval[0]);

    if (retval != 'h00000001) $error("[JTAG] FAILED: return code %0d", retval);
    else $display("[JTAG] SUCCESS");

    $finish;

  endtask

endmodule
