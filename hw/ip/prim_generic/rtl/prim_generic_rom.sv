// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`include "prim_assert.sv"
`define FPGA_EMUL

module prim_generic_rom import prim_rom_pkg::*; #(
  parameter  int Width       = 32,
  parameter  int Depth       = 2048, // 8kB default
  parameter      MemInitFile = "", // VMEM file to initialize the memory with

  localparam int Aw          =  $clog2(Depth)
) (
  input  logic             clk_i,
  input  logic             req_i,
  input  logic [Aw-1:0]    addr_i,
  output logic [Width-1:0] rdata_o,
  input rom_cfg_t          cfg_i
);
`ifndef FPGA_EMUL
  logic unused_cfg;
  assign unused_cfg = ^cfg_i;

  logic [Width-1:0] mem [Depth];

  always_ff @(posedge clk_i) begin
    rdata_o <= '0;
    if (req_i) begin
      rdata_o <= mem[addr_i];
    end
  end

  initial begin

     for(int i=0; i< Depth; i++) begin

        mem[i] = '0;
        
     end
     
  end

  `include "prim_util_memload.svh"

  ////////////////
  // ASSERTIONS //
  ////////////////

  // Control Signals should never be X
  `ASSERT(noXOnCsI, !$isunknown(req_i), clk_i, '0)

`else
  logic unused; 
  assign rdata_o = '0;
  assign unused = ^{clk_i, addr_i, req_i, cfg_i}; 
`endif // !`ifndef FPGA_EMUL
   
endmodule
