# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:opentitan.bzl", "opentitan_ram_binary")

package(default_visibility = ["//visibility:public"])

opentitan_ram_binary(
    name = "hello_world",
    srcs = ["hello_world.c"],
    hdrs = ["hello_world.h"],
    archive_symbol_prefix = "hello_world",
    testonly = True,
    deps = [
        "//sw/tests/common:common",
        "//sw/tests/common:linker",
        "//sw/tests/common:crt",
    ],
)
