module testbench ();

   logic clk_sys = 1'b0, rst_sys_n;
  
  initial begin
     
    rst_sys_n = 1'b0;
    #8
    rst_sys_n = 1'b1;
  
  end

   
  always begin
    #1 clk_sys = 1'b0;
    #1 clk_sys = 1'b1;
   end

  opentitan u_RoT (
    .clk_sys,
    .rst_sys_n 
);

endmodule
