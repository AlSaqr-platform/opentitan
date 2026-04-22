# Copyright 2026 ETH Zurich, University of Bologna and Fondazione Chips-IT.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:opentitan.bzl", "opentitan_ram_binary")

package(default_visibility = ["//visibility:public"])

opentitan_ram_binary(
    name = "ot_clk_div_test",
    srcs = [
        "ot_clk_div_test.c",
    ],
    hdrs = [
        "ot_clk_div_test.h",
    ],
    archive_symbol_prefix = "ot_clk_div_test",
    deps = [
        "//sw/tests/common:common",
        "//sw/tests/common:linker",
        "//sw/tests/common:crt",
    ],
)
