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
// Author: Yvan Tortorella, Fondazione Chips-IT
//

`include "pulp_soc_defines.sv"
`include "axi/typedef.svh"
`include "axi/assign.svh"

module security_island
   import axi_pkg::*;
   import pulp_cluster_package::*;
   import jtag_ot_pkg::*;
   import tlul2axi_pkg::*;
   import dm_ot::*;
   import lc_ctrl_pkg::*;
   import secure_subsystem_synth_astral_pkg::*;
   import top_earlgrey_pkg::*;
#(
   parameter int unsigned HartIdOffs = 0,
   // Shared AXI parameters
   parameter int unsigned AxiAddrWidth = SynthAxiAddrWidth,
   parameter int unsigned AxiDataWidth = SynthAxiDataWidth,
   parameter int unsigned AxiUserWidth = SynthAxiUserWidth,
   // External AXI master port ID Width
   parameter int unsigned AxiExtIdWidth = SynthAxiExtIdWidth, // 4
   // External AXI structs (must be coherent with the parameters above)
   parameter type axi_ext_aw_chan_t = synth_axi_ext_aw_chan_t,
   parameter type axi_ext_w_chan_t = synth_axi_ext_w_chan_t,
   parameter type axi_ext_b_chan_t = synth_axi_ext_b_chan_t,
   parameter type axi_ext_ar_chan_t = synth_axi_ext_ar_chan_t,
   parameter type axi_ext_r_chan_t = synth_axi_ext_r_chan_t,
   parameter type axi_ext_req_t = synth_axi_ext_req_t,
   parameter type axi_ext_resp_t = synth_axi_ext_resp_t,
   // Synchronizaton parameters
   parameter int unsigned LogDepth = SynthLogDepth,
   parameter int unsigned CdcSyncStages = SynthCdcSyncStages,
   parameter int unsigned SyncStages = 3,
   // Derived local parameters
   // Parameters for asynchronous CDC interface
   localparam int unsigned AsyncAxiExtAwWidth = (2**LogDepth)*axi_pkg::aw_width(AxiAddrWidth, AxiExtIdWidth, AxiUserWidth),
   localparam int unsigned AsyncAxiExtWWidth = (2**LogDepth)*axi_pkg::w_width(AxiDataWidth, AxiUserWidth),
   localparam int unsigned AsyncAxiExtBWidth = (2**LogDepth)*axi_pkg::b_width(AxiExtIdWidth, AxiUserWidth),
   localparam int unsigned AsyncAxiExtArWidth = (2**LogDepth)*axi_pkg::ar_width(AxiAddrWidth, AxiExtIdWidth, AxiUserWidth),
   localparam int unsigned AsyncAxiExtRWidth = (2**LogDepth)*axi_pkg::r_width(AxiDataWidth, AxiExtIdWidth, AxiUserWidth),
   // Internal crossbar AXI ID Widths
   // These are from the AXI XBAR perspective, so:
   // - "out" refers to XBAR master ports (slave devices -> external, PULP cluster slave)
   // - "in" refers to XBAR slave ports (master devices -> TLUL, iDMA, PULP cluster master)
   localparam int unsigned AxiOutIdWidth = SynthAxiOutIdWidth, // 8
   localparam int unsigned AxiInIdWidth = SynthAxiInIdWidth, // 6
   // PULP cluster slave port ID width
   localparam int unsigned AxiClsIdWidth = SynthClsAxiIdWidth,
   // Structs for AXI typedefs
   localparam type axi_addr_t = logic [AxiAddrWidth-1:0],
   localparam type axi_data_t = logic [AxiDataWidth-1:0],
   localparam type axi_strb_t = logic [AxiDataWidth/8-1:0],
   localparam type axi_user_t = logic [AxiUserWidth-1:0],
   localparam type axi_out_id_t = logic [AxiOutIdWidth-1:0],
   localparam type axi_in_id_t = logic [AxiInIdWidth-1:0]
)  (
   input logic                           clk_i,
   input logic                           clk_cluster_i,
   input logic                           clk_ref_i,
   input logic                           rst_ni,
   input logic                           pwr_on_rst_ni,
   input logic                           test_enable_i,
   input logic [1:0]                     bootmode_i,
   input logic                           fetch_en_i,
   // JTAG port
   input logic                           jtag_tck_i,
   input logic                           jtag_tms_i,
   input logic                           jtag_trst_n_i,
   input logic                           jtag_tdi_i,
   output logic                          jtag_tdo_o,
   output logic                          jtag_tdo_oe_o,
   // Asynch AXI tlul2axi port
   output logic [AsyncAxiExtAwWidth-1:0] async_axi_ext_aw_data_o,
   output logic [LogDepth:0]             async_axi_ext_aw_wptr_o,
   input logic [LogDepth:0]              async_axi_ext_aw_rptr_i,
   output logic [AsyncAxiExtWWidth-1:0]  async_axi_ext_w_data_o,
   output logic [LogDepth:0]             async_axi_ext_w_wptr_o,
   input logic [LogDepth:0]              async_axi_ext_w_rptr_i,
   input logic [AsyncAxiExtBWidth-1:0]   async_axi_ext_b_data_i,
   input logic [LogDepth:0]              async_axi_ext_b_wptr_i,
   output logic [LogDepth:0]             async_axi_ext_b_rptr_o,
   output logic [AsyncAxiExtArWidth-1:0] async_axi_ext_ar_data_o,
   output logic [LogDepth:0]             async_axi_ext_ar_wptr_o,
   input logic [LogDepth:0]              async_axi_ext_ar_rptr_i,
   input logic [AsyncAxiExtRWidth-1:0]   async_axi_ext_r_data_i,
   input logic [LogDepth:0]              async_axi_ext_r_wptr_i,
   output logic [LogDepth:0]             async_axi_ext_r_rptr_o,
   // Axi Isolate
   input  logic                          axi_isolate_i,
   output logic                          axi_isolated_o,
   // Interrupt signal
   input logic                           irq_ibex_i,
   input logic                           cfi_req_irq_i,
   input logic                           cfi_watermark_irq_i,
   // OT peripherals
   input logic                           ibex_uart_rx_i,
   output logic                          ibex_uart_tx_o,
   // GPIO
   output logic                          gpio_0_o,
   output logic                          gpio_0_oe_o,
   output logic                          gpio_1_o,
   output logic                          gpio_1_oe_o,
   input logic                           gpio_0_i,
   input logic                           gpio_1_i,
   // SPI Host
   output logic                          spi_host_SCK_o,
   output logic                          spi_host_SCK_en_o,
   output logic                          spi_host_CSB_o,
   output logic                          spi_host_CSB_en_o,
   output logic [3:0]                    spi_host_SD_o,
   input logic [3:0]                     spi_host_SD_i,
   output logic [3:0]                    spi_host_SD_en_o
);

//////////////////////////
// Defs and assignments //
//////////////////////////

   // Req/Resp structs for AXI XBAR master ports
   `AXI_TYPEDEF_ALL(axi_out, axi_addr_t, axi_out_id_t, axi_data_t, axi_strb_t, axi_user_t)
   // Req/Resp structs for AXI XBAR slave ports
   `AXI_TYPEDEF_ALL(axi_in, axi_addr_t, axi_in_id_t, axi_data_t, axi_strb_t, axi_user_t)

   localparam int unsigned NumMstPorts = 3;
   localparam int unsigned NumSlvPorts = 3;

   // Connections to the external AXI bus
   axi_ext_req_t axi_ext_serialized_req,
                 axi_ext_isolated_req;
   axi_ext_resp_t axi_ext_serialized_rsp,
                  axi_ext_isolated_rsp;

   // Connections to the AXI XBAR master ports
   axi_out_req_t [NumMstPorts-1:0] axi_mst_req;
   axi_out_resp_t [NumMstPorts-1:0] axi_mst_rsp;
   axi_out_req_t axi_ext_mst_req,
                 axi_cls_mst_req,
                 axi_l2_mst_req;
   axi_out_resp_t axi_ext_mst_rsp,
                  axi_cls_mst_rsp,
                  axi_l2_mst_rsp;

   // Connections to the AXI XBAR slave ports
   axi_in_req_t [NumSlvPorts-1:0] axi_slv_req;
   axi_in_resp_t [NumSlvPorts-1:0] axi_slv_rsp;
   axi_in_req_t axi_tlul_req,
                axi_idma_req,
                axi_cls_slv_req;
   axi_in_resp_t axi_tlul_rsp,
                 axi_idma_rsp,
                 axi_cls_slv_rsp;

   jtag_ot_pkg::jtag_req_t jtag_i;
   jtag_ot_pkg::jtag_rsp_t jtag_o;

   entropy_src_pkg::entropy_src_rng_req_t es_rng_req;
   entropy_src_pkg::entropy_src_rng_rsp_t es_rng_rsp;

   logic [15:0] dio_in_i;
   logic [15:0] dio_out_o;
   logic [15:0] dio_oe_o;

   logic [46:0] mio_in_i;
   logic [46:0] mio_out_o;
   logic [46:0] mio_oe_o;

   logic es_rng_fips;

   logic test_en_tieoff;
   logic s_rst_n, s_init_n;

   logic fetch_en_sync;
   logic irq_ibex_sync;

   wire [1:0] flash_testmode_tieoff;
   wire otp_ext_tieoff, flash_testvolt_tieoff;

   logic cluster_fetch_enable;
   logic cluster_en_sa_boot = 1'b0;

   logic unused = clk_ref_i & test_enable_i;

   logic s_cluster_eoc;

   assign flash_testmode_tieoff = '0;
   assign otp_ext_tieoff = '0;
   assign flash_testvolt_tieoff = '0;

   assign dio_in_i[1:0]   = '0;
   assign dio_in_i[15:6]  = '0;

   assign mio_in_i[0] = gpio_0_i ;
   assign mio_in_i[1] = gpio_1_i ;

   assign mio_in_i[25:2]  = '0;
   assign mio_in_i[46:27] = '0;

   assign spi_host_SCK_o  = dio_out_o[DioSpiHost0Sck];
   assign spi_host_CSB_o  = dio_out_o[DioSpiHost0Csb];

   assign spi_host_SCK_en_o = dio_oe_o[DioSpiHost0Sck];
   assign spi_host_CSB_en_o = dio_oe_o[DioSpiHost0Csb];

   assign spi_host_SD_o[0] = dio_out_o[DioSpiHost0Sd0];
   assign spi_host_SD_o[1] = dio_out_o[DioSpiHost0Sd1];
   assign spi_host_SD_o[2] = dio_out_o[DioSpiHost0Sd2];
   assign spi_host_SD_o[3] = dio_out_o[DioSpiHost0Sd3];

   assign spi_host_SD_en_o[0] = dio_oe_o[DioSpiHost0Sd0];
   assign spi_host_SD_en_o[1] = dio_oe_o[DioSpiHost0Sd1];
   assign spi_host_SD_en_o[2] = dio_oe_o[DioSpiHost0Sd2];
   assign spi_host_SD_en_o[3] = dio_oe_o[DioSpiHost0Sd3];

   assign dio_in_i[DioSpiHost0Sd0]  = spi_host_SD_i[0];
   assign dio_in_i[DioSpiHost0Sd1]  = spi_host_SD_i[1];
   assign dio_in_i[DioSpiHost0Sd2]  = spi_host_SD_i[2];
   assign dio_in_i[DioSpiHost0Sd3]  = spi_host_SD_i[3];

   assign mio_in_i[26]  = ibex_uart_rx_i;
   assign ibex_uart_tx_o = mio_out_o[26];

   assign gpio_0_o = mio_out_o[0];
   assign gpio_1_o = mio_out_o[1];

   assign gpio_0_oe_o = mio_oe_o[0];
   assign gpio_1_oe_o = mio_oe_o[1];

   //Unwrapping JTAG structures

   assign jtag_i.tck     = jtag_tck_i;
   assign jtag_i.tms     = jtag_tms_i;
   assign jtag_i.trst_n  = jtag_trst_n_i;
   assign jtag_i.tdi     = jtag_tdi_i;

   assign jtag_tdo_o     = jtag_o.tdo;
   assign jtag_tdo_oe_o  = jtag_o.tdo_oe;

   assign s_rst_n = rst_ni;

///////////
// Synch //
///////////

   sync #(
     .STAGES     ( SyncStages ),
     .ResetValue ( 1'b0       )
   ) i_fetch_en_sync (
     .clk_i,
     .rst_ni   ( pwr_on_rst_ni ),
     .serial_i ( fetch_en_i    ),
     .serial_o ( fetch_en_sync )
   );

   sync #(
     .STAGES     ( SyncStages ),
     .ResetValue ( 1'b0       )
   ) i_irq_sync (
     .clk_i,
     .rst_ni   ( pwr_on_rst_ni ),
     .serial_i ( irq_ibex_i    ),
     .serial_o ( irq_ibex_sync )
   );

   sync #(
     .STAGES     ( SyncStages ),
     .ResetValue ( 1'b1       )
   ) i_isolate_sync_tlul2axi (
     .clk_i,
     .rst_ni   ( pwr_on_rst_ni    ),
     .serial_i ( axi_isolate_i    ),
     .serial_o ( axi_isolate_sync )
   );

  // -----------------------------------------------------------------------------------
  // AXI interconnection
  // -----------------------------------------------------------------------------------

  ////////////////////////////////////////////////////////////////
  // Interface to external bus (CDC + Isolator + ID serializer) //
  ////////////////////////////////////////////////////////////////

   axi_cdc_src #(
      .LogDepth   ( LogDepth          ),
      .SyncStages ( CdcSyncStages     ),
      .aw_chan_t  ( axi_ext_aw_chan_t ),
      .w_chan_t   ( axi_ext_w_chan_t  ),
      .b_chan_t   ( axi_ext_b_chan_t  ),
      .ar_chan_t  ( axi_ext_ar_chan_t ),
      .r_chan_t   ( axi_ext_r_chan_t  ),
      .axi_req_t  ( axi_ext_req_t     ),
      .axi_resp_t ( axi_ext_resp_t    )
   ) i_cdc_out_tlul2axi (
      .src_clk_i                   ( clk_i                   ),
      .src_rst_ni                  ( pwr_on_rst_ni           ),
      .async_data_master_aw_data_o ( async_axi_ext_aw_data_o ),
      .async_data_master_aw_wptr_o ( async_axi_ext_aw_wptr_o ),
      .async_data_master_aw_rptr_i ( async_axi_ext_aw_rptr_i ),
      .async_data_master_w_data_o  ( async_axi_ext_w_data_o  ),
      .async_data_master_w_wptr_o  ( async_axi_ext_w_wptr_o  ),
      .async_data_master_w_rptr_i  ( async_axi_ext_w_rptr_i  ),
      .async_data_master_b_data_i  ( async_axi_ext_b_data_i  ),
      .async_data_master_b_wptr_i  ( async_axi_ext_b_wptr_i  ),
      .async_data_master_b_rptr_o  ( async_axi_ext_b_rptr_o  ),
      .async_data_master_ar_data_o ( async_axi_ext_ar_data_o ),
      .async_data_master_ar_wptr_o ( async_axi_ext_ar_wptr_o ),
      .async_data_master_ar_rptr_i ( async_axi_ext_ar_rptr_i ),
      .async_data_master_r_data_i  ( async_axi_ext_r_data_i  ),
      .async_data_master_r_wptr_i  ( async_axi_ext_r_wptr_i  ),
      .async_data_master_r_rptr_o  ( async_axi_ext_r_rptr_o  ),
      .src_req_i                   ( axi_ext_isolated_req    ),
      .src_resp_o                  ( axi_ext_isolated_rsp    )
   );

   axi_isolate            #(
     .NumPending           ( secure_subsystem_synth_astral_pkg::AxiMaxOutTrans ),
     .TerminateTransaction ( 1              ),
     .AtopSupport          ( 1              ),
     .AxiAddrWidth         ( AxiAddrWidth   ),
     .AxiDataWidth         ( AxiDataWidth   ),
     .AxiIdWidth           ( AxiExtIdWidth  ),
     .AxiUserWidth         ( AxiUserWidth   ),
     .axi_req_t            ( axi_ext_req_t  ),
     .axi_resp_t           ( axi_ext_resp_t )
   ) i_axi_out_isolate_tlul2axi (
     .clk_i                ( clk_i                  ),
     .rst_ni               ( rst_ni                 ),
     .slv_req_i            ( axi_ext_serialized_req ),
     .slv_resp_o           ( axi_ext_serialized_rsp ),
     .mst_req_o            ( axi_ext_isolated_req   ),
     .mst_resp_i           ( axi_ext_isolated_rsp   ),
     .isolate_i            ( axi_isolate_sync       ),
     .isolated_o           ( axi_isolated_o         )
   );

   axi_id_serialize #(
    .AxiSlvPortIdWidth      ( AxiOutIdWidth  ),
    .AxiMstPortMaxUniqIds   ( 4              ),
    .AxiMstPortMaxTxnsPerId ( 4              ),
    .AxiMstPortIdWidth      ( AxiExtIdWidth  ),
    .AxiAddrWidth           ( AxiAddrWidth   ),
    .AxiUserWidth           ( AxiUserWidth   ),
    .AxiDataWidth           ( AxiDataWidth   ),
    .slv_req_t              ( axi_out_req_t  ),
    .slv_resp_t             ( axi_out_resp_t ),
    .mst_req_t              ( axi_ext_req_t  ),
    .mst_resp_t             ( axi_ext_resp_t )
   ) ot_id_remap (
    .clk_i      ( clk_i                  ),
    .rst_ni     ( rst_ni                 ),
    .slv_req_i  ( axi_ext_mst_req        ),
    .slv_resp_o ( axi_ext_mst_rsp        ),
    .mst_req_o  ( axi_ext_serialized_req ),
    .mst_resp_i ( axi_ext_serialized_rsp )
   );

   rng #(
      .EntropyStreams ( 4 )
   ) u_rng (
      .clk_i          ( clk_i                 ),
      .rst_ni         ( s_rst_n               ),
      .clk_ast_rng_i  ( clk_i                 ),
      .rst_ast_rng_ni ( s_rst_n               ),
      .rng_en_i       ( es_rng_req.rng_enable ),
      .rng_fips_i     ( es_rng_fips           ),
      .scan_mode_i    ( '0                    ),
      .rng_b_o        ( es_rng_rsp.rng_b      ),
      .rng_val_o      ( es_rng_rsp.rng_valid  )
   );

  //////////////////
  // AXI Crossbar //
  //////////////////
  localparam int unsigned NumRules = 3;
  typedef struct packed {
    int unsigned idx;
    logic [AxiAddrWidth-1:0] start_addr;
    logic [AxiAddrWidth-1:0] end_addr;
  } xbar_rule_t;

  xbar_rule_t [NumRules-1:0] addr_map;

  logic [AxiAddrWidth-1:0] host_base_addr,
                           host_end_addr,
                           cls_base_addr,
                           cls_end_addr,
                           l2_base_addr,
                           l2_end_addr;

  assign host_base_addr = 32'h0001_0000;
  assign host_end_addr = 32'hB000_0000;
  assign cls_base_addr = 32'hB000_0000;
  assign cls_end_addr = 32'hC000_0000;
  assign l2_base_addr = 32'hD000_0000;
  assign l2_end_addr = 32'hDFFF_FFFF;

  assign addr_map = '{
    '{ // Host
      start_addr: host_base_addr,
      end_addr:   host_end_addr,
      idx:        0
    },
    '{ // Cluster
      start_addr: cls_base_addr,
      end_addr:   cls_end_addr,
      idx:        1
    },
    '{ // L2
      start_addr: l2_base_addr,
      end_addr:   l2_end_addr,
      idx:        2
    }
  };

  localparam axi_pkg::xbar_cfg_t XbarCfg = '{
    NoSlvPorts:                    NumSlvPorts,
    NoMstPorts:                    NumMstPorts,
    MaxMstTrans:                   NumMstPorts,
    MaxSlvTrans:                   NumSlvPorts,
    FallThrough:                          1'b0,
    LatencyMode:        axi_pkg::CUT_ALL_PORTS,
    PipelineStages:                      32'd0,
    AxiIdWidthSlvPorts:           AxiInIdWidth,
    AxiIdUsedSlvPorts:            AxiInIdWidth,
    UniqueIds:                            1'b0,
    AxiAddrWidth:                 AxiAddrWidth,
    AxiDataWidth:                 AxiDataWidth,
    NoAddrRules:                      NumRules
  };

  assign axi_ext_mst_req = axi_mst_req[0];
  assign axi_cls_mst_req = axi_mst_req[1];
  assign axi_l2_mst_req  = axi_mst_req[2];
  assign axi_mst_rsp     = { axi_l2_mst_rsp, axi_cls_mst_rsp, axi_ext_mst_rsp };

  assign axi_slv_req     = { axi_cls_slv_req, axi_idma_req, axi_tlul_req };
  assign axi_tlul_rsp    = axi_slv_rsp[0];
  assign axi_idma_rsp    = axi_slv_rsp[1];
  assign axi_cls_slv_rsp = axi_slv_rsp[2];

  axi_xbar #(
    .Cfg          ( XbarCfg           ),
    .slv_aw_chan_t( axi_in_aw_chan_t  ),
    .mst_aw_chan_t( axi_out_aw_chan_t ),
    // W channel does not depend on IDs,
    // so it is the same for master/slave ports
    .w_chan_t     ( axi_out_w_chan_t  ),
    .slv_b_chan_t ( axi_in_b_chan_t   ),
    .mst_b_chan_t ( axi_out_b_chan_t  ),
    .slv_ar_chan_t( axi_in_ar_chan_t  ),
    .mst_ar_chan_t( axi_out_ar_chan_t ),
    .slv_r_chan_t ( axi_in_r_chan_t   ),
    .mst_r_chan_t ( axi_out_r_chan_t  ),
    .slv_req_t    ( axi_in_req_t      ),
    .slv_resp_t   ( axi_in_resp_t     ),
    .mst_req_t    ( axi_out_req_t     ),
    .mst_resp_t   ( axi_out_resp_t    ),
    .rule_t       ( xbar_rule_t       )
  ) i_axi_xbar (
    .clk_i                  ( clk_i       ),
    .rst_ni                 ( rst_ni      ),
    .test_i                 ( '0          ),
    .slv_ports_req_i        ( axi_slv_req ),
    .slv_ports_resp_o       ( axi_slv_rsp ),
    .mst_ports_req_o        ( axi_mst_req ),
    .mst_ports_resp_i       ( axi_mst_rsp ),
    .addr_map_i             ( addr_map    ),
    .en_default_mst_port_i  ( '0          ),
    .default_mst_port_i     ( '0          )
  );

  /////////////////////
  // L2 memory slave //
  /////////////////////
  localparam int unsigned L2MemSize = 512*1024;
  localparam int unsigned MemDataWidth = 32;
  localparam int unsigned NumBanks = 2 * AxiDataWidth / MemDataWidth;
  localparam int unsigned L2BankSize = L2MemSize / NumBanks;

  logic [NumBanks-1:0]                         l2_mem_slave_req;
  logic [NumBanks-1:0]                         l2_mem_slave_gnt;
  logic [NumBanks-1:0]                         l2_mem_slave_we;
  logic [NumBanks-1:0][AxiDataWidth/8-1:0    ] l2_mem_slave_be;
  logic [NumBanks-1:0][$clog2(L2BankSize)-1:0] l2_mem_slave_add;
  logic [NumBanks-1:0][AxiDataWidth-1:0      ] l2_mem_slave_data;
  logic [NumBanks-1:0][AxiDataWidth-1:0      ] l2_mem_slave_r_data;

  axi_to_mem_banked #(
      .AxiIdWidth    ( AxiOutIdWidth     ),
      .AxiAddrWidth  ( AxiAddrWidth      ),
      .AxiDataWidth  ( AxiDataWidth      ),
      .axi_aw_chan_t ( axi_out_aw_chan_t ),
      .axi_w_chan_t  ( axi_out_w_chan_t  ),
      .axi_b_chan_t  ( axi_out_b_chan_t  ),
      .axi_ar_chan_t ( axi_out_ar_chan_t ),
      .axi_r_chan_t  ( axi_out_r_chan_t  ),
      .axi_req_t     ( axi_out_req_t     ),
      .axi_resp_t    ( axi_out_resp_t    ),
      .MemNumBanks   ( NumBanks          ),
      .MemAddrWidth  ( $clog2(L2BankSize)),
      .MemDataWidth  ( AxiDataWidth      )
  ) axi_to_mem_instance (
      .clk_i       ( clk_i               ),
      .rst_ni      ( rst_ni              ),
      .axi_req_i   ( axi_l2_mst_req      ),
      .axi_resp_o  ( axi_l2_mst_rsp      ),
      .mem_req_o   ( l2_mem_slave_req    ),
      .mem_gnt_i   ( l2_mem_slave_gnt    ),
      .mem_add_o   ( l2_mem_slave_add    ),
      .mem_we_o    ( l2_mem_slave_we     ),
      .mem_wdata_o ( l2_mem_slave_data   ),
      .mem_be_o    ( l2_mem_slave_be     ),
      .mem_rdata_i ( l2_mem_slave_r_data )
  );

  for(genvar i=0; i<NumBanks; i++) begin : l2_banks_gen

    // With regular TCDM banks, the grant is always asserted.
    assign l2_mem_slave_gnt[i] = 1'b1;

    tc_sram #(
      .NumWords   (L2BankSize  ), // Number of Words in data array
      .DataWidth  (AxiDataWidth), // Data signal width
      .NumPorts   (1           ), // Number of read and write ports
    `ifndef SYNTHESIS
      .ByteWidth  (8        ), // Width of a data byte
      .SimInit    ("ones"   ), // Simulation initialization
      .PrintSimCfg(0        ), // Print configuration
    `endif
      .Latency    (1        ) // Latency when the read data is available
    ) i_bank (
      .clk_i  (clk_i                 ), // Clock
      .rst_ni (rst_ni                ), // Asynchronous reset active low
      .req_i  (l2_mem_slave_req   [i]), // request
      .we_i   (l2_mem_slave_we    [i]), // write enable
      .addr_i (l2_mem_slave_add   [i]), // request address
      .wdata_i(l2_mem_slave_data  [i]), // write data
      .be_i   (l2_mem_slave_be    [i]), // write byte enable
      .rdata_o(l2_mem_slave_r_data[i])  // read data
    );

  end

  // -----------------------------------------------------------------------------
  // Cluster Domain
  // -----------------------------------------------------------------------------

  ///////////////////////////////////////
  // AXI interfaces (synch and asynch) //
  ///////////////////////////////////////

   // PULP cluster slave interfaces
   AXI_BUS #(
     .AXI_ADDR_WIDTH ( AxiAddrWidth  ),
     .AXI_DATA_WIDTH ( AxiDataWidth  ),
     .AXI_ID_WIDTH   ( AxiOutIdWidth ),
     .AXI_USER_WIDTH ( AxiUserWidth  )
   ) soc_to_cluster_axi_bus();

   AXI_BUS #(
     .AXI_ADDR_WIDTH ( AxiAddrWidth  ),
     .AXI_DATA_WIDTH ( AxiDataWidth  ),
     .AXI_ID_WIDTH   ( AxiClsIdWidth ),
     .AXI_USER_WIDTH ( AxiUserWidth  )
   ) serialized_soc_to_cluster_axi_bus();

   AXI_BUS_ASYNC_GRAY #(
     .AXI_ADDR_WIDTH ( AxiAddrWidth  ),
     .AXI_DATA_WIDTH ( AxiDataWidth  ),
     .AXI_ID_WIDTH   ( AxiClsIdWidth ),
     .AXI_USER_WIDTH ( AxiUserWidth  ),
     .LOG_DEPTH      ( LogDepth      )
   ) async_soc_to_cluster_axi_bus();

   // PULP cluster master interface
   AXI_BUS #(
     .AXI_ADDR_WIDTH ( AxiAddrWidth ),
     .AXI_DATA_WIDTH ( AxiDataWidth ),
     .AXI_ID_WIDTH   ( AxiInIdWidth ),
     .AXI_USER_WIDTH ( AxiUserWidth )
   ) cluster_to_soc_axi_bus();

   AXI_BUS_ASYNC_GRAY #(
     .AXI_ADDR_WIDTH ( AxiAddrWidth ),
     .AXI_DATA_WIDTH ( AxiDataWidth ),
     .AXI_ID_WIDTH   ( AxiInIdWidth ),
     .AXI_USER_WIDTH ( AxiUserWidth ),
     .LOG_DEPTH      ( LogDepth     )
   ) async_cluster_to_soc_axi_bus();

  // Assign PULP cluster structs to interfaces
  `AXI_ASSIGN_FROM_REQ(soc_to_cluster_axi_bus, axi_cls_mst_req)
  `AXI_ASSIGN_TO_RESP(axi_cls_mst_rsp, soc_to_cluster_axi_bus)
  `AXI_ASSIGN_TO_REQ(axi_cls_slv_req, cluster_to_soc_axi_bus)
  `AXI_ASSIGN_FROM_RESP(cluster_to_soc_axi_bus, axi_cls_slv_rsp)

///////////////////////
// Axi ID serializer //
///////////////////////

   axi_id_serialize_intf #(
     .AXI_SLV_PORT_ID_WIDTH (AxiOutIdWidth),
     .AXI_SLV_PORT_MAX_TXNS (4),
     .AXI_MST_PORT_ID_WIDTH (AxiClsIdWidth),
     .AXI_MST_PORT_MAX_UNIQ_IDS (4),
     .AXI_MST_PORT_MAX_TXNS_PER_ID (4),
     .AXI_ADDR_WIDTH (AxiAddrWidth),
     .AXI_DATA_WIDTH (AxiDataWidth),
     .AXI_USER_WIDTH (AxiUserWidth)
   ) u_cluster_slave_id_serializer (
     .clk_i (clk_i),
     .rst_ni (pwr_on_rst_ni),
     .slv (soc_to_cluster_axi_bus),
     .mst (serialized_soc_to_cluster_axi_bus)
   );

///////////////////////////
// PULP cluster AXI CDCs //
///////////////////////////

   axi_cdc_src_intf #(
     .AXI_ADDR_WIDTH ( AxiAddrWidth  ),
     .AXI_DATA_WIDTH ( AxiDataWidth  ),
     .AXI_ID_WIDTH   ( AxiClsIdWidth ),
     .AXI_USER_WIDTH ( AxiUserWidth  ),
     .LOG_DEPTH      ( LogDepth      ),
     .SYNC_STAGES    ( SyncStages    )
   ) soc_to_cluster_src_cdc_fifo_i (
       .src_clk_i  ( clk_i                             ),
       .src_rst_ni ( pwr_on_rst_ni                     ),
       .src        ( serialized_soc_to_cluster_axi_bus ),
       .dst        ( async_soc_to_cluster_axi_bus      )
   );

   axi_cdc_dst_intf #(
     .AXI_ADDR_WIDTH ( AxiAddrWidth ),
     .AXI_DATA_WIDTH ( AxiDataWidth ),
     .AXI_ID_WIDTH   ( AxiInIdWidth ),
     .AXI_USER_WIDTH ( AxiUserWidth ),
     .LOG_DEPTH      ( LogDepth     ),
     .SYNC_STAGES    ( SyncStages   )
   ) cluster_to_soc_dst_cdc_fifo_i (
       .dst_clk_i  ( clk_i                        ),
       .dst_rst_ni ( pwr_on_rst_ni                ),
       .src        ( async_cluster_to_soc_axi_bus ),
       .dst        ( cluster_to_soc_axi_bus       )
   );

/////////////////
// Pulp Cluster//
/////////////////

  localparam bit[31:0] ClustBase       = 'hB0000000;
  localparam bit[31:0] ClustPeriphOffs = 'h00200000;
  localparam bit[31:0] ClustExtOffs    = 'h00400000;
  localparam bit[ 5:0] ClustIdx        = 'h0;
  localparam bit[31:0] ClustBaseAddr   = ClustBase - (ClustIdx << 22);

  localparam pulp_cluster_cfg_t OTClusterCfg = '{
    CoreType: pulp_cluster_package::RI5CY,
    NumCores: 8,
    DmaNumPlugs: 4,
    DmaNumOutstandingBursts: 8,
    DmaBurstLength: 5,
    NumMstPeriphs: `NB_MPERIPHS,
    NumSlvPeriphs: `NB_SPERIPHS,
    ClusterAlias: 1,
    ClusterAliasBase: 'h0,
    NumSyncStages: CdcSyncStages,
    UseHci: 1,
    TcdmSize: 256*1024,
    TcdmNumBank: 16,
    HwpePresent: 0,
    HwpeCfg: '{NumHwpes: 3, HwpeList: {pulp_cluster_package::SOFTEX,
                                       pulp_cluster_package::NEUREKA,
                                       pulp_cluster_package::REDMULE}},
    HwpeNumPorts: 0,
    HMRPresent: 0,
    HMRDmrEnabled: 0,
    HMRTmrEnabled: 0,
    HMRDmrFIxed: 0,
    HMRTmrFIxed: 0,
    HMRInterleaveGrps: 1,
    HMREnableRapidRecovery: 1,
    HMRSeparateDataVoters: 1,
    HMRSeparateAxiBus: 0,
    HMRNumBusVoters: 1,
    EnableECC: 0,
    ECCInterco: 0,
    iCacheNumBanks: 2,
    iCacheNumLines: 1,
    iCacheNumWays: 4,
    iCacheSharedSize: 4*1024,
    iCachePrivateSize: 512,
    iCachePrivateDataWidth: 32,
    EnableReducedTag: 1,
    L2Size: 512*1024,
    DmBaseAddr: 'h60203000, // FIXME: CHECK!
    BootRomBaseAddr: 32'h1A000000,
    BootAddr: 32'h1C000080,
    EnablePrivateFpu: 1,
    EnablePrivateFpDivSqrt: 1,
    NumAxiIn: pulp_cluster_package::NumAxiSubordinatePorts,
    NumAxiOut: pulp_cluster_package::NumAxiManagerPorts,
    AxiIdInWidth: AxiClsIdWidth,
    AxiIdOutWidth:AxiInIdWidth,
    AxiAddrWidth: AxiAddrWidth,
    AxiDataInWidth: AxiDataWidth,
    AxiDataOutWidth: AxiDataWidth,
    AxiUserWidth: AxiUserWidth,
    AxiMaxInTrans: 64,
    AxiMaxOutTrans: 64,
    AxiCdcLogDepth: LogDepth,
    AxiCdcSyncStages: CdcSyncStages,
    SyncStages: CdcSyncStages,
    ClusterBaseAddr: ClustBaseAddr,
    ClusterPeriphOffs: ClustPeriphOffs,
    ClusterExternalOffs: ClustExtOffs,
    EnableRemapAddress: 0,
    SnitchICache: 0,
    default: '0
  };

   pulp_cluster
  #(
    .Cfg ( OTClusterCfg )
   ) cluster_i
   (
      .clk_i                           ( clk_cluster_i                        ),
      .rst_ni                          ( rst_ni                               ),
      .ref_clk_i                       ( clk_ref_i                            ),
      .pwr_on_rst_ni                   ( pwr_on_rst_ni                        ),
      .pmu_mem_pwdn_i                  ( 1'b0                                 ),

      .test_mode_i                     ( 1'b0                                 ),
      .en_sa_boot_i                    ( cluster_en_sa_boot                   ),

      .cluster_id_i                    ( 6'b000000                            ),
      .fetch_en_i                      ( cluster_fetch_enable                 ),
      .eoc_o                           ( s_cluster_eoc                        ),
      .busy_o                          (                                      ),

      .axi_isolate_i                   ( '0                                   ),
      .axi_isolated_o                  (                                      ),

      .dma_pe_evt_ack_i                ( 1'b1                                 ),
      .dma_pe_evt_valid_o              (                                      ),

      .dma_pe_irq_ack_i                ( 1'b1                                 ),
      .dma_pe_irq_valid_o              (                                      ),

      .dbg_irq_valid_i                 ( '0                                   ),
      .mbox_irq_i                      ( '0                                   ),

      .pf_evt_ack_i                    ( 1'b1                                 ),
      .pf_evt_valid_o                  (                                      ),

      .async_cluster_events_wptr_i     ( '0                                   ),
      .async_cluster_events_rptr_o     (                                      ),
      .async_cluster_events_data_i     ( '0                                   ),

      .async_data_master_aw_wptr_o     ( async_cluster_to_soc_axi_bus.aw_wptr ),
      .async_data_master_aw_rptr_i     ( async_cluster_to_soc_axi_bus.aw_rptr ),
      .async_data_master_aw_data_o     ( async_cluster_to_soc_axi_bus.aw_data ),
      .async_data_master_ar_wptr_o     ( async_cluster_to_soc_axi_bus.ar_wptr ),
      .async_data_master_ar_rptr_i     ( async_cluster_to_soc_axi_bus.ar_rptr ),
      .async_data_master_ar_data_o     ( async_cluster_to_soc_axi_bus.ar_data ),
      .async_data_master_w_data_o      ( async_cluster_to_soc_axi_bus.w_data  ),
      .async_data_master_w_wptr_o      ( async_cluster_to_soc_axi_bus.w_wptr  ),
      .async_data_master_w_rptr_i      ( async_cluster_to_soc_axi_bus.w_rptr  ),
      .async_data_master_r_wptr_i      ( async_cluster_to_soc_axi_bus.r_wptr  ),
      .async_data_master_r_rptr_o      ( async_cluster_to_soc_axi_bus.r_rptr  ),
      .async_data_master_r_data_i      ( async_cluster_to_soc_axi_bus.r_data  ),
      .async_data_master_b_wptr_i      ( async_cluster_to_soc_axi_bus.b_wptr  ),
      .async_data_master_b_rptr_o      ( async_cluster_to_soc_axi_bus.b_rptr  ),
      .async_data_master_b_data_i      ( async_cluster_to_soc_axi_bus.b_data  ),

      .async_data_slave_aw_wptr_i      ( async_soc_to_cluster_axi_bus.aw_wptr ),
      .async_data_slave_aw_rptr_o      ( async_soc_to_cluster_axi_bus.aw_rptr ),
      .async_data_slave_aw_data_i      ( async_soc_to_cluster_axi_bus.aw_data ),
      .async_data_slave_ar_wptr_i      ( async_soc_to_cluster_axi_bus.ar_wptr ),
      .async_data_slave_ar_rptr_o      ( async_soc_to_cluster_axi_bus.ar_rptr ),
      .async_data_slave_ar_data_i      ( async_soc_to_cluster_axi_bus.ar_data ),
      .async_data_slave_w_data_i       ( async_soc_to_cluster_axi_bus.w_data  ),
      .async_data_slave_w_wptr_i       ( async_soc_to_cluster_axi_bus.w_wptr  ),
      .async_data_slave_w_rptr_o       ( async_soc_to_cluster_axi_bus.w_rptr  ),
      .async_data_slave_r_wptr_o       ( async_soc_to_cluster_axi_bus.r_wptr  ),
      .async_data_slave_r_rptr_i       ( async_soc_to_cluster_axi_bus.r_rptr  ),
      .async_data_slave_r_data_o       ( async_soc_to_cluster_axi_bus.r_data  ),
      .async_data_slave_b_wptr_o       ( async_soc_to_cluster_axi_bus.b_wptr  ),
      .async_data_slave_b_rptr_i       ( async_soc_to_cluster_axi_bus.b_rptr  ),
      .async_data_slave_b_data_o       ( async_soc_to_cluster_axi_bus.b_data  )
   );

// -----------------------------------------------------------------------------------
// Root of Trust
// -----------------------------------------------------------------------------------

///////////////
// OpenTitan //
///////////////

   top_earlgrey #(
      .HartIdOffs       ( HartIdOffs       ),
      .axi_w_chan_t     ( axi_in_w_chan_t  ),
      .axi_b_chan_t     ( axi_in_b_chan_t  ),
      .axi_r_chan_t     ( axi_in_r_chan_t  ),
      .axi_aw_chan_t    ( axi_in_aw_chan_t ),
      .axi_ar_chan_t    ( axi_in_ar_chan_t ),
      .axi_req_t        ( axi_in_req_t     ),
      .axi_rsp_t        ( axi_in_resp_t    ),
      .AxiAddrWidth     ( AxiAddrWidth     ),
      .AxiDataWidth     ( AxiDataWidth     ),
      .AxiIdWidth       ( AxiInIdWidth     ),
      .AxiUserWidth     ( AxiUserWidth     ),
      .MemSizeMainSram  ( 32*1024          )
   ) u_RoT (
      .mio_attr_o                   (                       ),
      .dio_attr_o                   (                       ),
      .adc_req_o                    (                       ),
      .adc_rsp_i                    ( '0                    ),
      .ast_edn_rsp_o                (                       ),
      .ast_lc_dft_en_o              (                       ),
      .rom_cfg_i                    ( '0                    ),
      .clk_main_jitter_en_o         (                       ),
      .io_clk_byp_req_o             (                       ),
      .all_clk_byp_req_o            (                       ),
      .hi_speed_sel_o               (                       ),
      .flash_obs_o                  (                       ),
      .ast_tl_req_o                 (                       ),
      .ast_tl_rsp_i                 ( '0                    ),
      .dft_strap_test_o             (                       ),
      .usb_dp_pullup_en_o           (                       ),
      .usb_dn_pullup_en_o           (                       ),
      .pwrmgr_ast_req_o             (                       ),
      .otp_ctrl_otp_ast_pwr_seq_o   (                       ),
      .otp_ext_voltage_h_io         ( otp_ext_tieoff        ),
      .otp_obs_o                    (                       ),
      .sensor_ctrl_ast_alert_req_i  ( '0                    ),
      .sensor_ctrl_ast_alert_rsp_o  (                       ),
      .sensor_ctrl_ast_status_i     ( '0                    ),
      .ast2pinmux_i                 ( '0                    ),
      .flash_test_mode_a_io         ( flash_testmode_tieoff ),
      .ast_init_done_i              ( lc_ctrl_pkg::On       ),
      .sck_monitor_o                (                       ),
      .usbdev_usb_rx_d_i            ( '0                    ),
      .usbdev_usb_tx_d_o            (                       ),
      .usbdev_usb_tx_se0_o          (                       ),
      .usbdev_usb_tx_use_d_se0_o    (                       ),
      .usbdev_usb_rx_enable_o       (                       ),
      .usbdev_usb_ref_val_o         (                       ),
      .usbdev_usb_ref_pulse_o       (                       ),
      .clks_ast_o                   (                       ),
      .rsts_ast_o                   (                       ),
      .dio_in_i,
      .dio_out_o,
      .dio_oe_o,
      .mio_in_i,
      .mio_out_o,
      .mio_oe_o,
      .ast_edn_req_i                ( '0                    ),
      .obs_ctrl_i                   ( '0                    ),
      .ram_1p_cfg_i                 ( '0                    ),
      .ram_2p_cfg_i                 ( '0                    ),
      .io_clk_byp_ack_i             ( lc_ctrl_pkg::Off      ),
      .all_clk_byp_ack_i            ( lc_ctrl_pkg::Off      ),
      .div_step_down_req_i          ( lc_ctrl_pkg::Off      ),
      .calib_rdy_i                  ( lc_ctrl_pkg::Off      ),
      .flash_bist_enable_i          ( lc_ctrl_pkg::Off      ),
      .flash_power_down_h_i         ( '0                    ),
      .flash_power_ready_h_i        ( 1'b1                  ),
      .flash_test_voltage_h_io      ( flash_testvolt_tieoff ),
      .dft_hold_tap_sel_i           ( '0                    ),
      .pwrmgr_ast_rsp_i             ( 5'b11111              ),
      .otp_ctrl_otp_ast_pwr_seq_h_i ( '0                    ),
      .fpga_info_i                  ( '0                    ),
      .scan_rst_ni                  ( s_rst_n               ),
      .scan_en_i                    ( 1'b0                  ),
      .scanmode_i                   ( lc_ctrl_pkg::Off      ),
      .es_rng_fips_o                ( es_rng_fips           ),
      .es_rng_rsp_i                 ( es_rng_rsp            ),
      .es_rng_req_o                 ( es_rng_req            ),
      .por_n_i                      ( {s_rst_n, s_rst_n}    ),
      .clk_main_i                   ( clk_i                 ),
      .clk_io_i                     ( clk_i                 ),
      .clk_aon_i                    ( clk_i                 ),
      .clk_usb_i                    ( clk_i                 ),
      .tlul2axi_req_o               ( axi_tlul_req          ),
      .tlul2axi_rsp_i               ( axi_tlul_rsp          ),
      .idma_axi_req_o               ( axi_idma_req          ),
      .idma_axi_rsp_i               ( axi_idma_rsp          ),
      .irq_ibex_i                   ( irq_ibex_sync         ),
      .irq_cfi_req_i                ( cfi_req_irq_i         ),
      .cfi_watermark_irq_i          ( cfi_watermark_irq_i   ),
      .jtag_req_i                   ( jtag_i                ),
      .jtag_rsp_o                   ( jtag_o                ),
      .fetch_en_i                   ( fetch_en_sync         ),
      .bootmode_i                   ( bootmode_i            ),
      .cluster_fetch_en_o           ( cluster_fetch_enable  ),
      .cluster_eoc_i                ( s_cluster_eoc         )
   );

endmodule
