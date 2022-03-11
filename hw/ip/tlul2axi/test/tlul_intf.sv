interface tlul_bus;
   import tlul_pkg::*;
   logic clk_i;
   tl_h2d_t tl_req;
   tl_d2h_t tl_rsp;

   modport HOST(           
    output tl_req,
    input  tl_rsp            
   );
   modport DEVICE(
    input  tl_req,            
    output tl_rsp  
   );
   
endinterface
