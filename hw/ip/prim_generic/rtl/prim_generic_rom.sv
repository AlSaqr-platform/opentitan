// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`include "prim_assert.sv"
`define DUMMYBOY

module prim_rom import prim_rom_pkg::*; #(
  parameter  int Width       = 32,
  parameter  int Depth       = 2048, // 8kB default
  parameter      MemInitFile = "", // VMEM file to initialize the memory with
  localparam int Aw          =  $clog2(Depth)
) (
  input  logic             clk_i,
  input  logic             rst_ni,
  input  logic             fake_i,
  input  logic             req_i,
  input  logic [Aw-1:0]    addr_i,
  output logic [Width-1:0] rdata_o,
  input rom_cfg_t          cfg_i
);
   
`ifdef TARGET_XILINX
  xilinx_rom_bank_8192x40 rom_mem_i (
                                    .clk  (clk_i),
                                    .a (addr_i),
                                    .spo (rdata_o)
                                    );
     
  logic  unused; 
  assign unused = ^req_i & ^cfg_i & rst_ni;
`else //  `ifdef TARGET_XILINX   
 secure_boot_rom #(
     .Depth(Depth),
     .Width(Width),
     .Aw(Aw)
  ) u_bootrom (
     .clk_i,
     .rst_ni,
     .req_i,
     .addr_i,
     .rdata_o
  );  

`endif

endmodule
