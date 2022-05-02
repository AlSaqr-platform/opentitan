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
   
   logic [3:0] tieoff_data = 4'b0;
   logic       enable      = 1'b0;
   logic       test_reset;
   logic       irq_ibex_i;


   
   parameter int   AW = 64;   
   parameter int   DW = 64;  
   parameter int   IW = 8;   
   parameter int   UW = 1;
   localparam time TA   = 1ns;
   localparam time TT   = 2ns;
   parameter int unsigned SW = DW / 8;
   parameter bit   RAND_RESP = 0; 
   parameter int   AX_MIN_WAIT_CYCLES = 0;   
   parameter int   AX_MAX_WAIT_CYCLES = 0;   
   parameter int   R_MIN_WAIT_CYCLES = 0;   
   parameter int   R_MAX_WAIT_CYCLES = 0;   
   parameter int   RESP_MIN_WAIT_CYCLES = 0;
   parameter int   RESP_MAX_WAIT_CYCLES = 0;
   parameter int   NUM_BEATS = 100;
   localparam int unsigned RTC_CLOCK_PERIOD = 30.517us;
  // parameter MemInitFile = "/scratch/ciani/cva6/hardware/working_dir/opentitan/hw/top_titangrey/examples/sw/simple_system/hello_test/hello_test.vmem";
  // parameter mem = i_sim_mem.mem;
   

     
   typedef   logic [AW-1:0] axi_addr_t;
   typedef   logic [DW-1:0] axi_data_t;
   typedef   logic [IW-1:0] axi_id_t;
   typedef   logic [SW-1:0] axi_strb_t;
   typedef   logic [UW-1:0] axi_user_t;
      
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
   
   logic clk_sys = 1'b0, rst_sys_n;
   
   edn_pkg::edn_req_t fake_ast_edn;
   
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

   `AXI_TYPEDEF_AW_CHAN_T (axi_aw_t, axi_addr_t, axi_id_t, axi_user_t)
   `AXI_TYPEDEF_W_CHAN_T  (axi_w_t, axi_data_t, axi_strb_t, axi_user_t)
   `AXI_TYPEDEF_B_CHAN_T  (axi_b_t, axi_id_t, axi_user_t)
   `AXI_TYPEDEF_AR_CHAN_T (axi_ar_t, axi_addr_t, axi_id_t, axi_user_t)
   `AXI_TYPEDEF_R_CHAN_T  (axi_r_t, axi_data_t, axi_id_t, axi_user_t)
   `AXI_TYPEDEF_REQ_T     (axi_req_t, axi_aw_t, axi_w_t, axi_ar_t)
   `AXI_TYPEDEF_RESP_T    (axi_resp_t, axi_b_t, axi_r_t)

   axi_req_t  axi_req;
   axi_resp_t axi_rsp;
     
   axi_ran_slave axi_rand_slave = new(axi);
   
   `AXI_ASSIGN (axi, axi_slave)
   `AXI_ASSIGN_FROM_REQ (axi_slave, axi_req)
   
   `AXI_ASSIGN_TO_RESP  (axi_rsp, axi_slave)
   
   
   opentitan #(
    .axi_req_t(axi_req_t),
    .axi_resp_t(axi_resp_t)
   ) dut (

    // spi_device
    .test_reset,
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
    .irq_ibex_i
   );
   
   initial begin  : ibex_irq
     
     @(posedge rst_sys_n);
     irq_ibex_i = 1'b0;
      
     repeat (800) @(posedge clk_sys);
     irq_ibex_i = 1'b1;
      
     repeat (10)  @(posedge clk_sys);
     irq_ibex_i = 1'b0;
      
   end
   
   initial begin  : main_clock_rst_process
 
     clk_sys   = 1'b0;
     rst_sys_n = 1'b0;
     repeat (10)
       #(RTC_CLOCK_PERIOD/2) clk_sys = 1'b0;
       rst_sys_n = 1'b1;
     forever
       #(RTC_CLOCK_PERIOD/2) clk_sys = ~clk_sys;
   end

   initial begin  : axi_slave_process
      
     @(posedge rst_sys_n);
     axi_rand_slave.reset();
     repeat (4) @(posedge clk_sys);

     axi_rand_slave.run();
   
   end
      
endmodule
