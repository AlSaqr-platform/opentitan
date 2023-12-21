// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`include "prim_assert.sv"

module prim_clock_buf #(
  parameter bit NoFpgaBuf = 1'b0, // serves no function in generic
  parameter bit RegionSel = 1'b0  // serves no function in generic
) (
  input clk_i,
  output logic clk_o
);
`ifdef TARGET_ASIC
  tc_clk_buffer clk_buf(
     .clk_i,
     .clk_o
  );
`else
  logic inv;
  assign inv = ~clk_i;
  assign clk_o = ~inv;
`endif
endmodule // prim_clock_buf
