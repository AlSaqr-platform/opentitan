set ROOT [file normalize [file dirname [info script]]/..]
# This script was generated automatically by bender.

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/common_verification-d3e6f9a5c17df22d/src/clk_rst_gen.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d3e6f9a5c17df22d/src/rand_id_queue.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d3e6f9a5c17df22d/src/rand_stream_mst.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d3e6f9a5c17df22d/src/rand_synch_holdable_driver.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d3e6f9a5c17df22d/src/rand_verif_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d3e6f9a5c17df22d/src/signal_highlighter.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d3e6f9a5c17df22d/src/sim_timeout.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d3e6f9a5c17df22d/src/stream_watchdog.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d3e6f9a5c17df22d/src/rand_synch_driver.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d3e6f9a5c17df22d/src/rand_stream_slv.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-92d52f210ddc65ea/src/rtl/tc_sram.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-92d52f210ddc65ea/src/rtl/tc_sram_impl.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-92d52f210ddc65ea/src/rtl/tc_clk.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-92d52f210ddc65ea/src/deprecated/cluster_pwr_cells.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-92d52f210ddc65ea/src/deprecated/generic_memory.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-92d52f210ddc65ea/src/deprecated/generic_rom.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-92d52f210ddc65ea/src/deprecated/pad_functional.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-92d52f210ddc65ea/src/deprecated/pulp_buffer.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-92d52f210ddc65ea/src/deprecated/pulp_pwr_cells.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-92d52f210ddc65ea/src/tc_pwr.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-92d52f210ddc65ea/src/deprecated/pulp_clock_gating_async.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-92d52f210ddc65ea/src/deprecated/cluster_clk_cells.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-92d52f210ddc65ea/src/deprecated/pulp_clk_cells.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/include" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/binary_to_gray.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/include" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/cb_filter_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/cc_onehot.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/cdc_reset_ctrlr_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/cf_math_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/clk_int_div.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/delta_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/ecc_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/edge_propagator_tx.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/exp_backoff.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/fifo_v3.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/gray_to_binary.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/isochronous_4phase_handshake.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/isochronous_spill_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/lfsr.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/lfsr_16bit.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/lfsr_8bit.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/lossy_valid_to_stream.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/mv_filter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/onehot_to_bin.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/plru_tree.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/popcount.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/rr_arb_tree.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/rstgen_bypass.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/serial_deglitch.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/shift_reg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/shift_reg_gated.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/spill_register_flushable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_demux.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_filter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_fork.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_intf.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_join_dynamic.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_mux.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_throttle.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/sub_per_hash.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/sync.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/sync_wedge.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/unread.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/read.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/addr_decode_dync.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/cdc_2phase.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/cdc_4phase.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/clk_int_div_static.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/addr_decode.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/addr_decode_napot.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/multiaddr_decode.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/include" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/cb_filter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/cdc_fifo_2phase.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/clk_mux_glitch_free.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/ecc_decode.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/ecc_encode.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/edge_detect.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/lzc.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/max_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/rstgen.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/spill_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_delay.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_fifo.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_fork_dynamic.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_join.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/cdc_reset_ctrlr.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/cdc_fifo_gray.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/fall_through_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/id_queue.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_to_mem.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_arbiter_flushable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_fifo_optimal_wrap.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_xbar.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/cdc_fifo_gray_clearable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/cdc_2phase_clearable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/mem_to_banks_detailed.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_arbiter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/stream_omega_net.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/mem_to_banks.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/include" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/deprecated/sram.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/include" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/deprecated/clock_divider_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/deprecated/clk_div.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/deprecated/find_first_one.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/deprecated/generic_LFSR_8bit.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/deprecated/generic_fifo.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/deprecated/prioarbiter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/deprecated/pulp_sync.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/deprecated/pulp_sync_wedge.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/deprecated/rrarbiter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/deprecated/clock_divider.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/deprecated/fifo_v2.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/deprecated/fifo_v1.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/edge_propagator_ack.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/edge_propagator.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/src/edge_propagator_rx.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/include" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_pkg.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_intf.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_atop_filter.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_burst_splitter.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_bus_compare.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_cdc_dst.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_cdc_src.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_cut.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_delayer.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_demux_simple.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_dw_downsizer.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_dw_upsizer.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_fifo.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_id_remap.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_id_prepend.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_isolate.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_join.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_lite_demux.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_lite_dw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_lite_from_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_lite_join.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_lite_lfsr.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_lite_mailbox.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_lite_mux.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_lite_regs.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_lite_to_apb.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_lite_to_axi.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_modify_address.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_mux.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_rw_join.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_rw_split.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_serializer.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_slave_compare.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_throttle.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_to_detailed_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_cdc.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_demux.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_err_slv.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_dw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_from_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_id_serialize.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_lfsr.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_multicut.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_to_axi_lite.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_to_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_iw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_lite_xbar.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_xbar.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_to_mem_banked.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_to_mem_interleaved.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_to_mem_split.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_xp.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-b194fb1633f60a08/include" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_chan_compare.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_dumper.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_sim_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/src/axi_test.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/hw/ip/prim/rtl" \
    "+incdir+$ROOT/hw/ip/tlul/rtl" \
    "+incdir+$ROOT/hw/ip/rv_core_ibex/rtl" \
    "+incdir+$ROOT/hw/dv/sv/dv_utils" \
    "+incdir+$ROOT/hw/ip/tlul2axi/test" \
    "+incdir+$ROOT/hw/ip/lowrisc_ibex/rtl" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/include" \
    "$ROOT/hw/vendor/pulp_riscv_dbg/debug_rom/debug_rom.sv" \
    "$ROOT/hw/vendor/pulp_riscv_dbg/debug_rom/debug_rom_one_scratch.sv" \
    "$ROOT/hw/vendor/pulp_riscv_dbg/src/dm_pkg.sv" \
    "$ROOT/hw/vendor/pulp_riscv_dbg/src/dm_sba.sv" \
    "$ROOT/hw/vendor/pulp_riscv_dbg/src/dmi_cdc.sv" \
    "$ROOT/hw/vendor/pulp_riscv_dbg/src/dmi_jtag.sv" \
    "$ROOT/hw/vendor/pulp_riscv_dbg/src/dmi_jtag_tap.sv" \
    "$ROOT/hw/vendor/pulp_riscv_dbg/src/dm_mem.sv" \
    "$ROOT/hw/vendor/pulp_riscv_dbg/src/dm_csrs.sv" \
    "$ROOT/hw/vendor/pulp_riscv_dbg/src/dm_top.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/dv/uvm/core_ibex/common/prim/prim_pkg.sv" \
    "$ROOT/hw/top_earlgrey/ip_autogen/alert_handler/rtl/alert_handler_reg_pkg.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_mubi_pkg.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_util_pkg.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_pkg.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_pkg.sv" \
    "$ROOT/hw/ip/edn/rtl/edn_pkg.sv" \
    "$ROOT/hw/ip/lc_ctrl/rtl/lc_ctrl_state_pkg.sv" \
    "$ROOT/hw/ip/lc_ctrl/rtl/lc_ctrl_reg_pkg.sv" \
    "$ROOT/hw/ip/lc_ctrl/rtl/lc_ctrl_pkg.sv" \
    "$ROOT/hw/ip/otp_ctrl/rtl/otp_ctrl_reg_pkg.sv" \
    "$ROOT/hw/ip/otp_ctrl/rtl/otp_ctrl_pkg.sv" \
    "$ROOT/hw/ip/rv_dm/rtl/jtag_pkg.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_assert.sv" \
    "$ROOT/hw/top_earlgrey/ip/ast/rtl/ast_pkg.sv" \
    "$ROOT/hw/top_earlgrey/rtl/top_pkg.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_pkg.sv" \
    "$ROOT/hw/top_earlgrey/ip/flash_ctrl/rtl/autogen/flash_ctrl_reg_pkg.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_ctrl_pkg.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_phy_pkg.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_subreg_pkg.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_alert_pkg.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_alert_receiver.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_alert_sender.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_arbiter_fixed.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_arbiter_ppc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_arbiter_tree_dup.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_arbiter_tree.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_blanker.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_cdc_rand_delay.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_clock_meas.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_cipher_pkg.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_clock_div.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_clock_gating_sync.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_clock_gp_mux2.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_clock_timeout.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_count.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_crc32.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_diff_decode.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_dom_and_2share.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_double_lfsr.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_edge_detector.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_edn_req.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_esc_pkg.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_esc_receiver.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_esc_sender.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_fifo_async_sram_adapter.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_fifo_async.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_fifo_sync_cnt.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_fifo_sync.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_filter_ctr.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_fifo_async_simple.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_filter.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_flop_2sync.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_flop_macros.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_gate_gen.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_gf_mult.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_intr_hw.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_keccak.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_lc_and_hardened.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_lc_combine.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_lc_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_lc_or_hardened.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_lc_sender.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_lc_sync.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_lfsr.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_max_tree.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_msb_extend.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_mubi12_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_mubi12_sender.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_mubi12_sync.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_mubi16_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_mubi16_sender.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_mubi16_sync.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_mubi4_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_mubi4_sender.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_mubi4_sync.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_mubi8_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_mubi8_sender.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_mubi8_sync.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_multibit_sync.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_onehot_check.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_onehot_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_onehot_mux.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_otp_pkg.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_packer_fifo.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_packer.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_pad_wrapper_pkg.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_present.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_prince.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_pulse_sync.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_ram_2p_pkg.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_ram_1p_pkg.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_ram_2p.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_ram_1p.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_ram_1p_adv.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_ram_1p_scr.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_ram_2p_adv.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_ram_2p_async_adv.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_otp_wrap_adv.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_otp.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_reg_cdc_arb.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_reg_cdc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_reg_we_check.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_rom_pkg.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_rom_adv.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_rst_sync.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_sec_anchor_buf.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_sec_anchor_flop.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_22_16_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_22_16_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_28_22_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_28_22_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_39_32_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_39_32_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_64_57_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_64_57_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_72_64_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_72_64_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_hamming_22_16_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_hamming_22_16_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_hamming_39_32_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_hamming_39_32_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_hamming_72_64_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_hamming_72_64_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_hamming_76_68_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_hamming_76_68_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_22_16_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_22_16_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_28_22_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_28_22_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_39_32_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_39_32_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_64_57_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_64_57_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_72_64_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_72_64_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_hamming_22_16_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_hamming_22_16_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_hamming_39_32_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_hamming_39_32_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_hamming_72_64_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_hamming_72_64_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_hamming_76_68_dec.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_secded_inv_hamming_76_68_enc.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_slicer.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_sparse_fsm_flop.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_sram_arbiter.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_subreg_arb.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_subreg_ext.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_subreg_shadow.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_subreg.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_subst_perm.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_sum_tree.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_sync_reqack_data.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_sync_reqack.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_sync_slow_fast.sv" \
    "$ROOT/hw/ip/prim/rtl/prim_xoshiro256pp.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_cmd_intg_chk.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_data_integ_enc.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_rsp_intg_chk.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_cmd_intg_gen.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_rsp_intg_gen.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_data_integ_dec.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_adapter_host.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_adapter_reg.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_assert.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_assert_multiple.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_err.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_err_resp.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_lc_gate.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_sram_byte.sv" \
    "$ROOT/hw/ip/tlul/rtl/sram2tlul.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_socket_1n.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_socket_m1.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_fifo_sync.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_fifo_async.sv" \
    "$ROOT/hw/ip/tlul/rtl/tlul_adapter_sram.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_and2.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_buf.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_clock_buf.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_clock_gating.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_clock_inv.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_clock_mux2.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_flash_bank.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_flash.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_flop_en.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_flop.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_otp.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_pad_attr.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_pad_wrapper.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_ram_1p.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_ram_2p.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_rom.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_usb_diff_rx.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_xnor2.sv" \
    "$ROOT/hw/ip/prim_generic/rtl/prim_generic_xor2.sv" \
    "$ROOT/hw/ip/rng/rtl/ast_pulse_sync.sv" \
    "$ROOT/hw/ip/rng/rtl/rng.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_pkg.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_register_file_ff.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_alu.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_compressed_decoder.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_controller.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_counter.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_csr.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_decoder.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_icache.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_fetch_fifo.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_load_store_unit.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_multdiv_fast.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_multdiv_slow.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_pmp.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_tracer_pkg.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_wb_stage.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_dummy_instr.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_lockstep.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_cs_registers.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_ex_block.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_id_stage.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_prefetch_buffer.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_if_stage.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_core.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_top.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+RVFI=true \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/hw/ip/prim/rtl" \
    "+incdir+$ROOT/hw/ip/tlul/rtl" \
    "+incdir+$ROOT/hw/ip/rv_core_ibex/rtl" \
    "+incdir+$ROOT/hw/dv/sv/dv_utils" \
    "+incdir+$ROOT/hw/ip/tlul2axi/test" \
    "+incdir+$ROOT/hw/ip/lowrisc_ibex/rtl" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/include" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_lockstep.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_core.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_top.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/hw/ip/prim/rtl" \
    "+incdir+$ROOT/hw/ip/tlul/rtl" \
    "+incdir+$ROOT/hw/ip/rv_core_ibex/rtl" \
    "+incdir+$ROOT/hw/dv/sv/dv_utils" \
    "+incdir+$ROOT/hw/ip/tlul2axi/test" \
    "+incdir+$ROOT/hw/ip/lowrisc_ibex/rtl" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/include" \
    "$ROOT/hw/top_earlgrey/ip/pwrmgr/rtl/autogen/pwrmgr_reg_pkg.sv" \
    "$ROOT/hw/top_earlgrey/ip/pwrmgr/rtl/autogen/pwrmgr_reg_top.sv" \
    "$ROOT/hw/ip/pwrmgr/rtl/pwrmgr_pkg.sv" \
    "$ROOT/hw/ip/rv_core_ibex/rtl/rv_core_ibex_pkg.sv" \
    "$ROOT/hw/ip/rv_core_ibex/rtl/rv_core_ibex_reg_pkg.sv" \
    "$ROOT/hw/ip/rv_core_ibex/rtl/rv_core_ibex_cfg_reg_top.sv" \
    "$ROOT/hw/ip/rv_core_ibex/rtl/rv_core_addr_trans.sv" \
    "$ROOT/hw/ip/rv_core_ibex/rtl/rv_core_ibex.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+RVFI \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/hw/ip/prim/rtl" \
    "+incdir+$ROOT/hw/ip/tlul/rtl" \
    "+incdir+$ROOT/hw/ip/rv_core_ibex/rtl" \
    "+incdir+$ROOT/hw/dv/sv/dv_utils" \
    "+incdir+$ROOT/hw/ip/tlul2axi/test" \
    "+incdir+$ROOT/hw/ip/lowrisc_ibex/rtl" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/include" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_tracer.sv" \
    "$ROOT/hw/vendor/lowrisc_ibex/rtl/ibex_top_tracing.sv" \
    "$ROOT/hw/ip/rv_core_ibex/rtl/rv_core_addr_trans.sv" \
    "$ROOT/hw/ip/rv_core_ibex/rtl/rv_core_ibex.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/hw/ip/prim/rtl" \
    "+incdir+$ROOT/hw/ip/tlul/rtl" \
    "+incdir+$ROOT/hw/ip/rv_core_ibex/rtl" \
    "+incdir+$ROOT/hw/dv/sv/dv_utils" \
    "+incdir+$ROOT/hw/ip/tlul2axi/test" \
    "+incdir+$ROOT/hw/ip/lowrisc_ibex/rtl" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/include" \
    "$ROOT/hw/ip/rv_dm/rtl/rv_dm_reg_pkg.sv" \
    "$ROOT/hw/ip/rv_dm/rtl/rv_dm_regs_reg_top.sv" \
    "$ROOT/hw/ip/rv_dm/rtl/rv_dm_mem_reg_top.sv" \
    "$ROOT/hw/ip/rv_dm/rtl/rv_dm.sv" \
    "$ROOT/hw/ip/kmac/rtl/sha3_pkg.sv" \
    "$ROOT/hw/ip/kmac/rtl/kmac_reg_pkg.sv" \
    "$ROOT/hw/ip/kmac/rtl/kmac_pkg.sv" \
    "$ROOT/hw/ip/keymgr/rtl/keymgr_reg_pkg.sv" \
    "$ROOT/hw/ip/keymgr/rtl/keymgr_pkg.sv" \
    "$ROOT/hw/ip/kmac/rtl/keccak_2share.sv" \
    "$ROOT/hw/ip/kmac/rtl/keccak_round.sv" \
    "$ROOT/hw/ip/kmac/rtl/kmac.sv" \
    "$ROOT/hw/ip/kmac/rtl/kmac_app.sv" \
    "$ROOT/hw/ip/kmac/rtl/kmac_core.sv" \
    "$ROOT/hw/ip/kmac/rtl/kmac_entropy.sv" \
    "$ROOT/hw/ip/kmac/rtl/kmac_errchk.sv" \
    "$ROOT/hw/ip/kmac/rtl/kmac_msgfifo.sv" \
    "$ROOT/hw/ip/kmac/rtl/kmac_reg_top.sv" \
    "$ROOT/hw/ip/kmac/rtl/kmac_staterd.sv" \
    "$ROOT/hw/ip/kmac/rtl/sha3.sv" \
    "$ROOT/hw/ip/kmac/rtl/sha3pad.sv" \
    "$ROOT/hw/ip/boot_manager/rtl/boot_manager_regs_reg_pkg.sv" \
    "$ROOT/hw/ip/boot_manager/rtl/boot_manager_regs_reg_top.sv" \
    "$ROOT/hw/ip/boot_manager/rtl/boot_manager.sv" \
    "$ROOT/hw/ip/rom_ctrl/rtl/boot_rom.sv" \
    "$ROOT/hw/ip/rom_ctrl/rtl/rom_ctrl_pkg.sv" \
    "$ROOT/hw/ip/rom_ctrl/rtl/rom_ctrl_reg_pkg.sv" \
    "$ROOT/hw/ip/rom_ctrl/rtl/rom_ctrl_compare.sv" \
    "$ROOT/hw/ip/rom_ctrl/rtl/rom_ctrl_counter.sv" \
    "$ROOT/hw/ip/rom_ctrl/rtl/rom_ctrl_mux.sv" \
    "$ROOT/hw/ip/rom_ctrl/rtl/rom_ctrl_regs_reg_top.sv" \
    "$ROOT/hw/ip/rom_ctrl/rtl/rom_ctrl_rom_reg_top.sv" \
    "$ROOT/hw/ip/rom_ctrl/rtl/rom_ctrl_fsm.sv" \
    "$ROOT/hw/ip/rom_ctrl/rtl/rom_ctrl_scrambled_rom.sv" \
    "$ROOT/hw/ip/rom_ctrl/rtl/rom_ctrl.sv" \
    "$ROOT/hw/top_earlgrey/ip_autogen/rv_plic/rtl/rv_plic_reg_pkg.sv" \
    "$ROOT/hw/top_earlgrey/ip_autogen/rv_plic/rtl/rv_plic_reg_top.sv" \
    "$ROOT/hw/top_earlgrey/ip_autogen/rv_plic/rtl/rv_plic_gateway.sv" \
    "$ROOT/hw/top_earlgrey/ip_autogen/rv_plic/rtl/rv_plic_target.sv" \
    "$ROOT/hw/top_earlgrey/ip_autogen/rv_plic/rtl/rv_plic.sv" \
    "$ROOT/hw/top_earlgrey/ip_autogen/alert_handler/rtl/alert_handler_reg_top.sv" \
    "$ROOT/hw/top_earlgrey/ip_autogen/alert_handler/rtl/alert_pkg.sv" \
    "$ROOT/hw/top_earlgrey/ip_autogen/alert_handler/rtl/alert_handler_lpg_ctrl.sv" \
    "$ROOT/hw/top_earlgrey/ip_autogen/alert_handler/rtl/alert_handler_accu.sv" \
    "$ROOT/hw/top_earlgrey/ip_autogen/alert_handler/rtl/alert_handler_class.sv" \
    "$ROOT/hw/top_earlgrey/ip_autogen/alert_handler/rtl/alert_handler_esc_timer.sv" \
    "$ROOT/hw/top_earlgrey/ip_autogen/alert_handler/rtl/alert_handler_ping_timer.sv" \
    "$ROOT/hw/top_earlgrey/ip_autogen/alert_handler/rtl/alert_handler_reg_wrap.sv" \
    "$ROOT/hw/top_earlgrey/ip_autogen/alert_handler/rtl/alert_handler.sv" \
    "$ROOT/hw/ip/pwrmgr/rtl/pwrmgr_cdc.sv" \
    "$ROOT/hw/ip/pwrmgr/rtl/pwrmgr_cdc_pulse.sv" \
    "$ROOT/hw/ip/pwrmgr/rtl/pwrmgr_fsm.sv" \
    "$ROOT/hw/ip/pwrmgr/rtl/pwrmgr_slow_fsm.sv" \
    "$ROOT/hw/ip/pwrmgr/rtl/pwrmgr_wake_info.sv" \
    "$ROOT/hw/ip/pwrmgr/rtl/pwrmgr.sv" \
    "$ROOT/hw/ip/keymgr/rtl/keymgr_reg_top.sv" \
    "$ROOT/hw/ip/keymgr/rtl/keymgr_cfg_en.sv" \
    "$ROOT/hw/ip/keymgr/rtl/keymgr_ctrl.sv" \
    "$ROOT/hw/ip/keymgr/rtl/keymgr_op_state_ctrl.sv" \
    "$ROOT/hw/ip/keymgr/rtl/keymgr_data_en_state.sv" \
    "$ROOT/hw/ip/keymgr/rtl/keymgr_err.sv" \
    "$ROOT/hw/ip/keymgr/rtl/keymgr_input_checks.sv" \
    "$ROOT/hw/ip/keymgr/rtl/keymgr_kmac_if.sv" \
    "$ROOT/hw/ip/keymgr/rtl/keymgr_reseed_ctrl.sv" \
    "$ROOT/hw/ip/keymgr/rtl/keymgr_sideload_key.sv" \
    "$ROOT/hw/ip/keymgr/rtl/keymgr_sideload_key_ctrl.sv" \
    "$ROOT/hw/ip/keymgr/rtl/keymgr.sv" \
    "$ROOT/hw/ip/otp_ctrl/rtl/otp_rom.sv" \
    "$ROOT/hw/ip/otp_ctrl/rtl/otp_ctrl_part_pkg.sv" \
    "$ROOT/hw/ip/otp_ctrl/rtl/otp_ctrl_prim_reg_top.sv" \
    "$ROOT/hw/ip/otp_ctrl/rtl/otp_ctrl_core_reg_top.sv" \
    "$ROOT/hw/ip/otp_ctrl/rtl/otp_ctrl_dai.sv" \
    "$ROOT/hw/ip/otp_ctrl/rtl/otp_ctrl_ecc_reg.sv" \
    "$ROOT/hw/ip/otp_ctrl/rtl/otp_ctrl_kdi.sv" \
    "$ROOT/hw/ip/otp_ctrl/rtl/otp_ctrl_lci.sv" \
    "$ROOT/hw/ip/otp_ctrl/rtl/otp_ctrl_lfsr_timer.sv" \
    "$ROOT/hw/ip/otp_ctrl/rtl/otp_ctrl_part_buf.sv" \
    "$ROOT/hw/ip/otp_ctrl/rtl/otp_ctrl_part_unbuf.sv" \
    "$ROOT/hw/ip/otp_ctrl/rtl/otp_ctrl_scrmbl.sv" \
    "$ROOT/hw/ip/otp_ctrl/rtl/otp_ctrl.sv" \
    "$ROOT/hw/ip/hmac/rtl/hmac_reg_pkg.sv" \
    "$ROOT/hw/ip/hmac/rtl/hmac_pkg.sv" \
    "$ROOT/hw/ip/hmac/rtl/hmac.sv" \
    "$ROOT/hw/ip/hmac/rtl/hmac_core.sv" \
    "$ROOT/hw/ip/hmac/rtl/hmac_reg_top.sv" \
    "$ROOT/hw/ip/hmac/rtl/sha2.sv" \
    "$ROOT/hw/ip/hmac/rtl/sha2_pad.sv" \
    "$ROOT/hw/ip/lc_ctrl/rtl/lc_ctrl_reg_top.sv" \
    "$ROOT/hw/ip/lc_ctrl/rtl/lc_ctrl_fsm.sv" \
    "$ROOT/hw/ip/lc_ctrl/rtl/lc_ctrl_kmac_if.sv" \
    "$ROOT/hw/ip/lc_ctrl/rtl/lc_ctrl_signal_decode.sv" \
    "$ROOT/hw/ip/lc_ctrl/rtl/lc_ctrl_state_decode.sv" \
    "$ROOT/hw/ip/lc_ctrl/rtl/lc_ctrl_state_transition.sv" \
    "$ROOT/hw/ip/lc_ctrl/rtl/lc_ctrl.sv" \
    "$ROOT/hw/ip/sram_ctrl/rtl/sram_ctrl_reg_pkg.sv" \
    "$ROOT/hw/ip/sram_ctrl/rtl/sram_ctrl_pkg.sv" \
    "$ROOT/hw/ip/sram_ctrl/rtl/sram_ctrl_regs_reg_top.sv" \
    "$ROOT/hw/ip/sram_ctrl/rtl/sram_ctrl.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_ctrl_arb.sv" \
    "$ROOT/hw/top_earlgrey/ip/flash_ctrl/rtl/autogen/flash_ctrl_core_reg_top.sv" \
    "$ROOT/hw/top_earlgrey/ip/flash_ctrl/rtl/autogen/flash_ctrl_region_cfg.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_ctrl_erase.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_ctrl_info_cfg.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_ctrl_lcmgr.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_phy_rd_buf_dep.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_ctrl_prog.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_ctrl_rd.sv" \
    "$ROOT/hw/top_earlgrey/ip/flash_ctrl/rtl/autogen/flash_ctrl_prim_reg_top.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_mp.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_mp_data_region_sel.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_phy_rd_buffers.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_phy_core.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_phy_erase.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_phy_prog.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_phy_scramble.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_phy_rd.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_phy.sv" \
    "$ROOT/hw/ip/flash_ctrl/rtl/flash_ctrl.sv" \
    "$ROOT/hw/ip/uart/rtl/uart_reg_pkg.sv" \
    "$ROOT/hw/ip/uart/rtl/uart_reg_top.sv" \
    "$ROOT/hw/ip/uart/rtl/uart_core.sv" \
    "$ROOT/hw/ip/uart/rtl/uart_rx.sv" \
    "$ROOT/hw/ip/uart/rtl/uart_tx.sv" \
    "$ROOT/hw/ip/uart/rtl/uart.sv" \
    "$ROOT/hw/ip/pattgen/rtl/pattgen_ctrl_pkg.sv" \
    "$ROOT/hw/ip/pattgen/rtl/pattgen_reg_pkg.sv" \
    "$ROOT/hw/ip/pattgen/rtl/pattgen_reg_top.sv" \
    "$ROOT/hw/ip/pattgen/rtl/pattgen_chan.sv" \
    "$ROOT/hw/ip/pattgen/rtl/pattgen_core.sv" \
    "$ROOT/hw/ip/pattgen/rtl/pattgen.sv" \
    "$ROOT/hw/ip/usbdev/rtl/usbdev_pkg.sv" \
    "$ROOT/hw/ip/usbdev/rtl/usbdev_reg_pkg.sv" \
    "$ROOT/hw/ip/usbdev/rtl/usb_consts_pkg.sv" \
    "$ROOT/hw/ip/usbdev/rtl/usbdev_reg_top.sv" \
    "$ROOT/hw/ip/usbdev/rtl/usbdev_iomux.sv" \
    "$ROOT/hw/ip/usbdev/rtl/usbdev_usbif.sv" \
    "$ROOT/hw/ip/usbdev/rtl/usb_fs_nb_out_pe.sv" \
    "$ROOT/hw/ip/usbdev/rtl/usb_fs_rx.sv" \
    "$ROOT/hw/ip/usbdev/rtl/usb_fs_tx.sv" \
    "$ROOT/hw/ip/usbdev/rtl/usbdev_aon_wake.sv" \
    "$ROOT/hw/ip/usbdev/rtl/usbdev_linkstate.sv" \
    "$ROOT/hw/ip/usbdev/rtl/usb_fs_nb_in_pe.sv" \
    "$ROOT/hw/ip/usbdev/rtl/usb_fs_nb_pe.sv" \
    "$ROOT/hw/ip/usbdev/rtl/usb_fs_tx_mux.sv" \
    "$ROOT/hw/ip/usbdev/rtl/usbdev_empty.sv" \
    "$ROOT/hw/ip/i2c/rtl/i2c_reg_pkg.sv" \
    "$ROOT/hw/ip/i2c/rtl/i2c_reg_top.sv" \
    "$ROOT/hw/ip/i2c/rtl/i2c_fsm.sv" \
    "$ROOT/hw/ip/i2c/rtl/i2c_core.sv" \
    "$ROOT/hw/ip/i2c/rtl/i2c.sv" \
    "$ROOT/hw/top_earlgrey/ip/sensor_ctrl/rtl/sensor_ctrl_reg_pkg.sv" \
    "$ROOT/hw/top_earlgrey/ip/sensor_ctrl/rtl/sensor_ctrl_pkg.sv" \
    "$ROOT/hw/top_earlgrey/ip/sensor_ctrl/rtl/sensor_ctrl_reg_top.sv" \
    "$ROOT/hw/top_earlgrey/ip/sensor_ctrl/rtl/sensor_ctrl.sv" \
    "$ROOT/hw/ip/adc_ctrl/rtl/adc_ctrl_pkg.sv" \
    "$ROOT/hw/ip/adc_ctrl/rtl/adc_ctrl_reg_pkg.sv" \
    "$ROOT/hw/ip/adc_ctrl/rtl/adc_ctrl_reg_top.sv" \
    "$ROOT/hw/ip/adc_ctrl/rtl/adc_ctrl_core.sv" \
    "$ROOT/hw/ip/adc_ctrl/rtl/adc_ctrl_fsm.sv" \
    "$ROOT/hw/ip/adc_ctrl/rtl/adc_ctrl_intr.sv" \
    "$ROOT/hw/ip/adc_ctrl/rtl/adc_ctrl.sv" \
    "$ROOT/hw/top_earlgrey/ip/clkmgr/rtl/autogen/clkmgr_reg_pkg.sv" \
    "$ROOT/hw/top_earlgrey/ip/clkmgr/rtl/autogen/clkmgr_pkg.sv" \
    "$ROOT/hw/top_earlgrey/ip/clkmgr/rtl/autogen/clkmgr_reg_top.sv" \
    "$ROOT/hw/ip/clkmgr/rtl/clkmgr_clk_status.sv" \
    "$ROOT/hw/ip/clkmgr/rtl/clkmgr_root_ctrl.sv" \
    "$ROOT/hw/ip/clkmgr/rtl/clkmgr_meas_chk.sv" \
    "$ROOT/hw/ip/clkmgr/rtl/clkmgr_trans.sv" \
    "$ROOT/hw/ip/clkmgr/rtl/clkmgr_byp.sv" \
    "$ROOT/hw/top_earlgrey/ip/clkmgr/rtl/autogen/clkmgr.sv" \
    "$ROOT/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_pkg.sv" \
    "$ROOT/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_reg_pkg.sv" \
    "$ROOT/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_reg_top.sv" \
    "$ROOT/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_autoblock.sv" \
    "$ROOT/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_detect.sv" \
    "$ROOT/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_combo.sv" \
    "$ROOT/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_ulp.sv" \
    "$ROOT/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_comboact.sv" \
    "$ROOT/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_keyintr.sv" \
    "$ROOT/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl_pin.sv" \
    "$ROOT/hw/ip/sysrst_ctrl/rtl/sysrst_ctrl.sv" \
    "$ROOT/hw/top_earlgrey/ip/rstmgr/rtl/autogen/rstmgr_reg_pkg.sv" \
    "$ROOT/hw/top_earlgrey/ip/rstmgr/rtl/autogen/rstmgr_pkg.sv" \
    "$ROOT/hw/top_earlgrey/ip/rstmgr/rtl/autogen/rstmgr_reg_top.sv" \
    "$ROOT/hw/ip/rstmgr/rtl/rstmgr_crash_info.sv" \
    "$ROOT/hw/ip/rstmgr/rtl/rstmgr_cnsty_chk.sv" \
    "$ROOT/hw/ip/rstmgr/rtl/rstmgr_leaf_rst.sv" \
    "$ROOT/hw/ip/rstmgr/rtl/rstmgr_ctrl.sv" \
    "$ROOT/hw/ip/rstmgr/rtl/rstmgr_por.sv" \
    "$ROOT/hw/top_earlgrey/ip/rstmgr/rtl/autogen/rstmgr.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_reg_pkg.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_pkg.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_sbox_canright_pkg.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_reg_status.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_reg_top.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_cipher_control.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_cipher_core.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_control.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_ctr.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_ctrl_reg_shadowed.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_key_expand.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_mix_columns.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_mix_single_column.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_ctr_fsm.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_cipher_control_fsm.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_control_fsm.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_ctr_fsm_p.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_cipher_control_fsm_p.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_control_fsm_p.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_ctr_fsm_n.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_cipher_control_fsm_n.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_control_fsm_n.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_prng_clearing.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_prng_masking.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_sbox.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_sbox_canright.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_sbox_canright_masked.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_sbox_canright_masked_noreuse.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_sbox_dom.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_sbox_lut.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_sel_buf_chk.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_shift_rows.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_sub_bytes.sv" \
    "$ROOT/hw/ip/aes/rtl/aes_core.sv" \
    "$ROOT/hw/ip/aes/rtl/aes.sv" \
    "$ROOT/hw/ip/csrng/rtl/csrng_reg_pkg.sv" \
    "$ROOT/hw/ip/csrng/rtl/csrng_pkg.sv" \
    "$ROOT/hw/ip/csrng/rtl/csrng_reg_top.sv" \
    "$ROOT/hw/ip/csrng/rtl/csrng_block_encrypt.sv" \
    "$ROOT/hw/ip/csrng/rtl/csrng_cmd_stage.sv" \
    "$ROOT/hw/ip/csrng/rtl/csrng_ctr_drbg_cmd.sv" \
    "$ROOT/hw/ip/csrng/rtl/csrng_ctr_drbg_gen.sv" \
    "$ROOT/hw/ip/csrng/rtl/csrng_ctr_drbg_upd.sv" \
    "$ROOT/hw/ip/csrng/rtl/csrng_main_sm.sv" \
    "$ROOT/hw/ip/csrng/rtl/csrng_state_db.sv" \
    "$ROOT/hw/ip/csrng/rtl/csrng_core.sv" \
    "$ROOT/hw/ip/csrng/rtl/csrng.sv" \
    "$ROOT/hw/ip/edn/rtl/edn_reg_pkg.sv" \
    "$ROOT/hw/ip/edn/rtl/edn_reg_top.sv" \
    "$ROOT/hw/ip/edn/rtl/edn_ack_sm.sv" \
    "$ROOT/hw/ip/edn/rtl/edn_core.sv" \
    "$ROOT/hw/ip/edn/rtl/edn_field_en.sv" \
    "$ROOT/hw/ip/edn/rtl/edn_main_sm.sv" \
    "$ROOT/hw/ip/edn/rtl/edn.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_pkg.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_reg_pkg.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_reg_top.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_alu_base.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_alu_bignum.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_controller.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_decoder.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_instruction_fetch.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_loop_controller.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_predecode.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_lsu.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_mac_bignum.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_rf_base.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_rf_base_ff.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_rf_base_fpga.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_rf_bignum.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_rf_bignum_ff.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_rf_bignum_fpga.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_rnd.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_scramble_ctrl.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_stack.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_start_stop_control.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn_core.sv" \
    "$ROOT/hw/ip/otbn/rtl/otbn.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_reg_pkg.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_ack_sm_pkg.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_main_sm_pkg.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_reg_top.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_ack_sm.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_adaptp_ht.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_enable_delay.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_bucket_ht.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_cntr_reg.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_core.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_main_sm.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_markov_ht.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_repcnt_ht.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_repcnts_ht.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src_watermark_reg.sv" \
    "$ROOT/hw/ip/entropy_src/rtl/entropy_src.sv" \
    "$ROOT/hw/ip/gpio/rtl/gpio_reg_pkg.sv" \
    "$ROOT/hw/ip/gpio/rtl/gpio_reg_top.sv" \
    "$ROOT/hw/ip/gpio/rtl/gpio.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spi_device_reg_pkg.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spi_device_pkg.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spi_device_reg_top.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spi_cmdparse.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spi_fwm_rxf_ctrl.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spi_fwm_txf_ctrl.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spi_fwmode.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spi_p2s.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spi_passthrough.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spi_readcmd.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spi_s2p.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spid_fifo2sram_adapter.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spid_jedec.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spid_readbuffer.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spid_readsram.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spid_status.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spi_tpm.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spid_addr_4b.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spid_upload.sv" \
    "$ROOT/hw/ip/spi_device/rtl/spi_device_empty.sv" \
    "$ROOT/hw/ip/spi_host/rtl/spi_host_reg_pkg.sv" \
    "$ROOT/hw/ip/spi_host/rtl/spi_host_reg_top.sv" \
    "$ROOT/hw/ip/spi_host/rtl/spi_host_cmd_pkg.sv" \
    "$ROOT/hw/ip/spi_host/rtl/spi_host_empty.sv" \
    "$ROOT/hw/ip/spi_host/rtl/spi_host_byte_merge.sv" \
    "$ROOT/hw/ip/spi_host/rtl/spi_host_byte_select.sv" \
    "$ROOT/hw/ip/spi_host/rtl/spi_host_command_queue.sv" \
    "$ROOT/hw/ip/spi_host/rtl/spi_host_data_fifos.sv" \
    "$ROOT/hw/ip/spi_host/rtl/spi_host_fsm.sv" \
    "$ROOT/hw/ip/spi_host/rtl/spi_host_shift_register.sv" \
    "$ROOT/hw/ip/spi_host/rtl/spi_host_window.sv" \
    "$ROOT/hw/ip/spi_host/rtl/spi_host_core.sv" \
    "$ROOT/hw/ip/spi_host/rtl/spi_host.sv" \
    "$ROOT/hw/ip/aon_timer/rtl/aon_timer_reg_pkg.sv" \
    "$ROOT/hw/ip/aon_timer/rtl/aon_timer_reg_top.sv" \
    "$ROOT/hw/ip/aon_timer/rtl/aon_timer_core.sv" \
    "$ROOT/hw/ip/aon_timer/rtl/aon_timer.sv" \
    "$ROOT/hw/ip/rv_timer/rtl/rv_timer_reg_pkg.sv" \
    "$ROOT/hw/ip/rv_timer/rtl/rv_timer_reg_top.sv" \
    "$ROOT/hw/ip/rv_timer/rtl/timer_core.sv" \
    "$ROOT/hw/ip/rv_timer/rtl/rv_timer.sv" \
    "$ROOT/hw/top_earlgrey/ip/pinmux/rtl/autogen/pinmux_reg_pkg.sv" \
    "$ROOT/hw/top_earlgrey/ip/pinmux/rtl/autogen/pinmux_reg_top.sv" \
    "$ROOT/hw/ip/pinmux/rtl/pinmux_pkg.sv" \
    "$ROOT/hw/ip/pinmux/rtl/pinmux_jtag_breakout.sv" \
    "$ROOT/hw/ip/pinmux/rtl/pinmux_jtag_buf.sv" \
    "$ROOT/hw/ip/pinmux/rtl/pinmux_strap_sampling.sv" \
    "$ROOT/hw/ip/pinmux/rtl/pinmux_wkup.sv" \
    "$ROOT/hw/ip/pinmux/rtl/pinmux.sv" \
    "$ROOT/hw/top_earlgrey/ip/crossbar/xbar_peri/rtl/autogen/tl_peri_pkg.sv" \
    "$ROOT/hw/top_earlgrey/ip/crossbar/xbar_peri/rtl/autogen/xbar_peri.sv" \
    "$ROOT/hw/top_earlgrey/ip/crossbar/xbar_main/rtl/autogen/tl_main_pkg.sv" \
    "$ROOT/hw/top_earlgrey/ip/crossbar/xbar_main/rtl/autogen/xbar_main.sv" \
    "$ROOT/hw/ip/tlul2axi/rtl/tlul2axi_pkg.sv" \
    "$ROOT/hw/ip/tlul2axi/rtl/tlul2axi.sv" \
    "$ROOT/hw/ip/tlul2axi/test/tlul_intf.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/hw/ip/prim/rtl" \
    "+incdir+$ROOT/hw/ip/tlul/rtl" \
    "+incdir+$ROOT/hw/ip/rv_core_ibex/rtl" \
    "+incdir+$ROOT/hw/dv/sv/dv_utils" \
    "+incdir+$ROOT/hw/ip/tlul2axi/test" \
    "+incdir+$ROOT/hw/ip/lowrisc_ibex/rtl" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/include" \
    "$ROOT/hw/ip/tlul2axi/test/tlul_functions.sv" \
    "$ROOT/hw/ip/tlul2axi/test/tlul2axi_testbench.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/hw/ip/prim/rtl" \
    "+incdir+$ROOT/hw/ip/tlul/rtl" \
    "+incdir+$ROOT/hw/ip/rv_core_ibex/rtl" \
    "+incdir+$ROOT/hw/dv/sv/dv_utils" \
    "+incdir+$ROOT/hw/ip/tlul2axi/test" \
    "+incdir+$ROOT/hw/ip/lowrisc_ibex/rtl" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/include" \
    "$ROOT/hw/ip/pwm/rtl/pwm_reg_pkg.sv" \
    "$ROOT/hw/ip/pwm/rtl/pwm_reg_top.sv" \
    "$ROOT/hw/ip/pwm/rtl/pwm_chan.sv" \
    "$ROOT/hw/ip/pwm/rtl/pwm_core.sv" \
    "$ROOT/hw/ip/pwm/rtl/pwm.sv" \
    "$ROOT/hw/top_earlgrey/rtl/autogen/top_earlgrey_pkg.sv" \
    "$ROOT/hw/top_earlgrey/rtl/autogen/top_earlgrey_rnd_cnst_pkg.sv" \
    "$ROOT/hw/top_earlgrey/rtl/jtag_id_pkg.sv" \
    "$ROOT/hw/top_earlgrey/top/top_earlgrey.sv" \
    "$ROOT/hw/top_earlgrey/top/secure_subsystem_synth_pkg.sv" \
    "$ROOT/hw/top_earlgrey/top/secure_subsystem_asynch_synth_wrap.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314  +nospecify +notimingchecks  -timescale "1 ns / 1 ps"  \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST_OT_VIP \
    +define+TARGET_VSIM \
    +define+VIPS \
    "+incdir+$ROOT/hw/ip/prim/rtl" \
    "+incdir+$ROOT/hw/ip/tlul/rtl" \
    "+incdir+$ROOT/hw/ip/rv_core_ibex/rtl" \
    "+incdir+$ROOT/hw/dv/sv/dv_utils" \
    "+incdir+$ROOT/hw/ip/tlul2axi/test" \
    "+incdir+$ROOT/hw/ip/lowrisc_ibex/rtl" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-14472f022f20baa1/include" \
    "$ROOT/hw/tb/util/uart.sv" \
    "$ROOT/hw/tb/vips/s25fs256s.v" \
    "$ROOT/hw/tb/util/jtag_intf.sv" \
    "$ROOT/hw/vendor/pulp_riscv_dbg/src/jtag_test.sv" \
    "$ROOT/hw/vendor/common_pads/src/pad_alsaqr.sv" \
    "$ROOT/hw/tb/testbench.sv" \
    "$ROOT/hw/tb/testbench_asynch.sv"
}]} {return 1}

