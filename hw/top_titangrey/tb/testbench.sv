// Copyright 2022 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "../../ip/tlul2axi/test/axi_assign.svh"
`include "../../ip/tlul2axi/test/axi_typedef.svh"

module testbench ();

   import lc_ctrl_pkg::*;
   import jtag_pkg::*;
   import jtag_test::*;
   import dm::*;
   
   import "DPI-C" function read_elf(input string filename);
   import "DPI-C" function byte get_section(output longint address, output longint len); 
   import "DPI-C" context function byte read_section(input longint address, inout byte buffer[]);
   
 ////////////////////////////  Defines ////////////////////////////
   
   parameter int          AW = 64;   
   parameter int          DW = 64;  
   parameter int          IW = 8;   
   parameter int          UW = 1;
   parameter int unsigned SW = DW / 8;
 
   localparam AxiWideBeWidth    = 4;
   localparam AxiWideByteOffset = $clog2(AxiWideBeWidth);

   localparam time TA   = 1ns;
   localparam time TT   = 2ns;
   
   parameter bit   RAND_RESP = 0; 
   parameter int   AX_MIN_WAIT_CYCLES = 0;   
   parameter int   AX_MAX_WAIT_CYCLES = 0;   
   parameter int   R_MIN_WAIT_CYCLES = 0;   
   parameter int   R_MAX_WAIT_CYCLES = 0;   
   parameter int   RESP_MIN_WAIT_CYCLES = 0;
   parameter int   RESP_MAX_WAIT_CYCLES = 0;
   parameter int   NUM_BEATS = 100;
   
   localparam int unsigned RTC_CLOCK_PERIOD = 30.517us;
   
   int          sections [bit [31:0]];
   logic [31:0] memory[bit [31:0]];

   logic        finished = 1'b0;
   logic        rst_ibex_n;
   
   
   
   string       binary;
   
   typedef   logic [AW-1:0] axi_addr_t;
   typedef   logic [DW-1:0] axi_data_t;
   typedef   logic [IW-1:0] axi_id_t;
   typedef   logic [SW-1:0] axi_strb_t;
   typedef   logic [UW-1:0] axi_user_t;

      
   logic  clk_sys = 1'b0;
   logic  rst_sys_n;
   
   jtag_pkg::jtag_req_t jtag_i;
   jtag_pkg::jtag_rsp_t jtag_o;

   typedef axi_test::axi_rand_slave #(  
     .AW(AW),
     .DW(DW),
     .IW(IW),
     .UW(UW),
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
    .AXI_ADDR_WIDTH ( 64 ),
    .AXI_DATA_WIDTH ( 64 ),
    .AXI_ID_WIDTH   ( 8 ),
    .AXI_USER_WIDTH ( 1 )
   ) axi_slave();

   AXI_BUS_DV #(
     .AXI_ADDR_WIDTH(AW),
     .AXI_DATA_WIDTH(DW),
     .AXI_ID_WIDTH(IW),
     .AXI_USER_WIDTH(UW)
   ) axi (clk_sys);
   
   logic [3:0] tieoff_data = 4'b0;
   logic       enable      = 1'b0;
   logic       test_reset;
   logic       irq_ibex_i;
   
   `AXI_TYPEDEF_AW_CHAN_T (axi_aw_t, axi_addr_t, axi_id_t, axi_user_t)
   `AXI_TYPEDEF_W_CHAN_T  (axi_w_t, axi_data_t, axi_strb_t, axi_user_t)
   `AXI_TYPEDEF_B_CHAN_T  (axi_b_t, axi_id_t, axi_user_t)
   `AXI_TYPEDEF_AR_CHAN_T (axi_ar_t, axi_addr_t, axi_id_t, axi_user_t)
   `AXI_TYPEDEF_R_CHAN_T  (axi_r_t, axi_data_t, axi_id_t, axi_user_t)
   `AXI_TYPEDEF_REQ_T     (axi_req_t, axi_aw_t, axi_w_t, axi_ar_t)
   `AXI_TYPEDEF_RESP_T    (axi_resp_t, axi_b_t, axi_r_t)
   
   `AXI_ASSIGN (axi, axi_slave)
   `AXI_ASSIGN_FROM_REQ (axi_slave, axi_req)
   
   `AXI_ASSIGN_TO_RESP  (axi_rsp, axi_slave)

   axi_req_t  axi_req;
   axi_resp_t axi_rsp;

   axi_ran_slave axi_rand_slave = new(axi);

   // JTAG Definition
   typedef jtag_test::riscv_dbg #(
      .IrLength       (5                 ),
      .TA             (TA                ),
      .TT             (TT                ),
      .JtagSampleDelay(0                 )
   ) riscv_dbg_t;
  
    // JTAG driver
    JTAG_DV jtag_mst (clk_sys);
   
    riscv_dbg_t::jtag_driver_t jtag_driver = new(jtag_mst);
    riscv_dbg_t riscv_dbg = new(jtag_driver);


    assign jtag_i.tck        = clk_sys;  
    assign jtag_i.trst_n     = jtag_mst.trst_n;
    assign jtag_i.tms        = jtag_mst.tms;
    assign jtag_i.tdi        = jtag_mst.tdi;
   
    assign jtag_mst.tdo      = jtag_o.tdo;
   
/////////////////////////////// DUT ///////////////////////////////
   
   opentitan #(
    .axi_req_t(axi_req_t),
    .axi_resp_t(axi_resp_t)
   ) dut (

    // spi_device
    .test_reset,
    .rst_ibex_n,
    .cio_spi_device_sck_p2d(1'b0),
    .cio_spi_device_csb_p2d(1'b0),
    .cio_spi_device_sd_p2d(tieoff_data),
          
    // spi_host0
    .cio_spi_host0_sd_p2d(tieoff_data),
          
    // spi_host1
    .cio_spi_host1_sd_p2d(tieoff_data),
 
    .scan_rst_ni (rst_sys_n),
    .scan_en_i (1'b1),
    .scanmode_i (lc_ctrl_pkg::On),
    .ast_clk_byp_ack_i(lc_ctrl_pkg::Off), 
    
    .por_n_i (rst_sys_n),
    .clk_main_i (clk_sys),
    .clk_io_i(clk_sys),
    .clk_usb_i(clk_sys),
    .clk_aon_i(clk_sys),
    .axi_req(axi_req),
    .axi_rsp(axi_rsp),
    .irq_ibex_i,
    .jtag_i,
    .jtag_o
   );

///////////////////////// Processes ///////////////////////////////

   initial begin  : ibex_rst
     rst_ibex_n = 1'b0;
     @(posedge finished);
     repeat(20) @(posedge clk_sys); 
     rst_ibex_n = 1'b1; 
   end
   
   initial begin  : ibex_irq
     
     @(posedge rst_sys_n);
     irq_ibex_i = 1'b0;
      
     /*repeat (800) @(posedge clk_sys);
     irq_ibex_i = 1'b1;
      
     repeat (10)  @(posedge clk_sys);
     irq_ibex_i = 1'b0;
      */
   end
   
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

   initial begin  : axi_slave_process
      
     @(posedge rst_sys_n);
     axi_rand_slave.reset();
     repeat (4)  @(posedge clk_sys);

     axi_rand_slave.run();
   
   end

   initial begin: reset_jtag
      
      jtag_mst.tdi = 0;
      jtag_mst.tms = 0;
      jtag_mst.trst_n = 1'b0;
      
      @(posedge rst_sys_n);
 
      repeat (20) @(posedge clk_sys);
      
      jtag_mst.trst_n = 1'b1;
      
   end
   
   initial  begin : local_jtag_preload

      automatic dm::sbcs_t sbcs = '{
        sbautoincrement: 1'b1,
        sbreadondata   : 1'b1,
        default        : 1'b0
      };
      
      if ( $value$plusargs ("OT_STRING=%s", binary));
         $display("Testing %s", binary);
         
      repeat(50)
          @(posedge clk_sys);
      
      debug_module_init();
      load_binary(binary);
      
      
      // Call the JTAG preload task
      jtag_data_preload();
          
      #(RTC_CLOCK_PERIOD)
;
      jtag_ibex_wakeup(32'h 10000080);
      //jtag_read_eoc();
      
      
   end // block: local_jtag_preload
   
///////////////////////////// Tasks ///////////////////////////////
   
   task debug_module_init;
      
     logic [31:0]  idcode;
     automatic dm::sbcs_t sbcs;

     $info(" JTAG Preloading start time");
     riscv_dbg.wait_idle(300);

     $info(" Start getting idcode of JTAG");
     riscv_dbg.get_idcode(idcode);
      
     /*
     // Check Idcode
     assert (idcode == dm_idcode)
     else $error(" Wrong IDCode, expected: %h, actual: %h", dm_idcode, idcode);
     */
      
     $display(" IDCode = %h", idcode);

     $info(" Activating Debug Module");
     // Activate Debug Module
     riscv_dbg.write_dmi(dm::DMControl, 32'h0000_0001);

     $info(" SBA BUSY ");
     // Wait until SBA is free
     do riscv_dbg.read_dmi(dm::SBCS, sbcs);
     while (sbcs.sbbusy);
     $info(" SBA FREE");      
      
   endtask // debug_module_init

   task jtag_data_preload;
     logic [31:0] rdata;

     automatic dm::sbcs_t sbcs = '{
       sbautoincrement: 1'b1,
       sbreadondata   : 1'b1,
       default        : 1'b0
     };

     $display("======== Initializing the Debug Module ========");

     debug_module_init();
     riscv_dbg.write_dmi(dm::SBCS, sbcs);
     do riscv_dbg.read_dmi(dm::SBCS, sbcs);
     while (sbcs.sbbusy);

     $display("======== Preload data to SRAM ========");

     // Start writing to SRAM
     foreach (sections[addr]) begin
       $display("Writing %h with %0d words", addr << 2, sections[addr]); // word = 8 bytes here
       riscv_dbg.write_dmi(dm::SBAddress0, (addr << 2));
       do riscv_dbg.read_dmi(dm::SBCS, sbcs);
       while (sbcs.sbbusy);
       
       for (int i = 0; i < sections[addr]; i++) begin
         // $info(" Loading words to SRAM ");
         $display(" -- Word %0d/%0d", i, sections[addr]);      
         riscv_dbg.write_dmi(dm::SBData0, memory[addr + i]);
         // Wait until SBA is free to write next 32 bits
         do riscv_dbg.read_dmi(dm::SBCS, sbcs);
         while (sbcs.sbbusy);
       end // for (int i = 0; i < sections[addr]; i++)
       
     end // foreach (sections[addr])
      
    $display("======== Preloading finished ========");
   
 
    // Preloading finished. Can now start executing
    sbcs.sbreadonaddr = 0;
    sbcs.sbreadondata = 0;
    riscv_dbg.write_dmi(dm::SBCS, sbcs);

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
     
    automatic dm::sbcs_t sbcs = '{
      sbautoincrement: 1'b1,
      sbreadondata   : 1'b1,
      default        : 1'b0
    };

    $info("======== Waking up Ibex using JTAG ========");
    // Initialize the dm module again, otherwise it will not work
    debug_module_init();
    do riscv_dbg.read_dmi(dm::SBCS, sbcs);
    while (sbcs.sbbusy);
    // Write PC to Data0 and Data1
    riscv_dbg.write_dmi(dm::Data0, start_addr);
    do riscv_dbg.read_dmi(dm::SBCS, sbcs);
    while (sbcs.sbbusy);
    // Halt Req
    riscv_dbg.write_dmi(dm::DMControl, 32'h8000_0001);
    do riscv_dbg.read_dmi(dm::SBCS, sbcs);
    while (sbcs.sbbusy);
    // Wait for CVA6 to be halted
    do riscv_dbg.read_dmi(dm::DMStatus, dm_status);
    while (!dm_status[8]);
    // Ensure haltreq, resumereq and ackhavereset all equal to 0
    riscv_dbg.write_dmi(dm::DMControl, 32'h0000_0001);
    do riscv_dbg.read_dmi(dm::SBCS, sbcs);
    while (sbcs.sbbusy);
    // Register Access Abstract Command  
    riscv_dbg.write_dmi(dm::Command, {8'h0,1'b0,3'h2,1'b0,1'b0,1'b1,1'b1,4'h0,dm::CSR_DPC});
    do riscv_dbg.read_dmi(dm::SBCS, sbcs);
    while (sbcs.sbbusy);
    // Resume req. Exiting from debug mode CVA6 will jump at the DPC address.
    // Ensure haltreq, resumereq and ackhavereset all equal to 0
    riscv_dbg.write_dmi(dm::DMControl, 32'h4000_0001);
    do riscv_dbg.read_dmi(dm::SBCS, sbcs);
    while (sbcs.sbbusy);
    riscv_dbg.write_dmi(dm::DMControl, 32'h0000_0001);
    do riscv_dbg.read_dmi(dm::SBCS, sbcs);
    while (sbcs.sbbusy);
     
    // Wait till end of computation

    // When task completed reading the return value using JTAG
    // Mainly used for post synthesis part
    $info("======== Wait for Completion ========");
 /*
    repeat(500) @(posedge clk_sys);
    irq_ibex_i = 1'b1;
    repeat(10) @(posedge clk_sys);
    irq_ibex_i = 1'b0;
*/
  endtask // execute_application
/*
  task jtag_read_eoc;
    input logic [31:0] start_addr;
     
    automatic dm::sbcs_t sbcs = '{
      sbautoincrement: 1'b1,
      sbreadondata   : 1'b1,
      default        : 1'b0
    };

    logic [31:0] to_host_addr;
    to_host_addr = start_addr + 32'h1000;
 
    // Initialize the dm module again, otherwise it will not work
    debug_module_init();
    sbcs.sbreadonaddr = 1;
    sbcs.sbautoincrement = 0;
    riscv_dbg.write_dmi(dm::SBCS, sbcs);
    do riscv_dbg.read_dmi(dm::SBCS, sbcs);
    while (sbcs.sbbusy);

    riscv_dbg.write_dmi(dm::SBAddress0, to_host_addr); // tohost address
    riscv_dbg.wait_idle(10);
    do begin 
	     do riscv_dbg.read_dmi(dm::SBCS, sbcs);
	     while (sbcs.sbbusy);
       riscv_dbg.write_dmi(dm::SBAddress0, to_host_addr); // tohost address
	     do riscv_dbg.read_dmi(dm::SBCS, sbcs);
	     while (sbcs.sbbusy);
       riscv_dbg.read_dmi(dm::SBData0, retval);
       # 100ns;
    end while (~retval[0]);
     

    if (retval[31:1]!=0) begin
        `uvm_error( "Core Test",  $sformatf("*** FAILED *** (tohost = %0d)",retval[31:1]))
    end else begin
        `uvm_info( "Core Test",  $sformatf("*** SUCCESS *** (tohost = %0d)", (retval[31:1])), UVM_LOW)
    end

     $finish;
     
  endtask // jtag_read_eoc
*/
endmodule
