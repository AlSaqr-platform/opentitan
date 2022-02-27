module testbench ();

   logic clk_sys = 1'b0, rst_sys_n;
  
  initial begin
     
    rst_sys_n = 1'b0;
    #8
    rst_sys_n = 1'b1;
  
  end

  //lc_ctrl_pkg::lc_tx_t scanmode;
   
   
  always begin
    #1 clk_sys = 1'b0;
    #1 clk_sys = 1'b1;
   end

  opentitan u_RoT (
                   
    .scan_rst_ni (rst_sys_n),
    .scan_en_i (1'b1),
    .scanmode_i (lc_ctrl_pkg::On),
                   
    .por_n_i (rst_sys_n),
    .clk_main_i (clk_sys),
    .clk_io_i(clk_sys),
    .clk_usb_i(clk_sys),
    .clk_aon_i(clk_sys) 
);

endmodule
