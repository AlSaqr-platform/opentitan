module adapter_testbench #();

   localparam time TA   = 1ns;
   localparam time TT   = 2ns;
   
   localparam [31:0] BaseAddr      = 32'h1A10_0000;
   localparam [31:0] TestStartAddr = 32'h1A10_0000;
   localparam [31:0] TestEndAddr   = 32'h1A10_0030;
   
   localparam int unsigned RTC_CLOCK_PERIOD = 30.517us;

   logic rst_ni;
   logic clk_i;

   semaphore lock;
  //
   
   import tlul_pkg::*;
   import tlul_tasks::*;
   

   tl_h2d_t tl_req;
   tl_d2h_t tl_rsp;
   
   logic [31:0] mst_wdata;
   logic [31:0] mst_addr;
   logic        mst_req;
   logic        mst_we;
   logic [3:0]  mst_be;
   
   logic [31:0] mst_rdata;
   logic        mst_rvalid;
   
   //typedef tlul_test::tlul_driver #( .TT(TT), .TA(TA)) tlul_driver_t;
                                     
   //tlul_test::tlul_driver #( .TT(TT), .TA(TA)) tlul_master = new( clk_i);
   
   task cycle_start;
     #TT;
   endtask

   task cycle_end;
     @(posedge clk_i);
   endtask
   
   AXI_BUS #(
    .AXI_ADDR_WIDTH ( 32 ),
    .AXI_DATA_WIDTH ( 32 ),
    .AXI_ID_WIDTH   ( 3 ),
    .AXI_USER_WIDTH ( 1 )
   ) axi_slave();

   axi_tlul_adapter tlul_adapter (
     .clk_i,
     .rst_ni,
     .tl_req(tl_req),
     .tl_rsp(tl_rsp),
     .axi_mst_intf(axi_slave)
   );
   
   axi2mem #(
    .AXI_ID_WIDTH   ( 3 ),
    .AXI_ADDR_WIDTH ( 32 ),
    .AXI_DATA_WIDTH ( 32 ),
    .AXI_USER_WIDTH ( 1 )
   ) axi2mem (
    .clk_i      ( clk_i                ),
    .rst_ni     ( rst_ni               ),
    .slave      ( axi_slave            ),
    .req_o      ( mst_req              ),
    .we_o       ( mst_we               ),
    .addr_o     ( mst_addr             ),
    .be_o       ( mst_be               ),
    .data_o     ( mst_wdata            ),
    .data_i     ( mst_rdata            )
   );
   
   
      
   ram_2p #(
      .Depth(1024*1024/4)
   ) u_ram (
      .clk_i       (clk_i),
      .rst_ni      (rst_ni),

      .a_req_i     (mst_req),
      .a_we_i      (mst_we),
      .a_be_i      (mst_be),
      .a_addr_i    (mst_addr),
      .a_wdata_i   (mst_wdata),
      .a_rvalid_o  (mst_rvalid),
      .a_rdata_o   (mst_rdata)
   );
     
   initial begin
        lock = new(1);
        clk_i  = 1'b0;
        rst_ni = 1'b0;
        repeat (10)
            #(RTC_CLOCK_PERIOD/2) clk_i = 1'b0;
        rst_ni = 1'b1;
        forever
            #(RTC_CLOCK_PERIOD/2) clk_i = ~clk_i;
   end

   initial begin : proc_apb_master
      
     automatic logic [31:0] addr;
     automatic logic [31:0] wdata;
     automatic logic [31:0] rdata; 
     automatic logic        err;
    
     @(posedge rst_ni);
      
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
      
     repeat (3) @(posedge clk_i);
     

      
//////////////////////// WRITE ////////////////////////////

     addr  = 32'h1A100010;
     wdata = 32'h0025C350;
      
     tl_req.a_address   <= #TA addr;
     tl_req.a_opcode    <= #TA tlul_pkg::PutFullData;
     tl_req.a_data      <= #TA wdata;
       
     cycle_end();
     tl_req.a_valid     <= #TA 1'b1;
     cycle_start();
       
     while (!tl_rsp.a_ready) begin
       cycle_end();
       cycle_start();
     end
       
     err = tl_rsp.d_error;
      
     cycle_end();
       
     tl_req.a_valid     <= #TA 1'b0;
     tl_req.a_data      <= #TA 32'b0;
     tl_req.a_address   <= #TA 32'b0;

     $display("Write to addr: %0h. Data: %0h.", addr,  wdata);
     repeat ($urandom_range(10,15)) @(posedge clk_i);
      
