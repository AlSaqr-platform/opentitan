// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`


`include "common_cells/assertions.svh"

module scmi_reg_top #(
    parameter type reg_req_t = logic,
    parameter type reg_rsp_t = logic,
    parameter int AW = 5
) (
  input clk_i,
  input rst_ni,
  input  reg_req_t reg_req_i,
  output reg_rsp_t reg_rsp_o,
  // To HW
  output scmi_reg_pkg::scmi_reg2hw_t reg2hw, // Write


  // Config
  input devmode_i // If 1, explicit error return for unmapped register access
);

  import scmi_reg_pkg::* ;

  localparam int DW = 32;
  localparam int DBW = DW/8;                    // Byte Width

  // register signals
  logic           reg_we;
  logic           reg_re;
  logic [AW-1:0]  reg_addr;
  logic [DW-1:0]  reg_wdata;
  logic [DBW-1:0] reg_be;
  logic [DW-1:0]  reg_rdata;
  logic           reg_error;

  logic          addrmiss, wr_err;

  logic [DW-1:0] reg_rdata_next;

  // Below register interface can be changed
  reg_req_t  reg_intf_req;
  reg_rsp_t  reg_intf_rsp;


  assign reg_intf_req = reg_req_i;
  assign reg_rsp_o = reg_intf_rsp;


  assign reg_we = reg_intf_req.valid & reg_intf_req.write;
  assign reg_re = reg_intf_req.valid & ~reg_intf_req.write;
  assign reg_addr = reg_intf_req.addr;
  assign reg_wdata = reg_intf_req.wdata;
  assign reg_be = reg_intf_req.wstrb;
  assign reg_intf_rsp.rdata = reg_rdata;
  assign reg_intf_rsp.error = reg_error;
  assign reg_intf_rsp.ready = 1'b1;

  assign reg_rdata = reg_rdata_next ;
  assign reg_error = (devmode_i & addrmiss) | wr_err;


  // Define SW related signals
  // Format: <reg>_<field>_{wd|we|qs}
  //        or <reg>_{wd|we|qs} if field == 1 or 0
  logic [31:0] reserved_qs;
  logic [31:0] reserved_wd;
  logic reserved_we;
  logic channel_status_channel_free_qs;
  logic channel_status_channel_free_wd;
  logic channel_status_channel_free_we;
  logic channel_status_channel_error_qs;
  logic channel_status_channel_error_wd;
  logic channel_status_channel_error_we;
  logic [29:0] channel_status_reserved_qs;
  logic [29:0] channel_status_reserved_wd;
  logic channel_status_reserved_we;
  logic [31:0] reserved_impl_defined_qs;
  logic [31:0] reserved_impl_defined_wd;
  logic reserved_impl_defined_we;
  logic channel_flags_intr_enable_qs;
  logic channel_flags_intr_enable_wd;
  logic channel_flags_intr_enable_we;
  logic [30:0] channel_flags_reserved_qs;
  logic [30:0] channel_flags_reserved_wd;
  logic channel_flags_reserved_we;
  logic [31:0] length_qs;
  logic [31:0] length_wd;
  logic length_we;
  logic [7:0] message_header_message_id_qs;
  logic [7:0] message_header_message_id_wd;
  logic message_header_message_id_we;
  logic [1:0] message_header_message_type_qs;
  logic [1:0] message_header_message_type_wd;
  logic message_header_message_type_we;
  logic [7:0] message_header_protocol_id_qs;
  logic [7:0] message_header_protocol_id_wd;
  logic message_header_protocol_id_we;
  logic [9:0] message_header_token_qs;
  logic [9:0] message_header_token_wd;
  logic message_header_token_we;
  logic [3:0] message_header_reserved_qs;
  logic [3:0] message_header_reserved_wd;
  logic message_header_reserved_we;
  logic [31:0] message_payload_qs;
  logic [31:0] message_payload_wd;
  logic message_payload_we;

  // Register instances
  // R[reserved]: V(False)

  prim_subreg_scmi #(
    .DW      (32),
    .SWACCESS("RW"),
    .RESVAL  (32'h0)
  ) u_reserved (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (reserved_we),
    .wd     (reserved_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (reserved_qs)
  );


  // R[channel_status]: V(False)

  //   F[channel_free]: 0:0
  prim_subreg_scmi #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_channel_status_channel_free (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (channel_status_channel_free_we),
    .wd     (channel_status_channel_free_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.channel_status.channel_free.q ),

    // to register interface (read)
    .qs     (channel_status_channel_free_qs)
  );


  //   F[channel_error]: 1:1
  prim_subreg_scmi #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_channel_status_channel_error (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (channel_status_channel_error_we),
    .wd     (channel_status_channel_error_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.channel_status.channel_error.q ),

    // to register interface (read)
    .qs     (channel_status_channel_error_qs)
  );


  //   F[reserved]: 31:2
  prim_subreg_scmi #(
    .DW      (30),
    .SWACCESS("RW"),
    .RESVAL  (30'h0)
  ) u_channel_status_reserved (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (channel_status_reserved_we),
    .wd     (channel_status_reserved_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.channel_status.reserved.q ),

    // to register interface (read)
    .qs     (channel_status_reserved_qs)
  );


  // R[reserved_impl_defined]: V(False)

  prim_subreg_scmi #(
    .DW      (32),
    .SWACCESS("RW"),
    .RESVAL  (32'h0)
  ) u_reserved_impl_defined (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (reserved_impl_defined_we),
    .wd     (reserved_impl_defined_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (reserved_impl_defined_qs)
  );


  // R[channel_flags]: V(False)

  //   F[intr_enable]: 0:0
  prim_subreg_scmi #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_channel_flags_intr_enable (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (channel_flags_intr_enable_we),
    .wd     (channel_flags_intr_enable_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (channel_flags_intr_enable_qs)
  );


  //   F[reserved]: 31:1
  prim_subreg_scmi #(
    .DW      (31),
    .SWACCESS("RW"),
    .RESVAL  (31'h0)
  ) u_channel_flags_reserved (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (channel_flags_reserved_we),
    .wd     (channel_flags_reserved_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (channel_flags_reserved_qs)
  );


  // R[length]: V(False)

  prim_subreg_scmi #(
    .DW      (32),
    .SWACCESS("RW"),
    .RESVAL  (32'h0)
  ) u_length (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (length_we),
    .wd     (length_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (length_qs)
  );


  // R[message_header]: V(False)

  //   F[message_id]: 7:0
  prim_subreg_scmi #(
    .DW      (8),
    .SWACCESS("RW"),
    .RESVAL  (8'h0)
  ) u_message_header_message_id (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (message_header_message_id_we),
    .wd     (message_header_message_id_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (message_header_message_id_qs)
  );


  //   F[message_type]: 9:8
  prim_subreg_scmi #(
    .DW      (2),
    .SWACCESS("RW"),
    .RESVAL  (2'h0)
  ) u_message_header_message_type (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (message_header_message_type_we),
    .wd     (message_header_message_type_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (message_header_message_type_qs)
  );


  //   F[protocol_id]: 17:10
  prim_subreg_scmi #(
    .DW      (8),
    .SWACCESS("RW"),
    .RESVAL  (8'h0)
  ) u_message_header_protocol_id (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (message_header_protocol_id_we),
    .wd     (message_header_protocol_id_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (message_header_protocol_id_qs)
  );


  //   F[token]: 27:18
  prim_subreg_scmi #(
    .DW      (10),
    .SWACCESS("RW"),
    .RESVAL  (10'h0)
  ) u_message_header_token (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (message_header_token_we),
    .wd     (message_header_token_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (message_header_token_qs)
  );


  //   F[reserved]: 31:28
  prim_subreg_scmi #(
    .DW      (4),
    .SWACCESS("RW"),
    .RESVAL  (4'h0)
  ) u_message_header_reserved (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (message_header_reserved_we),
    .wd     (message_header_reserved_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (message_header_reserved_qs)
  );


  // R[message_payload]: V(False)

  prim_subreg_scmi #(
    .DW      (32),
    .SWACCESS("RW"),
    .RESVAL  (32'h0)
  ) u_message_payload (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (message_payload_we),
    .wd     (message_payload_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (message_payload_qs)
  );




  logic [6:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[0] = (reg_addr[4:0] == SCMI_RESERVED_OFFSET);
    addr_hit[1] = (reg_addr[4:0] == SCMI_CHANNEL_STATUS_OFFSET);
    addr_hit[2] = (reg_addr[4:0] == SCMI_RESERVED_IMPL_DEFINED_OFFSET);
    addr_hit[3] = (reg_addr[4:0] == SCMI_CHANNEL_FLAGS_OFFSET);
    addr_hit[4] = (reg_addr[4:0] == SCMI_LENGTH_OFFSET);
    addr_hit[5] = (reg_addr[4:0] == SCMI_MESSAGE_HEADER_OFFSET);
    addr_hit[6] = (reg_addr[4:0] == SCMI_MESSAGE_PAYLOAD_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0 ;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[0] & (|(SCMI_PERMIT[0] & ~reg_be))) |
               (addr_hit[1] & (|(SCMI_PERMIT[1] & ~reg_be))) |
               (addr_hit[2] & (|(SCMI_PERMIT[2] & ~reg_be))) |
               (addr_hit[3] & (|(SCMI_PERMIT[3] & ~reg_be))) |
               (addr_hit[4] & (|(SCMI_PERMIT[4] & ~reg_be))) |
               (addr_hit[5] & (|(SCMI_PERMIT[5] & ~reg_be))) |
               (addr_hit[6] & (|(SCMI_PERMIT[6] & ~reg_be)))));
  end

  assign reserved_we = addr_hit[0] & reg_we & !reg_error;
  assign reserved_wd = reg_wdata[31:0];

  assign channel_status_channel_free_we = addr_hit[1] & reg_we & !reg_error;
  assign channel_status_channel_free_wd = reg_wdata[0];

  assign channel_status_channel_error_we = addr_hit[1] & reg_we & !reg_error;
  assign channel_status_channel_error_wd = reg_wdata[1];

  assign channel_status_reserved_we = addr_hit[1] & reg_we & !reg_error;
  assign channel_status_reserved_wd = reg_wdata[31:2];

  assign reserved_impl_defined_we = addr_hit[2] & reg_we & !reg_error;
  assign reserved_impl_defined_wd = reg_wdata[31:0];

  assign channel_flags_intr_enable_we = addr_hit[3] & reg_we & !reg_error;
  assign channel_flags_intr_enable_wd = reg_wdata[0];

  assign channel_flags_reserved_we = addr_hit[3] & reg_we & !reg_error;
  assign channel_flags_reserved_wd = reg_wdata[31:1];

  assign length_we = addr_hit[4] & reg_we & !reg_error;
  assign length_wd = reg_wdata[31:0];

  assign message_header_message_id_we = addr_hit[5] & reg_we & !reg_error;
  assign message_header_message_id_wd = reg_wdata[7:0];

  assign message_header_message_type_we = addr_hit[5] & reg_we & !reg_error;
  assign message_header_message_type_wd = reg_wdata[9:8];

  assign message_header_protocol_id_we = addr_hit[5] & reg_we & !reg_error;
  assign message_header_protocol_id_wd = reg_wdata[17:10];

  assign message_header_token_we = addr_hit[5] & reg_we & !reg_error;
  assign message_header_token_wd = reg_wdata[27:18];

  assign message_header_reserved_we = addr_hit[5] & reg_we & !reg_error;
  assign message_header_reserved_wd = reg_wdata[31:28];

  assign message_payload_we = addr_hit[6] & reg_we & !reg_error;
  assign message_payload_wd = reg_wdata[31:0];

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[31:0] = reserved_qs;
      end

      addr_hit[1]: begin
        reg_rdata_next[0] = channel_status_channel_free_qs;
        reg_rdata_next[1] = channel_status_channel_error_qs;
        reg_rdata_next[31:2] = channel_status_reserved_qs;
      end

      addr_hit[2]: begin
        reg_rdata_next[31:0] = reserved_impl_defined_qs;
      end

      addr_hit[3]: begin
        reg_rdata_next[0] = channel_flags_intr_enable_qs;
        reg_rdata_next[31:1] = channel_flags_reserved_qs;
      end

      addr_hit[4]: begin
        reg_rdata_next[31:0] = length_qs;
      end

      addr_hit[5]: begin
        reg_rdata_next[7:0] = message_header_message_id_qs;
        reg_rdata_next[9:8] = message_header_message_type_qs;
        reg_rdata_next[17:10] = message_header_protocol_id_qs;
        reg_rdata_next[27:18] = message_header_token_qs;
        reg_rdata_next[31:28] = message_header_reserved_qs;
      end

      addr_hit[6]: begin
        reg_rdata_next[31:0] = message_payload_qs;
      end

      default: begin
        reg_rdata_next = '1;
      end
    endcase
  end

  // Unused signal tieoff

  // wdata / byte enable are not always fully used
  // add a blanket unused statement to handle lint waivers
  logic unused_wdata;
  logic unused_be;
  assign unused_wdata = ^reg_wdata;
  assign unused_be = ^reg_be;

  // Assertions for Register Interface
  `ASSERT(en2addrHit, (reg_we || reg_re) |-> $onehot0(addr_hit))

endmodule
