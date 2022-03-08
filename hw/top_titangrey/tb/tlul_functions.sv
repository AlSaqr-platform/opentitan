package tlul_tasks;
   
  import tlul_pkg::*; 
  
  localparam time TA   = 1ns;
  localparam time TT   = 2ns;

  tl_h2d_t tl_req;
  tl_d2h_t tl_rsp;
   
/*
  task reset_master(input tl_h2d_t tl_req, input logic clk_i);
   
    tl_req.a_valid     <= '0;
    tl_req.a_opcode    <= tlul_pkg::Get;
    tl_req.a_param     <= '0;
    tl_req.a_size      <= '0;
    tl_req.a_source    <= '0;
    tl_req.a_address   <= '0;
    tl_req.a_mask      <= '1;
    tl_req.a_data      <= '0;
    tl_req.a_user      <= '0;
    tl_req.d_ready     <= '0;
  endtask*/

  /*  function void reset_slave();
      tl_rsp.d_valid     <= '0;
      tl_rsp.d_opcode    <= tlul_pkg::AccessAckData;
      tl_rsp.d_param     <= '0;
      tl_rsp.d_size      <= '0;
      tl_rsp.d_source    <= '0;
      tl_rsp.d_sink      <= '0;
      tl_rsp.d_data      <= '0;
      tl_rsp.d_user      <= '0;
      tl_rsp.d_error     <= '0;
      tl_rsp.a_ready     <= '0;
    endfunction */

  task cycle_start;
    #TT;
  endtask

  task cycle_end (input logic clk_i);
    @(posedge clk_i);
  endtask

  task read(
    input  logic   clk_i,
    input  [31:0]  addr,
    output [31:0]  data,
    output logic   err
  );
        
    tl_req.a_address   <= #TA addr;
    tl_req.a_opcode    <= #TA tlul_pkg::Get;
     
    cycle_end (clk_i);
    tl_req.a_valid     <= #TA 1'b1;
    cycle_start();
     
    while (!tl_rsp.a_ready) begin
      cycle_end(clk_i);
      cycle_start();
    end
     
    data  = tl_rsp.d_data;
    err   = tl_rsp.d_error;
    cycle_end(clk_i);
       
    tl_req.a_address <= #TA 32'b0;
    tl_req.a_valid   <= #TA 1'b0;
         
  endtask

  
  task write(
    input  logic  clk_i,
    input  [31:0] addr,
    input  [31:0] data,
    output logic  err
  );
          
    tl_req.a_address   <= #TA addr;
    tl_req.a_opcode    <= #TA tlul_pkg::PutFullData;
    tl_req.a_data      <= #TA data;
     
    cycle_end(clk_i);
    tl_req.a_valid <= #TA 1'b1;
    cycle_start();
     
    while (!tl_rsp.a_ready) begin
      cycle_end(clk_i);
      cycle_start();
    end
       
    err = tl_rsp.d_error;
      
    cycle_end(clk_i);
     
    tl_req.a_valid   <= #TA 1'b0;
    tl_req.a_data    <= #TA 32'b0;
    tl_req.a_address <= #TA addr;
   
     
  endtask

endpackage
