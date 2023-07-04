// Copyright 2022 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "axi_assign.svh"
`include "axi_typedef.svh"

module testbench_asynch ();

   import lc_ctrl_pkg::*;
   import jtag_ot_pkg::*;
   import jtag_ot_test::*;
   import dm_ot::*;
   import tlul2axi_pkg::*;
   import top_earlgrey_pkg::*;
   import secure_subsystem_synth_pkg::*;
   import "DPI-C" function read_elf(input string filename);
   import "DPI-C" function byte get_section(output longint address, output longint len); 
   import "DPI-C" context function byte read_section(input longint address, inout byte buffer[]);
   
 ////////////////////////////  Defines ////////////////////////////
 
   localparam AxiWideBeWidth    = 4;
   localparam AxiWideByteOffset = $clog2(AxiWideBeWidth);

   localparam time TA   = 1ns;
   localparam time TT   = 2ns;
   
   localparam int unsigned AxiAddrWidth          = SynthAxiAddrWidth;
   localparam int unsigned AxiDataWidth          = SynthAxiDataWidth;
   localparam int unsigned AxiUserWidth          = SynthAxiUserWidth;
   localparam int unsigned AxiOutIdWidth         = SynthAxiOutIdWidth;

   localparam int unsigned AxiOtAddrWidth        = SynthOtAxiAddrWidth;
   localparam int unsigned AxiOtDataWidth        = SynthOtAxiDataWidth;
   localparam int unsigned AxiOtUserWidth        = SynthOtAxiUserWidth;
   localparam int unsigned AxiOtOutIdWidth       = SynthOtAxiOutIdWidth;
 
   localparam int unsigned AsyncAxiOutAwWidth    = SynthAsyncAxiOutAwWidth;
   localparam int unsigned AsyncAxiOutWWidth     = SynthAsyncAxiOutWWidth;
   localparam int unsigned AsyncAxiOutBWidth     = SynthAsyncAxiOutBWidth;
   localparam int unsigned AsyncAxiOutArWidth    = SynthAsyncAxiOutArWidth;
   localparam int unsigned AsyncAxiOutRWidth     = SynthAsyncAxiOutRWidth;

   localparam type         axi_out_aw_chan_t     = synth_axi_out_aw_chan_t;
   localparam type         axi_out_w_chan_t      = synth_axi_out_w_chan_t;
   localparam type         axi_out_b_chan_t      = synth_axi_out_b_chan_t;
   localparam type         axi_out_ar_chan_t     = synth_axi_out_ar_chan_t;
   localparam type         axi_out_r_chan_t      = synth_axi_out_r_chan_t;
   localparam type         axi_out_req_t         = synth_axi_out_req_t;
   localparam type         axi_out_resp_t        = synth_axi_out_resp_t;

   localparam type         axi_ot_out_aw_chan_t  = synth_ot_axi_out_aw_chan_t;
   localparam type         axi_ot_out_w_chan_t   = synth_ot_axi_out_w_chan_t;
   localparam type         axi_ot_out_b_chan_t   = synth_ot_axi_out_b_chan_t;
   localparam type         axi_ot_out_ar_chan_t  = synth_ot_axi_out_ar_chan_t;
   localparam type         axi_ot_out_r_chan_t   = synth_ot_axi_out_r_chan_t;
   localparam type         axi_ot_out_req_t      = synth_ot_axi_out_req_t;
   localparam type         axi_ot_out_resp_t     = synth_ot_axi_out_resp_t;
   
   localparam int  unsigned LogDepth             = SynthLogDepth;
   
   localparam bit  RAND_RESP = 0; 
   localparam int  AX_MIN_WAIT_CYCLES = 0;   
   localparam int  AX_MAX_WAIT_CYCLES = 1;   
   localparam int  R_MIN_WAIT_CYCLES = 0;   
   localparam int  R_MAX_WAIT_CYCLES = 1;   
   localparam int  RESP_MIN_WAIT_CYCLES = 0;
   localparam int  RESP_MAX_WAIT_CYCLES = 1;
   localparam int  NUM_BEATS = 100;
   
   localparam int unsigned RTC_CLOCK_PERIOD = 10ns;
   localparam int unsigned AON_PERIOD = 5us;
   localparam int unsigned IO_PERIOD = 10.41ns;
   localparam int unsigned USB_PERIOD = 20.82ns;
   
   int          sections [bit [31:0]];
   logic [31:0] memory[bit [31:0]];
   string       SRAM;
   
   logic clk_sys = 1'b0;
   logic aon_clk = 1'b0;
   logic io_clk = 1'b0;
   logic usb_clk = 1'b0;
   logic rst_sys_n;
   logic dbg_mode;
   logic es_rng_fips;
   logic SCK, CSNeg;
   logic [15:0] spi_i, spi_o, spi_oe_o;
   
   wire  I0, I1, I2, I3, WPNeg, RESETNeg;
   wire  PWROK_S, IOPWROK_S, BIAS_S, RETC_S;
   wire  ibex_uart_rx, ibex_uart_tx;


   logic [AsyncAxiOutAwWidth-1:0] async_axi_out_aw_data_o;
   logic             [LogDepth:0] async_axi_out_aw_wptr_o;
   logic             [LogDepth:0] async_axi_out_aw_rptr_i;
   logic [ AsyncAxiOutWWidth-1:0] async_axi_out_w_data_o;
   logic             [LogDepth:0] async_axi_out_w_wptr_o;
   logic             [LogDepth:0] async_axi_out_w_rptr_i;
   logic [ AsyncAxiOutBWidth-1:0] async_axi_out_b_data_i;
   logic             [LogDepth:0] async_axi_out_b_wptr_i;
   logic             [LogDepth:0] async_axi_out_b_rptr_o;
   logic [AsyncAxiOutArWidth-1:0] async_axi_out_ar_data_o;
   logic             [LogDepth:0] async_axi_out_ar_wptr_o;
   logic             [LogDepth:0] async_axi_out_ar_rptr_i;
   logic [ AsyncAxiOutRWidth-1:0] async_axi_out_r_data_i;
   logic             [LogDepth:0] async_axi_out_r_wptr_i;
   logic             [LogDepth:0] async_axi_out_r_rptr_o;
  
   uart_bus #(.BAUD_RATE(1470588), .PARITY_EN(0)) i_uart0_bus (.rx(ibex_uart_tx), .tx(ibex_uart_rx), .rx_en(1'b1));
   
   typedef axi_test::axi_rand_slave #(  
     .AW( AxiAddrWidth  ),
     .DW( AxiDataWidth  ),
     .IW( AxiOutIdWidth ),
     .UW( AxiUserWidth  ),
     .TA(TA),
     .TT(TT),
     .RAND_RESP(RAND_RESP),
     .AX_MIN_WAIT_CYCLES(AX_MIN_WAIT_CYCLES),
     .AX_MAX_WAIT_CYCLES(AX_MAX_WAIT_CYCLES),
     .R_MIN_WAIT_CYCLES(R_MIN_WAIT_CYCLES),
     .R_MAX_WAIT_CYCLES(R_MAX_WAIT_CYCLES),
     .RESP_MIN_WAIT_CYCLES(RESP_MIN_WAIT_CYCLES),
     .RESP_MAX_WAIT_CYCLES(RESP_MAX_WAIT_CYCLES)
   ) axi_ran_slave;
      
   AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth  ),
    .AXI_DATA_WIDTH ( AxiDataWidth  ),
    .AXI_ID_WIDTH   ( AxiOutIdWidth ),
    .AXI_USER_WIDTH ( AxiUserWidth  )
   ) axi_slave();

   AXI_BUS_DV #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth  ),
    .AXI_DATA_WIDTH ( AxiDataWidth  ),
    .AXI_ID_WIDTH   ( AxiOutIdWidth ),
    .AXI_USER_WIDTH ( AxiUserWidth  )
   ) axi (clk_sys);
   
   typedef jtag_ot_test::riscv_dbg #(
      .IrLength       (5                 ),
      .TA             (TA                ),
      .TT             (TT                )
   ) riscv_dbg_t;

   JTAG_DV jtag_mst (clk_sys);
   
   jtag_ot_pkg::jtag_req_t jtag_i;
   jtag_ot_pkg::jtag_rsp_t jtag_o;
      
   axi_out_req_t   ot_axi_req;
   axi_out_resp_t  ot_axi_rsp;

   entropy_src_pkg::entropy_src_rng_req_t es_rng_req;
   entropy_src_pkg::entropy_src_rng_rsp_t es_rng_rsp;
   
   riscv_dbg_t::jtag_driver_t jtag_driver = new(jtag_mst);
   riscv_dbg_t riscv_dbg = new(jtag_driver);
   
   axi_ran_slave axi_rand_slave = new(axi);
     
   `AXI_ASSIGN (axi, axi_slave)
   `AXI_ASSIGN_FROM_REQ (axi_slave, ot_axi_req)
   `AXI_ASSIGN_TO_RESP  (ot_axi_rsp, axi_slave)

   assign jtag_i.tck        = clk_sys;  
   assign jtag_i.trst_n     = jtag_mst.trst_n;
   assign jtag_i.tms        = jtag_mst.tms;
   assign jtag_i.tdi        = jtag_mst.tdi;
   assign jtag_mst.tdo      = jtag_o.tdo;
   

   assign SCK      = spi_o[DioSpiHost0Sck];
   assign CSNeg    = spi_o[DioSpiHost0Csb];
   assign RESETNeg = 1'b1;
   assign WPNeg    = 1'b0;

   assign ibex_uart_rx = '0;
   
   /*
   pad_alsaqr i_I0 ( .OEN(~spi_oe_o[DioSpiHost0Sd0]), .I(spi_o[DioSpiHost0Sd0]), .O(), .PUEN(1'b1), .PAD(I0), 
                     .DRV(2'b00), .SLW(1'b0), .SMT(1'b0), .PWROK(PWROK_S), .IOPWROK(IOPWROK_S), .BIAS(BIAS_S), .RETC(RETC_S)   );
 
   pad_alsaqr i_I1 ( .OEN(~spi_oe_o[DioSpiHost0Sd1]), .I(), .O(spi_i[DioSpiHost0Sd1]), .PUEN(1'b1), .PAD(I1), 
                     .DRV(2'b00), .SLW(1'b0), .SMT(1'b0), .PWROK(PWROK_S), .IOPWROK(IOPWROK_S), .BIAS(BIAS_S), .RETC(RETC_S)   );

   
   s25fs256s #(
    .TimingModel   ( "S25FS256SAGMFI000_F_30pF" ),
    .mem_file_name ( "/scratch/mciani/he-soc/hardware/working_dir/opentitan/scripts/vmem_scripts/outputs/baadcode.vmem" ),
    .UserPreload   ( 1 )
   ) i_spi_flash_csn0 (
    .SI       ( I0 ),
    .SO       ( I1 ),
    .SCK,      
    .CSNeg,    
    .WPNeg    (    ),
    .RESETNeg (    )
   );*/

   // Entropy Src
 /*  rng #(
    .EntropyStreams ( 4 )
   ) u_rng (
    .clk_i          ( clk_sys               ),
    .rst_ni         ( rst_sys_n             ),
    .clk_ast_rng_i  ( clk_sys               ),
    .rst_ast_rng_ni ( rst_sys_n             ),
    .rng_en_i       ( es_rng_req.rng_enable ),
    .rng_fips_i     ( es_rng_fips           ),
    .scan_mode_i    ( '0                    ),
    .rng_b_o        ( es_rng_rsp.rng_b      ),
    .rng_val_o      ( es_rng_rsp.rng_valid  )
  );*/

  axi_cdc_dst #(
    .LogDepth   ( LogDepth         ),
    .aw_chan_t  ( axi_out_aw_chan_t ),
    .w_chan_t   ( axi_out_w_chan_t  ),
    .b_chan_t   ( axi_out_b_chan_t  ),
    .ar_chan_t  ( axi_out_ar_chan_t ),
    .r_chan_t   ( axi_out_r_chan_t  ),
    .axi_req_t  ( axi_out_req_t     ),
    .axi_resp_t ( axi_out_resp_t    )
  ) i_cdc_in (
    .async_data_slave_aw_data_i( async_axi_out_aw_data_o ),
    .async_data_slave_aw_wptr_i( async_axi_out_aw_wptr_o ),
    .async_data_slave_aw_rptr_o( async_axi_out_aw_rptr_i ),
    .async_data_slave_w_data_i ( async_axi_out_w_data_o  ),
    .async_data_slave_w_wptr_i ( async_axi_out_w_wptr_o  ),
    .async_data_slave_w_rptr_o ( async_axi_out_w_rptr_i  ),
    .async_data_slave_b_data_o ( async_axi_out_b_data_i  ),
    .async_data_slave_b_wptr_o ( async_axi_out_b_wptr_i  ),
    .async_data_slave_b_rptr_i ( async_axi_out_b_rptr_o  ),
    .async_data_slave_ar_data_i( async_axi_out_ar_data_o ),
    .async_data_slave_ar_wptr_i( async_axi_out_ar_wptr_o ),
    .async_data_slave_ar_rptr_o( async_axi_out_ar_rptr_i ),
    .async_data_slave_r_data_o ( async_axi_out_r_data_i  ),
    .async_data_slave_r_wptr_o ( async_axi_out_r_wptr_i  ),
    .async_data_slave_r_rptr_i ( async_axi_out_r_rptr_o  ),
    .dst_clk_i                 ( clk_sys   ),
    .dst_rst_ni                ( rst_sys_n ),
    .dst_req_o                 ( ot_axi_req ),
    .dst_resp_i                ( ot_axi_rsp )
  );

