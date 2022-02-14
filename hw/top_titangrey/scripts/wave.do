onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group tb /ibex_simple_system/IO_CLK
add wave -noupdate -group tb /ibex_simple_system/IO_RST_N
add wave -noupdate -group tb /ibex_simple_system/clk_sys
add wave -noupdate -group tb /ibex_simple_system/rst_sys_n
add wave -noupdate -group tb /ibex_simple_system/main_tl_rv_core_ibex__corei_req
add wave -noupdate -group tb /ibex_simple_system/main_tl_rv_core_ibex__corei_rsp
add wave -noupdate -group tb /ibex_simple_system/main_tl_rv_core_ibex__cored_req
add wave -noupdate -group tb /ibex_simple_system/main_tl_rv_core_ibex__cored_rsp
add wave -noupdate -group tb /ibex_simple_system/core2ram
add wave -noupdate -group tb /ibex_simple_system/ram2core
add wave -noupdate -group tb /ibex_simple_system/core2simctrl
add wave -noupdate -group tb /ibex_simple_system/simctrl2core
add wave -noupdate -group tb /ibex_simple_system/core2timer
add wave -noupdate -group tb /ibex_simple_system/timer2core
add wave -noupdate -group tb /ibex_simple_system/core2instr
add wave -noupdate -group tb /ibex_simple_system/instr2core
add wave -noupdate -group tb /ibex_simple_system/device_sel
add wave -noupdate -group tb /ibex_simple_system/enable
add wave -noupdate -group tb /ibex_simple_system/timer_irq
add wave -noupdate -group tb /ibex_simple_system/instr_req
add wave -noupdate -group tb /ibex_simple_system/instr_gnt
add wave -noupdate -group tb /ibex_simple_system/instr_rvalid
add wave -noupdate -group tb /ibex_simple_system/instr_addr
add wave -noupdate -group tb /ibex_simple_system/instr_rdata
add wave -noupdate -group tb /ibex_simple_system/instr_err
add wave -noupdate -group Ram /ibex_simple_system/u_ram/clk_i
add wave -noupdate -group Ram /ibex_simple_system/u_ram/rst_ni
add wave -noupdate -group Ram /ibex_simple_system/u_ram/a_req_i
add wave -noupdate -group Ram /ibex_simple_system/u_ram/a_we_i
add wave -noupdate -group Ram /ibex_simple_system/u_ram/a_be_i
add wave -noupdate -group Ram /ibex_simple_system/u_ram/a_addr_i
add wave -noupdate -group Ram /ibex_simple_system/u_ram/a_wdata_i
add wave -noupdate -group Ram /ibex_simple_system/u_ram/a_rvalid_o
add wave -noupdate -group Ram /ibex_simple_system/u_ram/a_rdata_o
add wave -noupdate -group Ram /ibex_simple_system/u_ram/b_req_i
add wave -noupdate -group Ram /ibex_simple_system/u_ram/b_we_i
add wave -noupdate -group Ram /ibex_simple_system/u_ram/b_be_i
add wave -noupdate -group Ram /ibex_simple_system/u_ram/b_addr_i
add wave -noupdate -group Ram /ibex_simple_system/u_ram/b_wdata_i
add wave -noupdate -group Ram /ibex_simple_system/u_ram/b_rvalid_o
add wave -noupdate -group Ram /ibex_simple_system/u_ram/b_rdata_o
add wave -noupdate -group Ram /ibex_simple_system/u_ram/a_addr_idx
add wave -noupdate -group Ram /ibex_simple_system/u_ram/unused_a_addr_parts
add wave -noupdate -group Ram /ibex_simple_system/u_ram/b_addr_idx
add wave -noupdate -group Ram /ibex_simple_system/u_ram/unused_b_addr_parts
add wave -noupdate -group Ram /ibex_simple_system/u_ram/a_wmask
add wave -noupdate -group Ram /ibex_simple_system/u_ram/b_wmask
add wave -noupdate -group simctrl /ibex_simple_system/u_simulator_ctrl/clk_i
add wave -noupdate -group simctrl /ibex_simple_system/u_simulator_ctrl/rst_ni
add wave -noupdate -group simctrl /ibex_simple_system/u_simulator_ctrl/req_i
add wave -noupdate -group simctrl /ibex_simple_system/u_simulator_ctrl/we_i
add wave -noupdate -group simctrl /ibex_simple_system/u_simulator_ctrl/be_i
add wave -noupdate -group simctrl /ibex_simple_system/u_simulator_ctrl/addr_i
add wave -noupdate -group simctrl /ibex_simple_system/u_simulator_ctrl/wdata_i
add wave -noupdate -group simctrl /ibex_simple_system/u_simulator_ctrl/rvalid_o
add wave -noupdate -group simctrl /ibex_simple_system/u_simulator_ctrl/rdata_o
add wave -noupdate -group simctrl /ibex_simple_system/u_simulator_ctrl/ctrl_addr
add wave -noupdate -group simctrl /ibex_simple_system/u_simulator_ctrl/sim_finish
add wave -noupdate -group simctrl /ibex_simple_system/u_simulator_ctrl/log_fd
add wave -noupdate -group timer /ibex_simple_system/u_timer/clk_i
add wave -noupdate -group timer /ibex_simple_system/u_timer/rst_ni
add wave -noupdate -group timer /ibex_simple_system/u_timer/timer_req_i
add wave -noupdate -group timer /ibex_simple_system/u_timer/timer_addr_i
add wave -noupdate -group timer /ibex_simple_system/u_timer/timer_we_i
add wave -noupdate -group timer /ibex_simple_system/u_timer/timer_be_i
add wave -noupdate -group timer /ibex_simple_system/u_timer/timer_wdata_i
add wave -noupdate -group timer /ibex_simple_system/u_timer/timer_rvalid_o
add wave -noupdate -group timer /ibex_simple_system/u_timer/timer_rdata_o
add wave -noupdate -group timer /ibex_simple_system/u_timer/timer_err_o
add wave -noupdate -group timer /ibex_simple_system/u_timer/timer_intr_o
add wave -noupdate -group timer /ibex_simple_system/u_timer/timer_we
add wave -noupdate -group timer /ibex_simple_system/u_timer/mtime_we
add wave -noupdate -group timer /ibex_simple_system/u_timer/mtimeh_we
add wave -noupdate -group timer /ibex_simple_system/u_timer/mtimecmp_we
add wave -noupdate -group timer /ibex_simple_system/u_timer/mtimecmph_we
add wave -noupdate -group timer /ibex_simple_system/u_timer/mtime_wdata
add wave -noupdate -group timer /ibex_simple_system/u_timer/mtimeh_wdata
add wave -noupdate -group timer /ibex_simple_system/u_timer/mtimecmp_wdata
add wave -noupdate -group timer /ibex_simple_system/u_timer/mtimecmph_wdata
add wave -noupdate -group timer /ibex_simple_system/u_timer/mtime_q
add wave -noupdate -group timer /ibex_simple_system/u_timer/mtime_d
add wave -noupdate -group timer /ibex_simple_system/u_timer/mtime_inc
add wave -noupdate -group timer /ibex_simple_system/u_timer/mtimecmp_q
add wave -noupdate -group timer /ibex_simple_system/u_timer/mtimecmp_d
add wave -noupdate -group timer /ibex_simple_system/u_timer/interrupt_q
add wave -noupdate -group timer /ibex_simple_system/u_timer/interrupt_d
add wave -noupdate -group timer /ibex_simple_system/u_timer/error_q
add wave -noupdate -group timer /ibex_simple_system/u_timer/error_d
add wave -noupdate -group timer /ibex_simple_system/u_timer/rdata_q
add wave -noupdate -group timer /ibex_simple_system/u_timer/rdata_d
add wave -noupdate -group timer /ibex_simple_system/u_timer/rvalid_q
add wave -noupdate -group xbar /ibex_simple_system/bus/clk_main_i
add wave -noupdate -group xbar /ibex_simple_system/bus/rst_main_ni
add wave -noupdate -group xbar /ibex_simple_system/bus/tl_core_instr_i
add wave -noupdate -group xbar /ibex_simple_system/bus/tl_core_instr_o
add wave -noupdate -group xbar -expand /ibex_simple_system/bus/tl_core_data_i
add wave -noupdate -group xbar /ibex_simple_system/bus/tl_core_data_o
add wave -noupdate -group xbar /ibex_simple_system/bus/tl_data_mem_o
add wave -noupdate -group xbar /ibex_simple_system/bus/tl_data_mem_i
add wave -noupdate -group xbar /ibex_simple_system/bus/tl_sim_ctrl_o
add wave -noupdate -group xbar /ibex_simple_system/bus/tl_sim_ctrl_i
add wave -noupdate -group xbar /ibex_simple_system/bus/tl_timer_o
add wave -noupdate -group xbar /ibex_simple_system/bus/tl_timer_i
add wave -noupdate -group xbar /ibex_simple_system/bus/tl_instr_mem_o
add wave -noupdate -group xbar /ibex_simple_system/bus/tl_instr_mem_i
add wave -noupdate -group xbar /ibex_simple_system/bus/scanmode_i
add wave -noupdate -group xbar /ibex_simple_system/bus/unused_scanmode
add wave -noupdate -group xbar /ibex_simple_system/bus/tl_s1n_6_us_h2d
add wave -noupdate -group xbar /ibex_simple_system/bus/tl_s1n_6_us_d2h
add wave -noupdate -group xbar /ibex_simple_system/bus/dev_sel_s1n_6
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 309
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {524288 ps}
