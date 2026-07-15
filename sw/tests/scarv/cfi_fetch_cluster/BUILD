# Copyright 2026 Fondazione Chips-IT.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:opentitan.bzl", "opentitan_ram_binary")

package(default_visibility = ["//visibility:public"])

config_setting(
    name = "no_standalone",
    values = {"define": "NO_STANDALONE=1"},
)

opentitan_ram_binary(
    name = "cfi_fetch_cluster",
    srcs = [
        "cfi_fetch_cluster.c",
        "cfi_fetch_cluster.h",
    ],
    hdrs = ["cfi_fetch_cluster.h"],
    includes = ["."],
    copts = select({
        ":no_standalone": [
            "-DNO_STANDALONE",
            "-Wno-int-conversion",
            "-Wno-implicit-function-declaration",
            "-Wno-incompatible-pointer-types",
            "-Wno-implicit-int",
        ],
        "//conditions:default": [],
    }),
    archive_symbol_prefix = "cfi_fetch_cluster",
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
