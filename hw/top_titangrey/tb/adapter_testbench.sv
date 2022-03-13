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

`include "../../ip/tlul2axi/rtl/tlul_assign.svh"

module adapter_testbench #();

   localparam time TA   = 1ns;
   localparam time TT   = 2ns;
   localparam int unsigned RTC_CLOCK_PERIOD = 30.517us;

   logic rst_ni;
   logic clk_i;

   semaphore lock;
   
   import tlul_pkg::*;
   import tlul_functions::*;
   

  // tl_h2d_t tl_req;
  // tl_d2h_t tl_rsp;
   
   logic [31:0] mst_wdata;
   logic [31:0] mst_addr;
   logic        mst_req;
   logic        mst_we;
   logic [3:0]  mst_be;
   
   logic [31:0] mst_rdata;
   logic        mst_rvalid;
   
   typedef tlul_functions::tlul_driver #( .TT(TT), .TA(TA)) tlul_driver_t;
                                     
  
   tlul_bus tl_bus();
   tlul_driver_t tlul_master = new(tl_bus);

  // `REQ_ASSIGN(tl_req, tl_bus.tl_req);
  // `RSP_ASSIGN(tl_bus.tl_rsp, tl_rsp);
   assign tl_bus.clk_i = clk_i;
  
   AXI_BUS #(
    .AXI_ADDR_WIDTH ( 32 ),
    .AXI_DATA_WIDTH ( 32 ),
    .AXI_ID_WIDTH   ( 3 ),
    .AXI_USER_WIDTH ( 1 )
   ) axi_slave();
/*
   axi_tlul_adapter tlul_adapter (
     .clk_i,
     .rst_ni,
     .tl_req(tl_req),
     .tl_rsp(tl_rsp),
     .axi_mst_intf(axi_slave)
   );
  */
   
   axi2mem #(
    .AXI_ID_WIDTH   ( 3 ),
    .AXI_ADDR_WIDTH ( 32 ),
    .AXI_DATA_WIDTH ( 32 ),
    .AXI_USER_WIDTH ( 1 )
   ) axi2mem (
    .clk_i      ( clk_i                ),
    .rst_ni     ( rst_ni               ),
    .slave      ( axi_slave            ),
    .req_o      ( mst_req              ),
    .we_o       ( mst_we               ),
    .addr_o     ( mst_addr             ),
    .be_o       ( mst_be               ),
    .data_o     ( mst_wdata            ),
    .data_i     ( mst_rdata            )
   );
      
  
   tlul2axi u_tlul2axi (
      .clk_i,
      .rst_ni,            
      .tl_host(tl_bus),
      .axi_mst(axi_slave)
   );

   
   ram_2p #(
      .Depth(1024*1024/4)
   ) u_ram (
      .clk_i       (clk_i),
      .rst_ni      (rst_ni),

      .a_req_i     (mst_req),
      .a_we_i      (mst_we),
      .a_be_i      (mst_be),
      .a_addr_i    (mst_addr),
      .a_wdata_i   (mst_wdata),
      .a_rvalid_o  (mst_rvalid),
      .a_rdata_o   (mst_rdata)
   );
     
   initial begin
      
    lock = new(1);
    clk_i  = 1'b0;
    rst_ni = 1'b0;
    repeat (10)
      #(RTC_CLOCK_PERIOD/2) clk_i = 1'b0;
      rst_ni = 1'b1;
    forever
      #(RTC_CLOCK_PERIOD/2) clk_i = ~clk_i;
      
   end

   initial begin : proc_axi_master
      
    automatic logic [31:0] addr;
    automatic logic [31:0] rdata;
    automatic logic [31:0] wdata;
    automatic logic [7:0]  strb;
    automatic logic  err;

///////////////////////////////// RESET ///////////////////////////////
      
    @(posedge rst_ni);
    tlul_master.reset_master();
    repeat ($urandom_range(10,15)) @(posedge clk_i);

///////////////////////////////// START ///////////////////////////////
      
    addr = 'h1A100010;
    wdata = 32'h25C350;
     
    tlul_master.PutFullData(addr, wdata, err);
    $display("PutFullData to addr: %0h. Data: %0h. Err? %0h", addr, wdata, err);
    repeat ($urandom_range(10,15)) @(posedge clk_i);

    tlul_master.Get(addr, rdata, err);
    $display("Get to addr: %0h. Data: %0h. Err? %0h", addr, rdata, err);
    repeat ($urandom_range(10,15)) @(posedge clk_i);

//////////////////////////////////////////////////////////////////////
      
    addr = 'h1A100014;
    wdata = 32'h35C350;
      
    tlul_master.PutFullData(addr, wdata, err);
    $display("PutFullData to addr: %0h. Data: %0h. Err? %0h", addr, wdata, err);
    repeat ($urandom_range(10,15)) @(posedge clk_i);

    tlul_master.Get(addr, rdata, err);
    $display("Get to addr: %0h. Data: %0h. Err? %0h", addr, rdata, err);
    repeat ($urandom_range(10,15)) @(posedge clk_i);

//////////////////////////////////////////////////////////////////////
             
    addr = 'h1A100018;
    wdata = 32'h00000000;
    
      
      
    tlul_master.PutFullData(addr, wdata, err);
    $display("PutPartialData to addr: %0h. Data: %0h. Err? %0h", addr, wdata, err);
    repeat ($urandom_range(10,15)) @(posedge clk_i);

    tlul_master.Get(addr, rdata, err);
    $display("Get to addr: %0h. Data: %0h. Err? %0h", addr, rdata, err);
    repeat ($urandom_range(10,15)) @(posedge clk_i);

//////////////////////////////////////////////////////////////////////
             
    addr = 'h1A100018;
    wdata = 32'hFFFFFFFF;
    strb  = 4'b1001;
      
      
    tlul_master.PutPartialData(addr, wdata, strb, err);
    $display("PutPartialData to addr: %0h. Data: %0h. Err? %0h", addr, wdata, err);
    repeat ($urandom_range(10,15)) @(posedge clk_i);

    tlul_master.Get(addr, rdata, err);
    $display("Get to addr: %0h. Data: %0h. Err? %0h", addr, rdata, err);
    repeat ($urandom_range(10,15)) @(posedge clk_i);


//////////////////////////////// END ////////////////////////////////

        
    $finish;
      
   end 
   
endmodule