////////////////////////// READ ///////////////////////////   
      
     tl_req.a_address   <= #TA addr;
     tl_req.a_opcode    <= #TA tlul_pkg::Get;
      
     cycle_end();
     tl_req.a_valid     <= #TA 1'b1;
     cycle_start();
      
     while (!tl_rsp.a_ready) begin
       cycle_end();
       cycle_start();
     end
      
     err   =  tl_rsp.d_error;
     rdata =  tl_rsp.d_data;
     
     cycle_end();
      
     tl_req.a_address <= #TA 32'b0;
     tl_req.a_valid   <= #TA 1'b0;
    
      
     if(tl_rsp.d_data == wdata) 
        $display("Succeed");
     else
        $display("Fail");
      
     repeat  ($urandom_range(10,15)) @(posedge clk_i);
      
     $finish;
      
   end 
   
endmodule












 ////////////////////// TASK DEFS ///////////////////////////
  /* task reset_master(input tl_h2d_t tl_req);
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

  /*task cycle_start;
    #TT;
  endtask

  task cycle_end;
    @(posedge clk_i);
  endtask*/
/*
  task read(
    input  logic   clk_i,
    input  [31:0]  addr,
    output [31:0]  data,
    output logic   err
  );
        
    tl_req.a_address   <= #TA addr;
    tl_req.a_opcode    <= #TA tlul_pkg::Get;
     
    cycle_end();
    tl_req.a_valid     <= #TA 1'b1;
    cycle_start();
     
    while (!tl_rsp.a_ready) begin
      cycle_end();
      cycle_start();
    end
     
    data  = tl_rsp.d_data;
    err   = tl_rsp.d_error;
    cycle_end();
       
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
     
    cycle_end();
    tl_req.a_valid <= #TA 1'b1;
    cycle_start();
     
    while (!tl_rsp.a_ready) begin
      cycle_end();
      cycle_start();
    end
       
    err = tl_rsp.d_error;
      
    cycle_end();
     
    tl_req.a_valid   <= #TA 1'b0;
    tl_req.a_data    <= #TA 32'b0;
    tl_req.a_address <= #TA addr;
   
     
  endtask

endmodule
 /* initial begin : proc_apb_master

     
     automatic logic [31:0]  addr;
     automatic logic [31:0]  rdata;  
     automatic logic         wdata;
     automatic logic         err;

     @(posedge rst_ni);
      
     tl_req.a_valid     <= '0;
     tl_req.a_opcode    <= tlul_pkg::Get;
     tl_req.a_param     <= '0;
     tl_req.a_size      <= '0;
     tl_req.a_source    <= '0;
     tl_req.a_address   <= '0;
     tl_req.a_mask      <= '0;
     tl_req.a_data      <= '0;
     tl_req.a_user      <= '0;
     tl_req.d_ready     <= '0;
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
      
     @(posedge clk_i);
    
      

     tl_req.a_address   <= #TA  32'h00000010;
     tl_req.a_opcode    <= #TA  tlul_pkg::PutFullData;
     tl_req.a_data      <= #TA  32'h25C350;
      
     cycle_end();
      
     tl_req.a_valid     <= #TA  1'b1;
      
     cycle_start();
      
     while (!tl_rsp.a_ready) begin
       cycle_end();
       cycle_start();
     end
     
      
     $display("Write to addr: %0h. Data: %0h", tl_req.a_address, tl_req.a_data );
      
     cycle_end();
      
     
     tl_req.a_valid   <=  #TA 1'b0;
     tl_req.a_data    <=  #TA 32'b0;
     tl_req.a_address <=  #TA 32'b0;
     
     cycle_end();
      
    
     tl_req.a_address   <=  #TA 32'h0000010;
     tl_req.a_opcode    <=  #TA tlul_pkg::Get;
      
     cycle_end();
      
       
     tl_req.a_valid <=  #TA 1'b1;

     
     cycle_start();
      
     while (!tl_rsp.a_ready) begin
       cycle_end();
       cycle_start();
     end  
    
      
      
     $display("Read to addr: %0h. Data: %0h", tl_req.a_address, tl_rsp.d_data );
      
     cycle_end();
      
     
     tl_req.a_valid   <=  #TA 1'b0;
     tl_req.a_data    <=  #TA 32'b0;
     tl_req.a_address <=  #TA 32'b0;

     $finish;
      

   end*/
