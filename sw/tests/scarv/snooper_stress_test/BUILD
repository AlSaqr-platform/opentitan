# Copyright 2024 ETH Zurich, University of Bologna and Fondazione Chips-IT.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:opentitan.bzl", "opentitan_ram_binary")

package(default_visibility = ["//visibility:public"])

# Enable with:
#   bazel build //path/to:snooper_stress_test --define NO_STANDALONE=1
config_setting(
    name = "no_standalone",
    values = {"define": "NO_STANDALONE=1"},
)

opentitan_ram_binary(
    name = "snooper_stress_test",
    srcs = ["snooper_stress_test.c", "snooper_stress_test.h"],
    hdrs = ["snooper_stress_test.h"],
    includes = ["."],
    copts = [
    ]
    + select({
        ":no_standalone": [
            "-DNO_STANDALONE",
            "-Wno-int-conversion",
            "-Wno-implicit-function-declaration",
            "-Wno-incompatible-pointer-types",
            "-Wno-implicit-int",
        ],
        "//conditions:default": [],
    }),
    archive_symbol_prefix = "snooper_stress_test",
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
