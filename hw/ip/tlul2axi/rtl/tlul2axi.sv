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

module tlul2axi
  import tlul_pkg::*;
  #(
    parameter int unsigned AXI_ID_WIDTH      = 3,
    parameter int unsigned AXI_ADDR_WIDTH    = 32,
    parameter int unsigned AXI_DATA_WIDTH    = 32,
    parameter int unsigned AXI_USER_WIDTH    = 1
   ) (
   input logic clk_i,
   input logic rst_ni,
    
   //  tlul host
   input  tl_h2d_t tl_req,
   output tl_d2h_t tl_rsp,
 
   //  axi master 
   AXI_BUS.Master  axi_mst

   );
   
   enum logic [3:0] { IDLE, WAIT_B_VALID, WAIT_R_VALID, RESET } state_q, state_d;

   always_comb begin : axi_mst_state_fsm

    case(state_q)

      IDLE: begin       
        if(axi_mst.ar_ready && axi_mst.ar_valid) 
          state_d = WAIT_R_VALID;
        if(axi_mst.aw_ready && axi_mst.w_ready && axi_mst.aw_valid && axi_mst.w_valid)
          state_d = WAIT_B_VALID; 
      end

      WAIT_R_VALID: begin
        if(axi_mst.r_valid && axi_mst.r_ready) 
          state_d = IDLE;
        else
          state_d = WAIT_R_VALID;
      end

      
      WAIT_B_VALID: begin
        if(axi_mst.b_valid && axi_mst.b_ready) 
          state_d = IDLE;
        else
          state_d = WAIT_B_VALID;
      end

      default: state_d = IDLE;
      
    endcase // case (state_q)
      
   end
   
     
   always_comb begin : axi_mst_output_fsm
       
    // Default assignments
        
  
    axi_mst.aw_addr   = tl_req.a_address;
    axi_mst.aw_prot   = 3'b0;
    axi_mst.aw_region = 4'b0;
    axi_mst.aw_len    = 8'b0;
    axi_mst.aw_size   = { 1'b0 , tl_req.a_size };   
    axi_mst.aw_burst  = axi_pkg::BURST_INCR; 
    axi_mst.aw_lock   = 1'b0;
    axi_mst.aw_cache  = 4'b0;
    axi_mst.aw_qos    = 4'b0;
    axi_mst.aw_id     = tl_req.a_source;
    axi_mst.aw_atop   = '0;
    axi_mst.aw_user   = '0;

   
    axi_mst.ar_addr   = tl_req.a_address;
    axi_mst.ar_prot   = 3'b0;
    axi_mst.ar_region = 4'b0;
    axi_mst.ar_len    = 8'b0;
    axi_mst.ar_size   = { 1'b0 , tl_req.a_size };
    axi_mst.ar_burst  = axi_pkg::BURST_INCR; 
    axi_mst.ar_lock   = 1'b0;
    axi_mst.ar_cache  = 4'b0;
    axi_mst.ar_qos    = 4'b0;
    axi_mst.ar_id     = tl_req.a_source;
    axi_mst.ar_user   = '0;

 
    axi_mst.w_data    = '0;
    axi_mst.w_strb    = '0;
    axi_mst.w_user    = '0;

    tl_rsp.d_valid     = 1'b0;
    tl_rsp.d_opcode    = tlul_pkg::AccessAck;
    tl_rsp.d_param     = '0;
    tl_rsp.d_size      = '0;
    tl_rsp.d_source    = '0;
    tl_rsp.d_sink      = '0;
    tl_rsp.d_data      = '0;
    tl_rsp.d_user      = tl_req.a_user;
    tl_rsp.d_error     = '0;
    tl_rsp.a_ready     = '0;

    axi_mst.b_ready   = 1'b0;
    axi_mst.r_ready   = 1'b0;
    axi_mst.w_valid   = 1'b0;
    axi_mst.aw_valid  = 1'b0;
    axi_mst.w_last    = 1'b0;
    axi_mst.ar_valid  = 1'b0;
      
    tl_rsp.a_ready = 1'b0;
    tl_rsp.d_valid = 1'b0;

    case (state_q)

      IDLE: begin
        if(tl_req.a_valid) begin        // request
          tl_rsp.a_ready = 1'b1;   
          if(tl_req.a_opcode == tlul_pkg::Get) // get
            axi_mst.ar_valid = 1'b1; 
          else if (tl_req.a_opcode == tlul_pkg::PutFullData || tl_req.a_opcode == tlul_pkg::PutPartialData) begin                                     
            axi_mst.w_last   = 1'b1;
            axi_mst.aw_valid = 1'b1;
            axi_mst.w_valid  = 1'b1;
          end                   
        end
      end

      WAIT_B_VALID: begin
        tl_rsp.d_source = axi_mst.b_id;
        tl_rsp.d_size   = axi_mst.aw_size[1:0];
        tl_rsp.d_opcode = tlul_pkg::AccessAck;
        tl_rsp.d_error  = axi_mst.b_resp[1];
        axi_mst.w_data = tl_req.a_data;
        axi_mst.w_strb = tl_req.a_mask;
        if(axi_mst.b_valid) begin
          tl_rsp.d_valid  = 1'b1;
          axi_mst.b_ready = 1'b1;
        end
      end

      WAIT_R_VALID: begin
        tl_rsp.d_source = axi_mst.r_id;
        tl_rsp.d_size   = axi_mst.ar_size[1:0];
        tl_rsp.d_opcode = tlul_pkg::AccessAckData;
        tl_rsp.d_error  = axi_mst.r_resp[1];
        tl_rsp.d_data   = axi_mst.r_data;
        if(axi_mst.r_valid) begin
          tl_rsp.d_valid  = 1'b1;
          axi_mst.r_ready = 1'b1;
        end
      end

      default: begin
        axi_mst.b_ready   = 1'b0;
        axi_mst.r_ready   = 1'b0;
        axi_mst.w_valid   = 1'b0;
        axi_mst.aw_valid  = 1'b0;
        axi_mst.w_last    = 1'b0;
        axi_mst.ar_valid  = 1'b0;
      end
          
    endcase 
    
  end 

//----------------
// Registers
//----------------
   
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) 
       state_q  <= IDLE; //RESET
    else 
       state_q  <= state_d;
  end
   
endmodule // tlul2axi
