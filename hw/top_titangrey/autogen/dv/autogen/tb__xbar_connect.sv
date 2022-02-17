// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// tb__xbar_connect generated by `tlgen.py` tool

xbar_main dut();

`DRIVE_CLK(clk_main_i)

initial force dut.clk_main_i = clk_main_i;

// TODO, all resets tie together
initial force dut.rst_main_ni = rst_n;

// Host TileLink interface connections
`CONNECT_TL_HOST_IF(core_instr, dut, clk_main_i, rst_n)
`CONNECT_TL_HOST_IF(core_data, dut, clk_main_i, rst_n)

// Device TileLink interface connections
`CONNECT_TL_DEVICE_IF(data_mem, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(sim_ctrl, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(rom_ctrl, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(kmac, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(keymgr, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(otp_ctrl, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(hmac, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(lc_ctrl, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(sram_ctrl, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(flash_ctrl, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(uart, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(clkmgr, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(sysrst_ctrl, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(rstmgr, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(pwrmgr, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(alert_handler, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(rv_dm, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(rv_plic, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(edn, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(otbn, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(aes, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(csrng, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(entropy_src, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(gpio, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(spi_device, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(spi_host, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(testrst, dut, clk_main_i, rst_n)
`CONNECT_TL_DEVICE_IF(instr_mem, dut, clk_main_i, rst_n)
