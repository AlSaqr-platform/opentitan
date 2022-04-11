// Copyright (c) 2022 ETH Zurich and University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
//

`include "../include/assign.svh"
`include "../include/typedef.svh"

module axi_scmi_mailbox 
  import scmi_reg_pkg::*;
#(
  parameter int unsigned AxiAddrWidth = 32'd0,
  parameter int unsigned AxiDataWidth = 32'd0,
  parameter type         axi_req_t    = logic,
  parameter type         axi_resp_t   = logic
) (
  input  logic             clk_i,       // Clock
  input  logic             rst_ni,      // Asynchronous reset active low

  input  axi_req_t         ibex_axi_req,  
  output axi_resp_t        ibex_axi_rsp,

  input  axi_req_t         ariane_axi_req,
  output axi_resp_t        ariane_axi_rsp
   
  //output logic       [1:0] irq_o       // interrupt output for each port
);

  typedef logic [AxiAddrWidth-1:0]   addr_t;
  typedef logic [AxiDataWidth-1:0]   data_t;
  typedef logic [AxiDataWidth/8-1:0] strb_t;
  
  `REG_BUS_TYPEDEF_REQ(reg_req_t, addr_t, data_t, strb_t)
  `REG_BUS_TYPEDEF_RSP(reg_rsp_t, data_t)

   scmi_reg2hw_t reg2hw;
   
   reg_req_t reg_req, reg_req_ariane, reg_req_ibex;
   reg_rsp_t reg_rsp, reg_rsp_ariane, reg_rsp_ibex;

   assign reg_req        = ~reg2hw.channel_status.channel_free.q ? reg_req_ariane : reg_req_ibex;
   assign reg_rsp_ibex   = ~reg2hw.channel_status.channel_free.q ? '0 : reg_rsp;
   assign reg_rsp_ariane = ~reg2hw.channel_status.channel_free.q ? reg_rsp : '0;
/*
   always_comb
     case(reg2hw.channel_status.channel_free.q)
       
       1'b0:    begin
                reg_req = reg_req_ibex;
                reg_rsp_ibex = reg_rsp;
                reg_rsp_ariane = '0; 
                end
       
       1'b1:    begin
                reg_req = reg_req_ariane;
                reg_rsp_ariane = reg_rsp;
                reg_rsp_ibex   = '0;
                end
           
       default: begin
                reg_req = reg_req_ariane;
                reg_rsp_ariane = reg_rsp;
                reg_rsp_ibex   = '0;
                end
     endcase 
   end
*/
   scmi_reg_top #(
     .reg_req_t(reg_req_t),
     .reg_rsp_t(reg_rsp_t),
     .AW(AxiAddrWidth)
   ) u_shared_memory (
     .clk_i,
     .rst_ni,
     .reg_req_i(reg_req),
     .reg_rsp_o(reg_rsp),
     .reg2hw,
     .devmode_i(1'b1)
   );
   
   axi_to_reg #(
     .ADDR_WIDTH(AxiAddrWidth),
     .DATA_WIDTH(AxiDataWidth),
     .ID_WIDTH(8),
     .USER_WIDTH(1),
     .AXI_MAX_WRITE_TXNS(1),
     .AXI_MAX_READ_TXNS(1),
     .DECOUPLE_W(0),
     .axi_req_t(axi_req_t),
     .axi_rsp_t(axi_resp_t),
     .reg_req_t(reg_req_t),
     .reg_rsp_t(reg_rsp_t)
   ) u_ariane_agent (
     .clk_i,
     .rst_ni,
     .testmode_i(1'b0),
     .axi_req_i(ariane_axi_req),
     .axi_rsp_o(ariane_axi_rsp),
     .reg_req_o(reg_req_ariane),
     .reg_rsp_i(reg_rsp_ariane)
   );

    axi_to_reg #(
     .ADDR_WIDTH(AxiAddrWidth),
     .DATA_WIDTH(AxiDataWidth),
     .ID_WIDTH(8),
     .USER_WIDTH(1),
     .AXI_MAX_WRITE_TXNS(1),
     .AXI_MAX_READ_TXNS(1),
     .DECOUPLE_W(0),
     .axi_req_t(axi_req_t),
     .axi_rsp_t(axi_resp_t),
     .reg_req_t(reg_req_t),
     .reg_rsp_t(reg_rsp_t)
   ) u_ibex_platform (
     .clk_i,
     .rst_ni,
     .testmode_i(1'b0),
     .axi_req_i(ibex_axi_req),
     .axi_rsp_o(ibex_axi_rsp),
     .reg_req_o(reg_req_ibex),
     .reg_rsp_i(reg_rsp_ibex)
   ); 

endmodule // axi_scmi_mailbox
