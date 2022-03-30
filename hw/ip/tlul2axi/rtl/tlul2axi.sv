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
    parameter int unsigned AXI_ADDR_WIDTH    = 64,
    parameter int unsigned AXI_DATA_WIDTH    = 64,
    parameter int unsigned AXI_USER_WIDTH    = 1,
    parameter type axi_req_t  = logic,
    parameter type axi_resp_t = logic
   ) (
   input logic clk_i,
   input logic rst_ni,
    
   //  tlul host
   input  tl_h2d_t tl_req,
   output tl_d2h_t tl_rsp,
 
   //  axi master 
   input  axi_resp_t axi_rsp,
   output axi_req_t  axi_req

   );
   
   enum  logic [2:0] { IDLE, WAIT_B_VALID, WAIT_R_VALID, WAIT_AR_READY, WAIT_AW_READY, WAIT_W_READY } state_q, state_d;

   always_comb  begin

    case(state_q)

      IDLE: begin
        if(axi_req.ar_valid)       
          if(axi_rsp.ar_ready)
            state_d = WAIT_R_VALID;
          else
            state_d = WAIT_AR_READY;
        if(axi_req.aw_valid && axi_req.w_valid)
          case({axi_rsp.aw_ready, axi_rsp.w_ready})
            2'b01:   state_d = WAIT_AW_READY;
            2'b10:   state_d = WAIT_W_READY;
            2'b11:   state_d = WAIT_B_VALID;
            default: state_d = IDLE;
          endcase 
      end // case: IDLE

      WAIT_AW_READY: begin
         if(axi_rsp.aw_ready)
           state_d = WAIT_B_VALID;
         else
           state_d = WAIT_AW_READY;
      end

      WAIT_AR_READY: begin
         if(axi_rsp.ar_ready)
           state_d = WAIT_R_VALID;
         else
           state_d = WAIT_AR_READY;
      end

      WAIT_W_READY: begin
         if(axi_rsp.w_ready)
           state_d = WAIT_B_VALID;
         else
           state_d = WAIT_W_READY;
      end

      WAIT_R_VALID: begin
        if(axi_rsp.r_valid && axi_req.r_ready) 
          state_d = IDLE;
        else
          state_d = WAIT_R_VALID;
      end

      
      WAIT_B_VALID: begin
        if(axi_rsp.b_valid && axi_req.b_ready) 
          state_d = IDLE;
        else
          state_d = WAIT_B_VALID;
      end

      default: state_d = IDLE;
      
    endcase // case (state_q)
      
   end
   
     
   always_comb begin : axi_mst_output_fsm
       
    // Default assignments
        
  
    axi_req.aw.addr   = { 32'b0, tl_req.a_address};
    axi_req.aw.prot   = 3'b0;
    axi_req.aw.region = 4'b0;
    axi_req.aw.len    = 8'b0;
    axi_req.aw.size   = { 1'b0 , tl_req.a_size };   
    axi_req.aw.burst  = axi_pkg::BURST_INCR; 
    axi_req.aw.lock   = 1'b0;
    axi_req.aw.cache  = 4'b0;
    axi_req.aw.qos    = 4'b0;
    axi_req.aw.id     = tl_req.a_source;
    axi_req.aw.atop   = '0;
    axi_req.aw.user   = '0;

   
    axi_req.ar.addr   = { 32'b0, tl_req.a_address};
    axi_req.ar.prot   = 3'b0;
    axi_req.ar.region = 4'b0;
    axi_req.ar.len    = 8'b0;
    axi_req.ar.size   = { 1'b0 , tl_req.a_size };
    axi_req.ar.burst  = axi_pkg::BURST_INCR; 
    axi_req.ar.lock   = 1'b0;
    axi_req.ar.cache  = 4'b0;
    axi_req.ar.qos    = 4'b0;
    axi_req.ar.id     = tl_req.a_source;
    axi_req.ar.user   = '0;
 
    axi_req.w.data    = '0;
    axi_req.w.strb    = '0;
    axi_req.w.user    = '0;

    tl_rsp.d_valid     = 1'b0;
    tl_rsp.d_opcode    = tlul_pkg::AccessAck;
    tl_rsp.d_param     = '0;
    tl_rsp.d_size      = tl_req.a_size;
    tl_rsp.d_source    = '0;
    tl_rsp.d_sink      = '0;
    tl_rsp.d_data      = '0;
    tl_rsp.d_user      = tl_req.a_user;
    tl_rsp.d_error     = '0;
    tl_rsp.a_ready     = '0;

    axi_req.b_ready   = 1'b0;
    axi_req.r_ready   = 1'b0;
    axi_req.w_valid   = 1'b0;
    axi_req.aw_valid  = 1'b0;
    axi_req.w.last    = 1'b0;
    axi_req.ar_valid  = 1'b0;
      
    tl_rsp.a_ready = 1'b0;
    tl_rsp.d_valid = 1'b0;

    case (state_q)

      IDLE: begin
        if(tl_req.a_valid) begin        // request   
          if(tl_req.a_opcode == tlul_pkg::Get) begin // get
            axi_req.ar_valid = 1'b1;
            if(axi_rsp.ar_ready)
              tl_rsp.a_ready = 1'b1; 
          end else if (tl_req.a_opcode == tlul_pkg::PutFullData || tl_req.a_opcode == tlul_pkg::PutPartialData) begin                                     
            axi_req.w.last   = 1'b1;
            axi_req.aw_valid = 1'b1;
            axi_req.w_valid  = 1'b1;
            axi_req.w.data = { 32'b0, tl_req.a_data};
            axi_req.w.strb = {  4'b0, tl_req.a_mask};
            if(axi_rsp.aw_ready && axi_rsp.w_ready)
              tl_rsp.a_ready = 1'b1;
          end                   
        end 
      end

      WAIT_AR_READY: begin 
          axi_req.ar_valid = 1'b1;
          if(axi_rsp.ar_ready)
            tl_rsp.a_ready = 1'b1;
      end

      WAIT_AW_READY: begin
         axi_req.aw_valid = 1'b1;  
         if(axi_rsp.aw_ready)
            tl_rsp.a_ready = 1'b1;
      end

      WAIT_W_READY: begin 
          axi_req.w.last   = 1'b1;
          axi_req.w_valid  = 1'b1;
          axi_req.w.data   = { 32'b0,tl_req.a_data};
          axi_req.w.strb   = {  4'b0,tl_req.a_mask};
          if(axi_rsp.w_ready)
            tl_rsp.a_ready = 1'b1;
      end

      WAIT_B_VALID: begin
        if(axi_rsp.b_valid) begin
          tl_rsp.d_source = axi_rsp.b.id;
          tl_rsp.d_opcode = tlul_pkg::AccessAck;
          tl_rsp.d_error  = axi_rsp.b.resp[1];
          tl_rsp.d_valid  = 1'b1;
          axi_req.b_ready = 1'b1;
        end
      end

      WAIT_R_VALID: begin
        if(axi_rsp.r_valid) begin
          tl_rsp.d_source = axi_rsp.r.id;
          tl_rsp.d_opcode = tlul_pkg::AccessAckData;
          tl_rsp.d_error  = axi_rsp.r.resp[1];
          tl_rsp.d_data   = axi_rsp.r.data[31:0];
          tl_rsp.d_valid  = 1'b1;
          axi_req.r_ready = 1'b1;
        end
      end

      default: begin
        axi_req.b_ready   = 1'b0;
        axi_req.r_ready   = 1'b0;
        axi_req.w_valid   = 1'b0;
        axi_req.aw_valid  = 1'b0;
        axi_req.w_last    = 1'b0;
        axi_req.ar_valid  = 1'b0;
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
