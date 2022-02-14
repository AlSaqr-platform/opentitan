set ROOT [file normalize [file dirname [info script]]/..]
# This script was generated automatically by bender.

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/prim/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/prim/../prim_generic/rtl" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_clock_mux2.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_clock_inv.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_clock_buf.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_alert_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_ram_2p_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_esc_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_rom_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_util_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_otp_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_cipher_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_subreg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_ram_1p_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_pad_wrapper_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_count_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_buf.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_flop.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_flop_en.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/../prim_generic/rtl/prim_generic_flop.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/../prim_generic/rtl/prim_generic_rom.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/../prim_generic/rtl/prim_generic_ram_1p.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/../entropy_src/rtl/entropy_src_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/../lc_ctrl/rtl/lc_ctrl_state_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/../lc_ctrl/rtl/lc_ctrl_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/../edn/rtl/edn_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_multibit_sync.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_22_16_dec.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_slicer.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_alert_receiver.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_esc_receiver.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_22_16_enc.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_sram_arbiter.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_alert_sender.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_esc_sender.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_packer_fifo.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_28_22_dec.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_subreg_arb.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_arbiter_fixed.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_fifo_async_sram_adapter.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_packer.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_28_22_enc.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_subreg_async.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_arbiter_ppc.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_fifo_async.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_39_32_dec.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_subreg_cdc.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_arbiter_tree.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_fifo_sync.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_present.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_39_32_enc.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_subreg_ext_async.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_filter_ctr.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_prince.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_64_57_dec.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_subreg_ext.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_filter.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_pulse_sync.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_64_57_enc.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_gate_gen.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_ram_1p_adv.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_72_64_dec.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_subreg_shadow.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_gf_mult.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_72_64_enc.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_subreg.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_count.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_intr_hw.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_ram_1p_scr.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_hamming_22_16_dec.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_subst_perm.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_clock_div.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_keccak.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_ram_2p_adv.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_hamming_22_16_enc.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_sync_reqack_data.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_clock_gating_sync.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_lc_dec.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_ram_2p_async_adv.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_hamming_39_32_dec.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_sync_reqack.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_diff_decode.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_lc_sender.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_hamming_39_32_enc.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_sync_slow_fast.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_dom_and_2share.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_lc_sync.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_reg_cdc.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_hamming_72_64_dec.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_edge_detector.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_lfsr.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_rom_adv.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_secded_hamming_72_64_enc.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_edn_req.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_msb_extend.sv" \
    "/scratch/ciani/opentitan/hw/ip/prim/rtl/prim_ram_2p.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/common_verification-5b1967f713b85158/src/clk_rst_gen.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-5b1967f713b85158/src/rand_id_queue.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-5b1967f713b85158/src/rand_stream_mst.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-5b1967f713b85158/src/rand_synch_holdable_driver.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-5b1967f713b85158/src/rand_verif_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-5b1967f713b85158/src/sim_timeout.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-5b1967f713b85158/src/rand_synch_driver.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-5b1967f713b85158/src/rand_stream_slv.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/common_verification-5b1967f713b85158/test/tb_clk_rst_gen.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/tlul/../prim/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/tlul/../../top_earlgrey/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/tlul/rtl" \
    "/scratch/ciani/opentitan/hw/ip/tlul/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/../../top_earlgrey/rtl/top_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_cmd_intg_chk.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_data_integ_enc.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_rsp_intg_chk.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_cmd_intg_gen.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_rsp_intg_gen.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_data_integ_dec.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_adapter_host.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_adapter_reg.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_assert_multiple.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_err.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_err_resp.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_sram_byte.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/sram2tlul.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_socket_1n.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_socket_m1.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_fifo_sync.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_fifo_async.sv" \
    "/scratch/ciani/opentitan/hw/ip/tlul/rtl/tlul_adapter_sram.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/otp_ctrl/../tlul/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/otp_ctrl/../pwrmgr/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/otp_ctrl/../prim/rtl" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/../pwrmgr/rtl/pwrmgr_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/../../top_earlgrey/ip/ast/rtl/ast_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl/otp_ctrl_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl/otp_ctrl_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl/otp_ctrl_part_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl/otp_ctrl_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/../prim_generic/rtl/prim_generic_otp.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl/otp_ctrl_core_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl/otp_ctrl_dai.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl/otp_ctrl_ecc_reg.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl/otp_ctrl_kdi.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl/otp_ctrl_lci.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl/otp_ctrl_lfsr_timer.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl/otp_ctrl_part_buf.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl/otp_ctrl_part_unbuf.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl/otp_ctrl_prim_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl/otp_ctrl_scrmbl.sv" \
    "/scratch/ciani/opentitan/hw/ip/otp_ctrl/rtl/otp_ctrl.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-54a62622015b51f7/src/rtl/tc_sram.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-54a62622015b51f7/src/rtl/tc_clk.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-54a62622015b51f7/src/deprecated/cluster_pwr_cells.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-54a62622015b51f7/src/deprecated/generic_memory.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-54a62622015b51f7/src/deprecated/generic_rom.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-54a62622015b51f7/src/deprecated/pad_functional.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-54a62622015b51f7/src/deprecated/pulp_buffer.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-54a62622015b51f7/src/deprecated/pulp_pwr_cells.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-54a62622015b51f7/src/tc_pwr.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-54a62622015b51f7/test/tb_tc_sram.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-54a62622015b51f7/src/deprecated/pulp_clock_gating_async.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-54a62622015b51f7/src/deprecated/cluster_clk_cells.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-54a62622015b51f7/src/deprecated/pulp_clk_cells.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/../../dv/sv/dv_utils/" \
    "+incdir+/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/../../ip/prim/rtl" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_pkg.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_register_file_ff.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/../../ip/prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/../../ip/prim/rtl/prim_clock_gating.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_alu.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_compressed_decoder.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_controller.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_counter.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_csr.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_decoder.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_fetch_fifo.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_load_store_unit.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_multdiv_fast.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_multdiv_slow.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_pmp.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_tracer_pkg.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_wb_stage.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_cs_registers.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_ex_block.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_id_stage.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_prefetch_buffer.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_tracer.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_if_stage.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_core.sv" \
    "/scratch/ciani/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_top.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/kmac/../prim/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/kmac/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/kmac/../keymgr/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/kmac/../tlul/rtl" \
    "/scratch/ciani/opentitan/hw/ip/kmac/rtl/sha3_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/rtl/kmac_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/rtl/kmac_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/../keymgr/rtl/keymgr_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/../keymgr/rtl/keymgr_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/rtl/keccak_2share.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/rtl/keccak_round.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/rtl/kmac.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/rtl/kmac_app.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/rtl/kmac_core.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/rtl/kmac_entropy.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/rtl/kmac_errchk.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/rtl/kmac_msgfifo.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/rtl/kmac_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/rtl/kmac_staterd.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/rtl/sha3.sv" \
    "/scratch/ciani/opentitan/hw/ip/kmac/rtl/sha3pad.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/lc_ctrl/../prim_generic/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/lc_ctrl/../../vendor/pulp_riscv_dbg/src/" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/lc_ctrl/../alert_handler/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/lc_ctrl/../prim/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/lc_ctrl/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/lc_ctrl/../tlul/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/lc_ctrl/../pwrmgr/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/lc_ctrl/../rv_dm/rtl" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/../../vendor/pulp_riscv_dbg/src/dm_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/../../vendor/pulp_riscv_dbg/src/dmi_jtag.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/../../vendor/pulp_riscv_dbg/src/dmi_jtag_tap.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/../../vendor/pulp_riscv_dbg/src/dmi_cdc.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/../rv_dm/rtl/jtag_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/../prim_generic/rtl/prim_generic_clock_inv.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/../pwrmgr/rtl/pwrmgr_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/../prim_generic/rtl/prim_generic_clock_mux2.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/../alert_handler/rtl/alert_handler_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/rtl/lc_ctrl_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/rtl/lc_ctrl_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/rtl/lc_ctrl_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/rtl/lc_ctrl_fsm.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/rtl/lc_ctrl_kmac_if.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/rtl/lc_ctrl_signal_decode.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/rtl/lc_ctrl_state_decode.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/rtl/lc_ctrl_state_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/rtl/lc_ctrl_state_transition.sv" \
    "/scratch/ciani/opentitan/hw/ip/lc_ctrl/rtl/lc_ctrl.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rom_ctrl/../kmac/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rom_ctrl/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rom_ctrl/../tlul/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rom_ctrl/../prim/rtl" \
    "/scratch/ciani/opentitan/hw/ip/rom_ctrl/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/rom_ctrl/../kmac/rtl/sha3_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rom_ctrl/rtl/rom_ctrl_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rom_ctrl/../kmac/rtl/kmac_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rom_ctrl/rtl/rom_ctrl_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rom_ctrl/rtl/rom_ctrl.sv" \
    "/scratch/ciani/opentitan/hw/ip/rom_ctrl/rtl/rom_ctrl_compare.sv" \
    "/scratch/ciani/opentitan/hw/ip/rom_ctrl/rtl/rom_ctrl_counter.sv" \
    "/scratch/ciani/opentitan/hw/ip/rom_ctrl/rtl/rom_ctrl_mux.sv" \
    "/scratch/ciani/opentitan/hw/ip/rom_ctrl/rtl/rom_ctrl_regs_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/rom_ctrl/rtl/rom_ctrl_rom_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/rom_ctrl/rtl/rom_ctrl_fsm.sv" \
    "/scratch/ciani/opentitan/hw/ip/rom_ctrl/rtl/rom_ctrl_scrambled_rom.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/sram_ctrl/../tlul/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/sram_ctrl/../prim/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/sram_ctrl/rtl" \
    "/scratch/ciani/opentitan/hw/ip/sram_ctrl/rtl/sram_ctrl_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/sram_ctrl/rtl/sram_ctrl_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/sram_ctrl/rtl/sram_ctrl_regs_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/sram_ctrl/rtl/sram_ctrl.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/aes/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/aes/../prim/rtl/" \
    "/scratch/ciani/opentitan/hw/ip/aes/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_sbox_canright_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_reg_status.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_cipher_control.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_cipher_core.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_control.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_ctr.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_ctrl_reg_shadowed.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_key_expand.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_mix_columns.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_mix_single_column.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_prng_clearing.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_prng_masking.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_sbox.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_sbox_canright.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_sbox_canright_masked.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_sbox_canright_masked_noreuse.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_sbox_dom.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_sbox_lut.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_sel_buf_chk.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_shift_rows.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_sub_bytes.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes_core.sv" \
    "/scratch/ciani/opentitan/hw/ip/aes/rtl/aes.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/alert_handler/../tlul/rt" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/alert_handler/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/alert_handler/../prim/rtl" \
    "/scratch/ciani/opentitan/hw/ip/alert_handler/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/alert_handler/rtl/alert_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/alert_handler/rtl/alert_handler_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/alert_handler/rtl/alert_handler_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/alert_handler/rtl/alert_handler_accu.sv" \
    "/scratch/ciani/opentitan/hw/ip/alert_handler/rtl/alert_handler_class.sv" \
    "/scratch/ciani/opentitan/hw/ip/alert_handler/rtl/alert_handler_esc_timer.sv" \
    "/scratch/ciani/opentitan/hw/ip/alert_handler/rtl/alert_handler_ping_timer.sv" \
    "/scratch/ciani/opentitan/hw/ip/alert_handler/rtl/alert_handler_reg_wrap.sv" \
    "/scratch/ciani/opentitan/hw/ip/alert_handler/rtl/alert_handler.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/clkmgr/../prim/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/clkmgr/../tlul/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/clkmgr/../pwrmgr/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/clkmgr/rtl" \
    "/scratch/ciani/opentitan/hw/ip/clkmgr/../pwrmgr/rtl/pwrmgr_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/clkmgr/rtl/clkmgr_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/clkmgr/rtl/clkmgr_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/clkmgr/rtl/clkmgr_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/clkmgr/rtl/clkmgr_byp.sv" \
    "/scratch/ciani/opentitan/hw/ip/clkmgr/rtl/clkmgr.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/csrng/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/csrng/../prim/rtl/" \
    "/scratch/ciani/opentitan/hw/ip/csrng/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/csrng/rtl/csrng_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/csrng/rtl/csrng_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/csrng/rtl/csrng_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/csrng/rtl/csrng_block_encrypt.sv" \
    "/scratch/ciani/opentitan/hw/ip/csrng/rtl/csrng_cmd_stage.sv" \
    "/scratch/ciani/opentitan/hw/ip/csrng/rtl/csrng_ctr_drbg_cmd.sv" \
    "/scratch/ciani/opentitan/hw/ip/csrng/rtl/csrng_ctr_drbg_gen.sv" \
    "/scratch/ciani/opentitan/hw/ip/csrng/rtl/csrng_ctr_drbg_upd.sv" \
    "/scratch/ciani/opentitan/hw/ip/csrng/rtl/csrng_main_sm.sv" \
    "/scratch/ciani/opentitan/hw/ip/csrng/rtl/csrng_state_db.sv" \
    "/scratch/ciani/opentitan/hw/ip/csrng/rtl/csrng_track_sm.sv" \
    "/scratch/ciani/opentitan/hw/ip/csrng/rtl/csrng_core.sv" \
    "/scratch/ciani/opentitan/hw/ip/csrng/rtl/csrng.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/edn/../csrng/rtl/" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/edn/../prim/rtl/" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/edn/rtl" \
    "/scratch/ciani/opentitan/hw/ip/edn/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/edn/../csrng/rtl/csrng_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/edn/rtl/edn_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/edn/rtl/edn_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/edn/rtl/edn_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/edn/rtl/edn_ack_sm.sv" \
    "/scratch/ciani/opentitan/hw/ip/edn/rtl/edn_core.sv" \
    "/scratch/ciani/opentitan/hw/ip/edn/rtl/edn_field_en.sv" \
    "/scratch/ciani/opentitan/hw/ip/edn/rtl/edn_main_sm.sv" \
    "/scratch/ciani/opentitan/hw/ip/edn/rtl/edn.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/entropy_src/../prim/rtl/" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/entropy_src/rtl" \
    "/scratch/ciani/opentitan/hw/ip/entropy_src/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/entropy_src/rtl/entropy_src_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/entropy_src/rtl/entropy_src_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/entropy_src/rtl/entropy_src_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/entropy_src/rtl/entropy_src_ack_sm.sv" \
    "/scratch/ciani/opentitan/hw/ip/entropy_src/rtl/entropy_src_adaptp_ht.sv" \
    "/scratch/ciani/opentitan/hw/ip/entropy_src/rtl/entropy_src_bucket_ht.sv" \
    "/scratch/ciani/opentitan/hw/ip/entropy_src/rtl/entropy_src_cntr_reg.sv" \
    "/scratch/ciani/opentitan/hw/ip/entropy_src/rtl/entropy_src_core.sv" \
    "/scratch/ciani/opentitan/hw/ip/entropy_src/rtl/entropy_src_main_sm.sv" \
    "/scratch/ciani/opentitan/hw/ip/entropy_src/rtl/entropy_src_markov_ht.sv" \
    "/scratch/ciani/opentitan/hw/ip/entropy_src/rtl/entropy_src_repcnt_ht.sv" \
    "/scratch/ciani/opentitan/hw/ip/entropy_src/rtl/entropy_src_repcnts_ht.sv" \
    "/scratch/ciani/opentitan/hw/ip/entropy_src/rtl/entropy_src_watermark_reg.sv" \
    "/scratch/ciani/opentitan/hw/ip/entropy_src/rtl/entropy_src.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/flash_ctrl/../prim/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/flash_ctrl/../prim_generic/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/flash_ctrl/../tlul/rtl" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/../prim_generic/rtl/prim_generic_ram_1p.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_ctrl_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_ctrl_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_phy_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_ctrl_arb.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_ctrl_core_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_ctrl_erase.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_ctrl_info_cfg.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_ctrl_lcmgr.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_ctrl_prog.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_ctrl_rd.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_mp.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_mp_data_region_sel.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_phy_rd_buffers.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_phy_core.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_phy_erase.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_phy_prog.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_phy_scramble.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/../prim_generic/rtl/prim_generic_flash_bank.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_phy_rd.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/../prim_generic/rtl/prim_generic_flash.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_phy.sv" \
    "/scratch/ciani/opentitan/hw/ip/flash_ctrl/rtl/flash_ctrl.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/gpio/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/gpio/../prim/rtl/" \
    "/scratch/ciani/opentitan/hw/ip/gpio/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/gpio/rtl/gpio_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/gpio/rtl/gpio_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/gpio/rtl/gpio.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/hmac/../tlul/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/hmac/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/hmac/../prim/rtl" \
    "/scratch/ciani/opentitan/hw/ip/hmac/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/hmac/rtl/hmac_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/hmac/rtl/hmac_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/hmac/rtl/hmac.sv" \
    "/scratch/ciani/opentitan/hw/ip/hmac/rtl/hmac_core.sv" \
    "/scratch/ciani/opentitan/hw/ip/hmac/rtl/hmac_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/hmac/rtl/sha2.sv" \
    "/scratch/ciani/opentitan/hw/ip/hmac/rtl/sha2_pad.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/keymgr/../rom_ctrl/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/keymgr/../flash_ctrl/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/keymgr/../prim/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/keymgr/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/keymgr/../rv_dm/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/keymgr/../otp_ctrl/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/keymgr/../tlul/rtl" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/../rv_dm/rtl/jtag_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/../otp_ctrl/rtl/otp_ctrl_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/../otp_ctrl/rtl/otp_ctrl_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/../flash_ctrl/rtl/flash_ctrl_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/../flash_ctrl/rtl/flash_ctrl_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/rtl/keymgr_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/rtl/keymgr_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/rtl/keymgr.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/rtl/keymgr_cfg_en.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/rtl/keymgr_ctrl.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/rtl/keymgr_input_checks.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/rtl/keymgr_kmac_if.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/rtl/keymgr_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/rtl/keymgr_reseed_ctrl.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/rtl/keymgr_sideload_key.sv" \
    "/scratch/ciani/opentitan/hw/ip/keymgr/rtl/keymgr_sideload_key_ctrl.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/otbn/../prim/rtl/" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/otbn/../csrng/rtl/" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/otbn/rtl" \
    "/scratch/ciani/opentitan/hw/ip/otbn/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_alu_base.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_alu_bignum.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_controller.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_decoder.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_instruction_fetch.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_loop_controller.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_lsu.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_mac_bignum.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_rf_base.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_rf_base_ff.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_rf_base_fpga.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_rf_bignum.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_rf_bignum_ff.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_rf_bignum_fpga.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_rnd.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_scramble_ctrl.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_stack.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_start_stop_control.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn_core.sv" \
    "/scratch/ciani/opentitan/hw/ip/otbn/rtl/otbn.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/vendor/pulp_riscv_dbg/src/../../../ip/prim_generic/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/vendor/pulp_riscv_dbg/src/../../../ip/prim/rtl" \
    "/scratch/ciani/opentitan/hw/vendor/pulp_riscv_dbg/src/../../../ip/prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/vendor/pulp_riscv_dbg/src/../../../ip/prim_generic/rtl/prim_generic_rom.sv" \
    "/scratch/ciani/opentitan/hw/vendor/pulp_riscv_dbg/src/dm_pkg.sv" \
    "/scratch/ciani/opentitan/hw/vendor/pulp_riscv_dbg/src/dm_obi_top.sv" \
    "/scratch/ciani/opentitan/hw/vendor/pulp_riscv_dbg/src/dm_sba.sv" \
    "/scratch/ciani/opentitan/hw/vendor/pulp_riscv_dbg/src/dmi_cdc.sv" \
    "/scratch/ciani/opentitan/hw/vendor/pulp_riscv_dbg/src/dmi_jtag.sv" \
    "/scratch/ciani/opentitan/hw/vendor/pulp_riscv_dbg/src/dmi_jtag_tap.sv" \
    "/scratch/ciani/opentitan/hw/vendor/pulp_riscv_dbg/src/dm_mem.sv" \
    "/scratch/ciani/opentitan/hw/vendor/pulp_riscv_dbg/src/dm_csrs.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/pwrmgr/../prim/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/pwrmgr/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/pwrmgr/../tlul/rtl" \
    "/scratch/ciani/opentitan/hw/ip/pwrmgr/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/pwrmgr/rtl/pwrmgr_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/pwrmgr/rtl/pwrmgr_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/pwrmgr/rtl/pwrmgr_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/pwrmgr/rtl/pwrmgr_cdc.sv" \
    "/scratch/ciani/opentitan/hw/ip/pwrmgr/rtl/pwrmgr_cdc_pulse.sv" \
    "/scratch/ciani/opentitan/hw/ip/pwrmgr/rtl/pwrmgr_fsm.sv" \
    "/scratch/ciani/opentitan/hw/ip/pwrmgr/rtl/pwrmgr_slow_fsm.sv" \
    "/scratch/ciani/opentitan/hw/ip/pwrmgr/rtl/pwrmgr_wake_info.sv" \
    "/scratch/ciani/opentitan/hw/ip/pwrmgr/rtl/pwrmgr.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rstmgr/../alert_handelr/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rstmgr/../prim/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rstmgr/../tlul/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rstmgr/rtl" \
    "/scratch/ciani/opentitan/hw/ip/rstmgr/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/rstmgr/../alert_handler/rtl/alert_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rstmgr/rtl/rstmgr_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rstmgr/rtl/rstmgr_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rstmgr/rtl/rstmgr_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/rstmgr/rtl/rstmgr_crash_info.sv" \
    "/scratch/ciani/opentitan/hw/ip/rstmgr/rtl/rstmgr_ctrl.sv" \
    "/scratch/ciani/opentitan/hw/ip/rstmgr/rtl/rstmgr_por.sv" \
    "/scratch/ciani/opentitan/hw/ip/rstmgr/rtl/rstmgr.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rv_dm/../prim/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rv_dm/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rv_dm/../tlul/rt" \
    "/scratch/ciani/opentitan/hw/ip/rv_dm/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_dm/rtl/jtag_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_dm/rtl/rv_dm_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_dm/rtl/rv_dm_regs_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_dm/rtl/rv_dm_rom_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_dm/rtl/rv_dm.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../prim_generic/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../pwrmgr/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../../vendor/lowrisc_ibex/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../prim/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../alert_handler/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rv_core_ibex/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../dv/sv/dv_utils/" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../../top_earlgrey/rtl" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../../top_earlgrey/rtl/top_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../tlul/rtl/tlul_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../../vendor/lowrisc_ibex/rtl/ibex_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../pwrmgr/rtl/pwrmgr_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../pwrmgr/rtl/pwrmgr_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../../vendor/lowrisc_ibex/rtl/ibex_icache.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../prim/rtl/prim_flop_2sync.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../prim/rtl/prim_flop.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../prim_generic/rtl/prim_generic_ram_1p.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/../alert_handler/rtl/alert_handler_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/rtl/rv_core_ibex_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/rtl/rv_core_ibex_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/rtl/rv_core_ibex_cfg_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/rtl/rv_core_addr_trans.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_core_ibex/rtl/rv_core_ibex.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rv_plic/../prim/rtl/" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/rv_plic/rtl" \
    "/scratch/ciani/opentitan/hw/ip/rv_plic/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_plic/rtl/rv_plic_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_plic/rtl/rv_plic_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_plic/rtl/rv_plic_gateway.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_plic/rtl/rv_plic_target.sv" \
    "/scratch/ciani/opentitan/hw/ip/rv_plic/rtl/rv_plic.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/spi_device/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/spi_device/../prim/rtl/" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spi_device_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spi_device_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spi_device_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spi_cmdparse.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spi_fwm_rxf_ctrl.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spi_fwm_txf_ctrl.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spi_fwmode.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spi_p2s.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spi_passthrough.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spi_readcmd.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spi_s2p.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spid_fifo2sram_adapter.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spid_jedec.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spid_readbuffer.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spid_readsram.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spid_status.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spid_upload.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_device/rtl/spi_device.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/spi_host/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/spi_host/../prim/rtl/" \
    "/scratch/ciani/opentitan/hw/ip/spi_host/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_host/rtl/spi_host_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_host/rtl/spi_host_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_host/rtl/spi_host_cmd_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_host/rtl/spi_host_byte_merge.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_host/rtl/spi_host_byte_select.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_host/rtl/spi_host_command_cdc.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_host/rtl/spi_host_data_cdc.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_host/rtl/spi_host_fsm.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_host/rtl/spi_host_shift_register.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_host/rtl/spi_host_window.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_host/rtl/spi_host_core.sv" \
    "/scratch/ciani/opentitan/hw/ip/spi_host/rtl/spi_host.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/../tlul/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/../prim/rtl" \
    "/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_autoblock.sv" \
    "/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_combo.sv" \
    "/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_comboact.sv" \
    "/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_combofsm.sv" \
    "/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_keyfsm.sv" \
    "/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_keyintr.sv" \
    "/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_pin.sv" \
    "/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_timerfsm.sv" \
    "/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_ulp.sv" \
    "/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_ulpfsm.sv" \
    "/scratch/ciani/opentitan/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+/scratch/ciani/opentitan/hw/ip/uart/../tlul/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/uart/../prim/rtl" \
    "+incdir+/scratch/ciani/opentitan/hw/ip/uart/rtl" \
    "/scratch/ciani/opentitan/hw/ip/uart/../prim/rtl/prim_assert.sv" \
    "/scratch/ciani/opentitan/hw/ip/uart/rtl/uart_reg_pkg.sv" \
    "/scratch/ciani/opentitan/hw/ip/uart/rtl/uart_reg_top.sv" \
    "/scratch/ciani/opentitan/hw/ip/uart/rtl/uart_core.sv" \
    "/scratch/ciani/opentitan/hw/ip/uart/rtl/uart_rx.sv" \
    "/scratch/ciani/opentitan/hw/ip/uart/rtl/uart_tx.sv" \
    "/scratch/ciani/opentitan/hw/ip/uart/rtl/uart.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -suppress vlog-2583 -suppress vlog-13314 -suppress vlog-13198 -suppress vlog-13233 -timescale "1 ns / 1 ps" \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/tb" \
    "+incdir+$ROOT/autogen/rtl/autogen" \
    "+incdir+$ROOT/../ip/prim/rtl" \
    "$ROOT/../ip/prim/rtl/prim_assert.sv" \
    "$ROOT/autogen/rtl/autogen/tl_main_pkg.sv" \
    "$ROOT/autogen/rtl/autogen/xbar_main.sv" \
    "$ROOT/tb/prim_generic_ram_2p.sv" \
    "$ROOT/tb/simulator_ctrl.sv" \
    "$ROOT/tb/ram_2p.sv" \
    "$ROOT/tb/opentitan.sv" \
    "$ROOT/tb/testbench.sv"
}]} {return 1}

