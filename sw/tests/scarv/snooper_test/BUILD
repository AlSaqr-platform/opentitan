# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:opentitan.bzl", "OPENTITAN_CPU", "opentitan_ram_binary")

package(default_visibility = ["//visibility:public"])

opentitan_ram_binary(
    name = "snooper_test",
    srcs = ["snooper_test.c"],
    hdrs = ["snooper_test.h"],
    archive_symbol_prefix = "snooper_test",
    testonly = True,
    deps = [
        "//sw/tests/common:common",
        "//sw/tests/common:regs",
        "//sw/tests/common:linker",
        "//sw/tests/common:crt",
        "//sw/device/lib/base:memory",
        "//sw/device/lib/base:mmio",
        "//sw/device/lib/dif:rv_plic",
        "//sw/device/lib/runtime:irq",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",

    ],
)
