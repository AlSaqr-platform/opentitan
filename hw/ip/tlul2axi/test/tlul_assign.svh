
`ifndef TLUL_ASSIGN_SVH_
`define TLUL_ASSIGN_SVH_

////////////////////////////////////////////////////////////////////////////////////////////////////
// Assign an APB4 interface to another, as if you would do in `assign slv = mst;`.
//
// Usage example:
// `APB_ASSIGN(slv, mst)
`define REQ_ASSIGN(dst, src)         \
  assign dst.a_valid   = src.a_valid ;    \
  assign dst.a_opcode  = src.a_opcode ;    \
  assign dst.a_param   = src.a_param ;     \
  assign dst.a_size    = src.a_size ;  \
  assign dst.a_source  = src.a_source ;   \
  assign dst.a_address = src.a_address ;   \
  assign dst.a_mask    = src.a_mask ;    \
  assign dst.a_data    = src.a_data ;   \
  assign dst.a_user    = src.a_user ;   \
  assign dst.d_ready   = src.d_ready ;
////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////
// Assign an APB4 interface to another, as if you would do in `assign slv = mst;`.
//
// Usage example:
// `APB_ASSIGN(slv, mst)
`define RSP_ASSIGN(dst, src)         \
  assign dst.d_valid   = src.d_valid ;    \
  assign dst.d_opcode  = src.d_opcode ;    \
  assign dst.d_param   = src.d_param ;     \
  assign dst.d_size    = src.d_size ;  \
  assign dst.d_source  = src.d_source ;   \
  assign dst.d_sink    = src.d_sink ;   \
  assign dst.d_data    = src.d_data ;    \
  assign dst.d_user    = src.d_user ;   \
  assign dst.d_error   = src.d_error ;   \
  assign dst.a_ready   = src.a_ready ;
////////////////////////////////////////////////////////////////////////////////////////////////////
      

`endif