/////////////////////////////// DUT ///////////////////////////////
  
  secure_subsystem_synth_wrap dut (
      .clk_i            ( clk_sys       ),
      .clk_ref_i        ( clk_sys       ),
      .rst_ni           ( rst_sys_n     ),
      .pwr_on_rst_ni    ( rst_sys_n     ),
      .fetch_en_i       ( '0            ),
      .bootmode_i       ( '0            ),
      .test_enable_i    ( '0            ),
      .irq_ibex_i       ( '0            ),
   // JTAG port
      .jtag_tck_i       ( jtag_i.tck    ),
      .jtag_tms_i       ( jtag_i.tms    ),
      .jtag_trst_n_i    ( jtag_i.trst_n ),
      .jtag_tdi_i       ( jtag_i.tdi    ),
      .jtag_tdo_o       ( jtag_o.tdo    ),
      .jtag_tdo_oe_o    (               ),
   // Asynch axi port
      .async_axi_out_aw_data_o,
      .async_axi_out_aw_wptr_o,
      .async_axi_out_aw_rptr_i,
      .async_axi_out_w_data_o,
      .async_axi_out_w_wptr_o,
      .async_axi_out_w_rptr_i,
      .async_axi_out_b_data_i,
      .async_axi_out_b_wptr_i,
      .async_axi_out_b_rptr_o,
      .async_axi_out_ar_data_o,
      .async_axi_out_ar_wptr_o,
      .async_axi_out_ar_rptr_i,
      .async_axi_out_r_data_i,
      .async_axi_out_r_wptr_i,
      .async_axi_out_r_rptr_o,      
   // Uart   
      .ibex_uart_rx_i   ( ibex_uart_rx  ),
      .ibex_uart_tx_o   ( ibex_uart_tx  ),
   // SPI host 
      .spi_host_SCK_o   (               ),
      .spi_host_SCK_en_o(               ),
      .spi_host_CSB_o   (               ),
      .spi_host_CSB_en_o(               ),
      .spi_host_SD_o    (               ),
      .spi_host_SD_i    ( '0            ),
      .spi_host_SD_en_o (               ),
      .axi_isolated_o   (               ),
      .axi_isolate_i    ( '0            )
  );

///////////////////////// Processes ///////////////////////////////

  
  initial begin  : main_clock_rst_process
    clk_sys   = 1'b0;
    rst_sys_n = 1'b0;
    jtag_mst.trst_n = 1'b0;
     
    repeat (2)
     #(RTC_CLOCK_PERIOD/2) clk_sys = 1'b0;
     rst_sys_n = 1'b1;
  
    forever
      #(RTC_CLOCK_PERIOD/2) clk_sys = ~clk_sys;
  end // block: main_clock_rst_process
   
  initial begin  : aon_clock_process
    aon_clk   = 1'b0;
    forever
      #(AON_PERIOD/2) aon_clk = ~aon_clk;
  end
  
  initial begin  : io_clock_process
    io_clk   = 1'b0;
    forever
      #(IO_PERIOD/2) io_clk = ~io_clk;
  end
  
  initial begin  : usb_clock_process
    usb_clk   = 1'b0;
    forever
      #(USB_PERIOD/2) usb_clk = ~usb_clk;
  end 

  initial begin  : axi_slave_process
     
    @(posedge rst_sys_n);
    axi_rand_slave.reset();
    repeat (4)  @(posedge clk_sys);
     axi_rand_slave.run();
  
  end
   
  initial  begin : local_jtag_preload
      automatic dm_ot::sbcs_t sbcs = '{
       sbautoincrement: 1'b1,
       sbreadondata   : 1'b1,
       sbaccess       : 3'h2,
       default        : 1'b0
     };

    logic [31:0] dm_status;
    //dm_ot::dtm_op_status_e op;
    automatic int dmi_wait_cycles = 10;

      riscv_dbg.reset_master();
`ifdef IBEX_JTAG
     if ( $value$plusargs ("SRAM=%s", SRAM));
        $display("Testing %s", SRAM);
   
     repeat(150000)
         @(posedge clk_sys); 
     debug_module_init();
     load_binary(SRAM);
     jtag_data_preload();
     jtag_ibex_wakeup(32'h e0000080); //preload the flash
     repeat(400000)
        @(posedge clk_sys);
     jtag_ibex_wakeup(32'h d0008080); //secure boot
     
     
`endif               
  end // block: local_jtag_preload
   
///////////////////////////// Tasks ///////////////////////////////
   
   task debug_module_init;
      
     automatic dm_ot::sbcs_t sbcs = '{
        sbautoincrement: 1'b1,
        sbreadondata   : 1'b1,
        sbaccess       : 3'h2,
        default        : 1'b0
     };
     logic [31:0]  idcode;
     //dm_ot::dtm_op_status_e op;
     automatic int dmi_wait_cycles = 10;

     $info(" JTAG Preloading start time");
     riscv_dbg.wait_idle(300);

     $info(" Start getting idcode of JTAG");
     riscv_dbg.get_idcode(idcode);
      
     $display(" IDCode = %h", idcode);

     $info(" Activating Debug Module");
     // Activate Debug Module
     riscv_dbg.write_dmi(dm_ot::DMControl, 32'h0000_0001);

     $info(" SBA BUSY ");
     // Wait until SBA is free
     do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
     while (sbcs.sbbusy);
     $info(" SBA FREE");      
      
   endtask // debug_module_init

   task jtag_data_preload;
     logic [31:0] rdata;

     automatic dm_ot::sbcs_t sbcs = '{
        sbautoincrement: 1'b1,
        sbreadondata   : 1'b1,
        sbaccess       : 3'h2,
        default        : 1'b0
     };
      
     //dm_ot::dtm_op_status_e op;
     automatic int dmi_wait_cycles = 10;

     $display("======== Initializing the Debug Module ========");

     debug_module_init();
     riscv_dbg.write_dmi(dm_ot::SBCS, sbcs);
     do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);//, op);
     while (sbcs.sbbusy);

     $display("======== Preload data to SRAM ========");

     // Start writing to SRAM
     foreach (sections[addr]) begin
       $display("Writing %h with %0d words", addr << 2, sections[addr]); // word = 8 bytes here
       riscv_dbg.write_dmi(dm_ot::SBAddress0, (addr << 2));
       do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs,  dmi_wait_cycles);//, op);
       while (sbcs.sbbusy);
       
       for (int i = 0; i < sections[addr]; i++) begin
         // $info(" Loading words to SRAM ");
         $display(" -- Word %0d/%0d", i, sections[addr]);      
         riscv_dbg.write_dmi(dm_ot::SBData0, memory[addr + i]);
         // Wait until SBA is free to write next 32 bits
         do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);//, op);
         while (sbcs.sbbusy);
       end // for (int i = 0; i < sections[addr]; i++)
       
     end // foreach (sections[addr])
      
    $display("======== Preloading finished ========");
   
 
    // Preloading finished. Can now start executing
    sbcs.sbreadonaddr = 0;
    sbcs.sbreadondata = 0;
    riscv_dbg.write_dmi(dm_ot::SBCS, sbcs);

  endtask // jtag_data_preload

  // Load ELF binary file
  task load_binary;
    input string binary;                   // File name
    logic [31:0] section_addr, section_len;
    byte         buffer[];
     
    // Read ELF
    void'(read_elf(binary));
    $display("Reading %s", binary);
     
    while (get_section(section_addr, section_len)) begin
      // Read Sections
      automatic int num_words = (section_len + AxiWideBeWidth - 1)/AxiWideBeWidth;
      $display("Reading section %x with %0d words", section_addr, num_words);

      sections[section_addr >> AxiWideByteOffset] = num_words;
      buffer                                      = new[num_words * AxiWideBeWidth];
      void'(read_section(section_addr, buffer));
      for (int i = 0; i < num_words; i++) begin
        automatic logic [AxiWideBeWidth-1:0][7:0] word = '0;
        for (int j = 0; j < AxiWideBeWidth; j++) begin
          word[j] = buffer[i * AxiWideBeWidth + j];
        end
        memory[section_addr/AxiWideBeWidth + i] = word;
      end
    end 

  endtask // load_binary
   
  task jtag_ibex_wakeup;
    input logic [31:0] start_addr;
    logic [31:0] dm_status;
     
    automatic dm_ot::sbcs_t sbcs = '{
        sbautoincrement: 1'b1,
        sbreadondata   : 1'b1,
        sbaccess       : 3'h2,
        default        : 1'b0
     };
    //dm_ot::dtm_op_status_e op;
    automatic int dmi_wait_cycles = 10;


    $info("======== Waking up Ibex using JTAG ========");
    // Initialize the dm module again, otherwise it will not work
    debug_module_init();
    do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);//, op);
    while (sbcs.sbbusy);
    // Write PC to Data0 and Data1
    riscv_dbg.write_dmi(dm_ot::Data0, start_addr);
    do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
    while (sbcs.sbbusy);
    // Halt Req
    riscv_dbg.write_dmi(dm_ot::DMControl, 32'h8000_0001);
    do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
    while (sbcs.sbbusy);
    // Wait for CVA6 to be halted
    do riscv_dbg.read_dmi(dm_ot::DMStatus, dm_status, dmi_wait_cycles);
    while (!dm_status[8]);
    // Ensure haltreq, resumereq and ackhavereset all equal to 0
    riscv_dbg.write_dmi(dm_ot::DMControl, 32'h0000_0001);
    do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
    while (sbcs.sbbusy);
    // Register Access Abstract Command  
    riscv_dbg.write_dmi(dm_ot::Command, {8'h0,1'b0,3'h2,1'b0,1'b0,1'b1,1'b1,4'h0,dm_ot::CSR_DPC});
    do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
    while (sbcs.sbbusy);
    // Resume req. Exiting from debug mode CVA6 will jump at the DPC address.
    // Ensure haltreq, resumereq and ackhavereset all equal to 0
    riscv_dbg.write_dmi(dm_ot::DMControl, 32'h4000_0001);
    do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
    while (sbcs.sbbusy);
    riscv_dbg.write_dmi(dm_ot::DMControl, 32'h0000_0001);
    do riscv_dbg.read_dmi(dm_ot::SBCS, sbcs, dmi_wait_cycles);
    while (sbcs.sbbusy);
     
    // Wait till end of computation

    // When task completed reading the return value using JTAG
    // Mainly used for post synthesis part
    $info("======== Wait for Completion ========");
 
  endtask // execute_application

endmodule
