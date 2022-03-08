
`include "../include/axi/assign.svh"
`include "../include/axi/typedef.svh"

module axi_tlul_adapter      
  import axi_pkg::*;
  import tlul_pkg::*; 
#(
  parameter int unsigned AXI_ADDR_WIDTH = 32,
  parameter int unsigned AXI_DATA_WIDTH = 32,
  parameter int unsigned AXI_ID_WIDTH   = 3,
  parameter int unsigned AXI_USER_WIDTH = 1
) (
  input logic     clk_i,
  input logic     rst_ni,
   
  input  tl_h2d_t tl_req,
  output tl_d2h_t tl_rsp,
   
  AXI_BUS.Master  axi_mst_intf 
);

  localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;
   
  typedef logic [                      1:0] id_mst_t;
  typedef logic [AXI_ADDR_WIDTH       -1:0] addr_t;
  typedef logic [AXI_DATA_WIDTH       -1:0] data_t;
  typedef logic [AXI_STRB_WIDTH       -1:0] strb_t;
  typedef logic [AXI_USER_WIDTH       -1:0] user_t;

  ariane_axi::req_t mst_req;
   
  ariane_axi::resp_t mst_rsp;
   

  `AXI_TYPEDEF_AW_CHAN_T   ( mst_aw_chan_t, addr_t, id_mst_t, user_t           )
  `AXI_TYPEDEF_W_CHAN_T    ( w_chan_t, data_t, strb_t, user_t                  )
  `AXI_TYPEDEF_B_CHAN_T    ( mst_b_chan_t, id_mst_t, user_t                    )
  `AXI_TYPEDEF_AR_CHAN_T   ( mst_ar_chan_t, addr_t, id_mst_t, user_t           )
  `AXI_TYPEDEF_R_CHAN_T    ( mst_r_chan_t, data_t, id_mst_t, user_t            )
   
  `AXI_TYPEDEF_REQ_T       ( mst_req_t, mst_aw_chan_t, w_chan_t, mst_ar_chan_t )
  `AXI_TYPEDEF_RESP_T      ( mst_resp_t, mst_b_chan_t, mst_r_chan_t            )

  mst_req_t   mst_reqs;
  mst_resp_t  mst_resps;
   
  `AXI_ASSIGN_FROM_REQ     ( axi_mst_intf,  mst_req )
  `AXI_ASSIGN_TO_RESP      ( mst_rsp, axi_mst_intf )

  logic        tl_we;
  logic [63:0] rdata;
   
  axi_adapter #(
    .DATA_WIDTH            (  64  ),
    .AXI_ID_WIDTH          (  10  )
  ) u_opentitan_mst (
    .clk_i,
    .rst_ni,
    .req_i                 ( tl_req.a_valid             ),
    .type_i                ( ariane_axi::SINGLE_REQ     ),
    .gnt_o                 ( tl_rsp.a_ready             ),
    .gnt_id_o              (                            ),
    .addr_i                ( { 32'b0, tl_req.a_address} ),
    .we_i                  ( tl_we                      ),
    .wdata_i               ( { 32'b0, tl_req.a_data }   ),
    .be_i                  ( { 4'b0, tl_req.a_mask }    ),
    .size_i                ( 2'b11                      ),
    .id_i                  ( '0                         ),
    .valid_o               ( tl_rsp.d_valid             ),
    .rdata_o               (   rdata                    ),
    .id_o                  (                            ),
    .critical_word_o       (                            ),
    .critical_word_valid_o (                            ),
    .axi_req_o             ( mst_req                   ),
    .axi_resp_i            ( mst_rsp                  )
  );

//////////  dummy assignments

  
   // assign tl_req.a_ready          = 1'b1;
    assign tl_rsp.d_data             = rdata [31:0];
    assign tl_rsp.d_opcode           = tlul_pkg::AccessAckData;
    assign tl_rsp.d_error            = 1'b0;
    assign tl_rsp.d_param            = tl_req.a_param;
    assign tl_rsp.d_size             = tl_req.a_size;
    assign tl_rsp.d_source           = tl_req.a_source;
    assign tl_rsp.d_user             = TL_D_USER_DEFAULT;
    assign tl_rsp.d_sink             = '0;
      
    assign tl_we = ~(tl_req.a_opcode[2] || tl_req.a_opcode[0]);
   
endmodule
/* 
/////////////////////////////  INPUT  ////////////////////////////////// 
  
//TILE LINK REQ tl_h2d_t  IN
//  tl_req.a_valid;
  tl_req.a_opcode;
  tl_req.a_param;
  tl_req.a_size;
  tl_req.a_source;
//  tl_req.a_address;
//  tl_req.a_mask;
//  tl_req.a_data;
  tl_req.a_user;
//  tl_req.d_ready;

   
//WRITE RESPONSE CHANNEL  IN
  axi_int.b_id;
  axi_int.b_resp;
  axi_int.b_user;
  axi_int.b_valid;
  axi_int.b_ready;


//READ CHANNEL            IN
  axi_int.r_id;
  axi_int.r_data;
  axi_int.r_resp;
  axi_int.r_last;
  axi_int.r_user;
  axi_int.r_valid;
  axi_int.r_ready;

/////////////////////////////  OUTPUT  /////////////////////////////////

//TILE LINK RSP tl_d2h_t  OUT
//  tl_rsp.d_valid;
  tl_rsp.d_opcode;
  tl_rsp.d_param;
  tl_rsp.d_size;
  tl_rsp.d_source;
  tl_rsp.d_sink;
//  tl_rsp.d_data;
  tl_rsp.d_user;
  tl_rsp.d_error;
  tl_rsp.a_ready;

// ADDRESS WRITE CHANNEL  OUT
  axi_int.faw_id;
  axi_int.faw_addr;
  axi_int.aw_len;
  axi_int.aw_size;
  axi_int.aw_burst;
  axi_int.aw_lock;
  axi_int.aw_cache;
  axi_int.aw_prot;
  axi_int.aw_qos;
  axi_int.aw_region;
  axi_int.aw_atop;
  axi_int.aw_user;
  axi_int.aw_valid; 
  axi_int.aw_ready;

//WRITE CHANNEL           OUT
  axi_int.w_data;
  axi_int.w_strb;
  axi_int.w_last;
  axi_int.w_user;
  axi_int.w_valid; 
  axi_int.w_ready;

//ADDRESS READ CHANNEL    OUT
  axi_int.ar_id;
  axi_int.ar_addr;
  axi_int.ar_len;
  axi_int.ar_size;
  axi_int.ar_burst;
  axi_int.ar_lock;
  axi_int.ar_cache;
  axi_int.ar_prot;
  axi_int.ar_qos;
  axi_int.ar_region;
  axi_int.ar_user;
  axi_int.ar_valid;
  axi_int.ar_ready; 
 
 
  localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;

  typedef logic [AXI_ID_WIDTH-1:0  ] id_t;
 // typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0] data_t;
  typedef logic [AXI_STRB_WIDTH-1:0] strb_t;
 // typedef logic [AXI_USER_WIDTH-1:0] user_t;
  `AXI_TYPEDEF_AW_CHAN_T(mst_aw_chan_t, addr_t, id_mst_t, user_t);
*/
