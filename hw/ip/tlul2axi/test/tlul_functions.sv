`include "tlul_assign.svh"

package tlul_functions;
  import tlul_pkg::*; 
  class tlul_driver#(
    parameter time         TA         = 0ns,    // application time
    parameter time         TT         = 0ns     // test time
  );
     


    virtual tlul_bus tl_bus;
    semaphore lock;
    logic clk_i;
     

    function new(virtual tlul_bus tlbus, logic clk = 0);
      this.tl_bus = tlbus;
      this.clk_i  = clk; 
      this.lock   = new(1);
    endfunction
   

    function void reset_master();
      
      tl_bus.tl_req.a_valid     <= '0;
      tl_bus.tl_req.a_opcode    <= tlul_pkg::Get;
      tl_bus.tl_req.a_param     <= '0;
      tl_bus.tl_req.a_size      <= '0;
      tl_bus.tl_req.a_source    <= '0;
      tl_bus.tl_req.a_address   <= '0;
      tl_bus.tl_req.a_mask      <= '1;
      tl_bus.tl_req.a_data      <= '0;
      tl_bus.tl_req.a_user      <= '0;
      tl_bus.tl_req.d_ready     <= '1;
      
    endfunction

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

    task cycle_end;
      @(posedge tl_bus.clk_i);
    endtask

    task read(
      input  [31:0]  addr,
      output [31:0]  data,
      output logic   err
    );
      
      while (!lock.try_get()) begin
        cycle_end();
      end
      tl_bus.tl_req.a_address   <= #TA addr;
      tl_bus.tl_req.a_opcode    <= #TA tlul_pkg::Get;
     
      //cycle_end ();
      tl_bus.tl_req.a_valid     <= #TA 1'b1;
      //cycle_start();
     
      @(posedge tl_bus.tl_rsp.d_valid) 
   
      data  = tl_bus.tl_rsp.d_data;
      err   = tl_bus.tl_rsp.d_error;
      tl_bus.tl_req.a_valid   <= #TA 1'b0; 
      cycle_end();


      tl_bus.tl_req.a_address <= #TA 32'b0;

      lock.put();
         
    endtask

  
    task write(
      input [31:0] addr,
      input [31:0] data,
      output logic err
    );

      while (!lock.try_get()) begin
        cycle_end();
      end
      
     // tl_bus.tl_req.a_address   <= #TA addr;
      tl_bus.tl_req.a_opcode    <= #TA tlul_pkg::PutFullData;
     // tl_bus.tl_req.a_data      <= #TA data;  
      tl_bus.tl_req.a_valid     <= #TA 1'b1;
      
      @(posedge tl_bus.tl_rsp.d_valid) 
       
      err = tl_bus.tl_rsp.d_error;
   //   tl_bus.tl_req.a_valid   <= #TA 1'b0;    
      cycle_end();
     

      tl_bus.tl_req.a_data    <= #TA 32'b0;
      tl_bus.tl_req.a_address <= #TA addr;
   
      lock.put();
   
    endtask 

  endclass

endpackage
