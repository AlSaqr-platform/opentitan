// Copyright 2023 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "axi/typedef.svh"

package secure_subsystem_synth_astral_pkg;

  localparam SynthAxiAddrWidth    = 48;
  localparam SynthAxiDataWidth    = 64;
  localparam SynthAxiUserWidth    = 10;
  // External AXI master port ID Width
  localparam SynthAxiExtIdWidth   = 2;
  // Security Island internal crossbar AXI ID Widths
  // These are from the AXI XBAR perspective, so:
  // - "out" refers to XBAR master ports (slave devices -> external, PULP cluster slave)
  // - "in" refers to XBAR slave ports (master devices -> TLUL, iDMA, PULP cluster master)
  localparam SynthAxiOutIdWidth   = 8;
  localparam SynthAxiInIdWidth = 6;
  // PULP cluster slave port ID width
  localparam SynthClsAxiIdWidth = 4;
  // Structs for AXI typedefs
  typedef logic [SynthAxiAddrWidth-1:0]   synth_axi_addr_t;
  typedef logic [SynthAxiDataWidth-1:0]   synth_axi_data_t;
  typedef logic [SynthAxiDataWidth/8-1:0] synth_axi_strb_t;
  typedef logic [SynthAxiUserWidth-1:0]   synth_axi_user_t;
  typedef logic [SynthAxiExtIdWidth-1:0]  synth_axi_ext_id_t;
  typedef logic [SynthAxiOutIdWidth-1:0]  synth_axi_out_id_t;
  typedef logic [SynthAxiInIdWidth-1:0]   synth_axi_in_id_t;

  `AXI_TYPEDEF_ALL(synth_axi_ext, synth_axi_addr_t, synth_axi_ext_id_t, synth_axi_data_t, synth_axi_strb_t, synth_axi_user_t)
  `AXI_TYPEDEF_ALL(synth_axi_out, synth_axi_addr_t, synth_axi_out_id_t, synth_axi_data_t, synth_axi_strb_t, synth_axi_user_t)
  `AXI_TYPEDEF_ALL(synth_axi_in, synth_axi_addr_t, synth_axi_in_id_t, synth_axi_data_t, synth_axi_strb_t, synth_axi_user_t)

  localparam SynthLogDepth = 3;
  localparam SynthCdcSyncStages = 3;

  localparam AxiMaxOutTrans = 2;

//`endif
endpackage
