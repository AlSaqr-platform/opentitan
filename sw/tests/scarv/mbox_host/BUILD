# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:opentitan.bzl", "opentitan_ram_binary")

package(default_visibility = ["//visibility:public"])

# Enable with:
#   bazel build //path/to:mbox_ext_irq --define NO_STANDALONE=1
config_setting(
    name = "no_standalone",
    values = {"define": "NO_STANDALONE=1"},
)

opentitan_ram_binary(
    name = "mbox_host",
    srcs = ["mbox_host.c", "mbox_host.h"],
    hdrs = ["mbox_host.h"],
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
    archive_symbol_prefix = "mbox_host",
    deps = [
        "//sw/tests/common:common",
        "//sw/tests/common:linker",
        "//sw/tests/common:crt",
        "//sw/device/lib/base:memory",
        "//sw/device/lib/base:mmio",
        "//sw/device/lib/dif:rv_plic",
        "//sw/device/lib/runtime:irq",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
    ],
)
