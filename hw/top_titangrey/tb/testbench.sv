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

  top_earlgrey u_RoT (
    .clk_main_i (clk_sys)
 );

endmodule
