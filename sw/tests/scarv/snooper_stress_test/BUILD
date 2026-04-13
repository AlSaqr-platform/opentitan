# Copyright 2024 ETH Zurich, University of Bologna and Fondazione Chips-IT.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:opentitan.bzl", "OPENTITAN_CPU", "opentitan_ram_binary")

package(default_visibility = ["//visibility:public"])

opentitan_ram_binary(
    name = "snooper_stress_test",
    srcs = ["snooper_stress_test.c"],
    hdrs = ["snooper_stress_test.h"],
    archive_symbol_prefix = "snooper_stress_test",
    testonly = True,
    deps = [
        "//sw/tests/common:common",
        "//sw/tests/common:regs",
        "//sw/tests/common:linker",
        "//sw/tests/common:crt",
        "//sw/device/lib/base:memory",
        "//sw/device/lib/base:mmio",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
    ],
)
