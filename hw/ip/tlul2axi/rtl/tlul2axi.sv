module tlul2axi #(
    parameter int unsigned AXI_ID_WIDTH      = 8,
    parameter int unsigned AXI_ADDR_WIDTH    = 0,
    parameter int unsigned AXI_DATA_WIDTH    = 32,
    parameter int unsigned AXI_USER_WIDTH    = 21
                 
 ) (
   input logic clk_i,
   input logic rst_ni,
    
   // input tlul host interface
   tlul_bus.DEVICE tl_host,
    
   // output axi master interface
   AXI_BUS.Master  axi_mst

   );
   
   enum logic [3:0] { IDLE, WAIT_B_VALID, WAIT_R_VALID } state_q, state_d;

   always_comb begin : axi_fsm
       
    // Default assignments
        
    axi_mst.aw_valid  = 1'b0;
    axi_mst.aw_addr   = tl_host.tl_req.a_address;
    axi_mst.aw_prot   = 3'b0;
    axi_mst.aw_region = 4'b0;
    axi_mst.aw_len    = 8'b0;
    axi_mst.aw_size   = { 1'b0 , tl_host.tl_req.a_size };   
    axi_mst.aw_burst  = axi_pkg::BURST_INCR; 
    axi_mst.aw_lock   = 1'b0;
    axi_mst.aw_cache  = 4'b0;
    axi_mst.aw_qos    = 4'b0;
    axi_mst.aw_id     = tl_host.tl_req.a_source;
    axi_mst.aw_atop   = '0;
    axi_mst.aw_user   = '0;

    axi_mst.ar_valid  = 1'b0;
    axi_mst.ar_addr   = tl_host.tl_req.a_address;
    axi_mst.ar_prot   = 3'b0;
    axi_mst.ar_region = 4'b0;
    axi_mst.ar_len    = 8'b0;
    axi_mst.ar_size   = { 1'b0 , tl_host.tl_req.a_size };
    axi_mst.ar_burst  = axi_pkg::BURST_INCR; 
    axi_mst.ar_lock   = 1'b0;
    axi_mst.ar_cache  = 4'b0;
    axi_mst.ar_qos    = 4'b0;
    axi_mst.ar_id     = tl_host.tl_req.a_source;
    axi_mst.ar_user   = '0;

    axi_mst.w_valid   = 1'b0;
    axi_mst.w_data    = tl_host.tl_req.a_data;
    axi_mst.w_strb    = tl_host.tl_req.a_mask;
    axi_mst.w_last    = 1'b0;
    axi_mst.w_user    = '0;

    axi_mst.b_ready   = 1'b0;
    axi_mst.r_ready   = 1'b0;

    tl_host.tl_rsp.d_valid     = 1'b0;
    tl_host.tl_rsp.d_opcode    = tlul_pkg::AccessAck;
    tl_host.tl_rsp.d_param     = '0;
    tl_host.tl_rsp.d_size      = '0;
    tl_host.tl_rsp.d_source    = '0;
    tl_host.tl_rsp.d_sink      = '0;
    tl_host.tl_rsp.d_data      = '0;
    tl_host.tl_rsp.d_user      = tl_host.tl_req.a_user;
    tl_host.tl_rsp.d_error     = '0;
    tl_host.tl_rsp.a_ready     = '0;

    case (state_q)

      IDLE: begin

        if(tl_host.tl_req.a_valid) begin        // request
          tl_host.tl_rsp.a_ready = 1'b1;  
          if(tl_host.tl_req.a_opcode == tlul_pkg::Get) begin // get
            axi_mst.ar_valid = 1'b1;
            if(axi_mst.ar_ready)
              state_d = WAIT_R_VALID;
          end else begin                                     // put
            axi_mst.w_last   = 1'b1;
            axi_mst.aw_valid = 1'b1;
            axi_mst.w_valid  = 1'b1;
            if(axi_mst.aw_ready && axi_mst.w_ready)
              state_d = WAIT_B_VALID;
            else
              state_d = IDLE;    
          end 
        end 
      end   

      WAIT_B_VALID: begin

        axi_mst.b_ready = 1'b1;
        if(axi_mst.b_valid) begin
          state_d = IDLE;
          tl_host.tl_rsp.d_valid  = 1'b1; 
          tl_host.tl_rsp.d_source = axi_mst.b_id;
          tl_host.tl_rsp.d_size   = axi_mst.aw_size[1:0];
          tl_host.tl_rsp.d_opcode = tlul_pkg::AccessAck;
          tl_host.tl_rsp.d_error  = axi_mst.b_resp[1]; 
        end else
          state_d = WAIT_B_VALID;  
      end

      WAIT_R_VALID: begin

        axi_mst.r_ready = 1'b1;
        if(axi_mst.r_valid) begin
          state_d = IDLE;
          tl_host.tl_rsp.d_valid  = 1'b1;
          tl_host.tl_rsp.d_source = axi_mst.r_id;
          tl_host.tl_rsp.d_size   = axi_mst.ar_size[1:0];
          tl_host.tl_rsp.d_opcode = tlul_pkg::AccessAckData;
          tl_host.tl_rsp.d_data   = axi_mst.r_data;
          tl_host.tl_rsp.d_error  = axi_mst.r_resp[1]; 
        end else
          state_d = WAIT_R_VALID;
      end

      default: state_d = IDLE;
          
    endcase // case (state_q)
    
  end // block: axi_fsm

//----------------
// Registers
//----------------
   
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) 
       state_q  <= IDLE;
    else 
       state_q  <= state_d;
  end
   
endmodule // tlul2axi
