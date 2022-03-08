module testbench ();

   logic clk_sys = 1'b0, rst_sys_n;
   edn_pkg::edn_req_t fake_ast_edn;

   assign fake_ast_edn.edn_ack = '0;
   assign fake_ast_edn.edn_fips = '0;
   assign fake_ast_edn.edn_bus = '0;
   
   
  
  initial begin
     
    rst_sys_n = 1'b0;
    #8
    rst_sys_n = 1'b1;
  
  end

  //lc_ctrl_pkg::lc_tx_t scanmode;
   
    import lc_ctrl_pkg::*;
   
    always begin
      #1 clk_sys = 1'b0;
      #1 clk_sys = 1'b1;
    end
   
    logic [3:0] tieoff_data = 4'b0;
    logic       enable      = 1'b0;
    logic       test_reset;
   
/*  AXI_BUS #(
    .AXI_ADDR_WIDTH ( 64 ),
    .AXI_DATA_WIDTH ( 64 ),
    .AXI_ID_WIDTH   ( 0 ),
    .AXI_USER_WIDTH ( 1 )
  ) slave();
*/
   
  opentitan u_RoT (

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
    .ast_edn_req_i (fake_ast_edn),
    .clk_aon_i(clk_sys)
  );
   

endmodule
