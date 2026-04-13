# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:opentitan.bzl", "opentitan_ram_binary")

package(default_visibility = ["//visibility:public"])

opentitan_ram_binary(
    name = "mbox_test_host",
    srcs = ["mbox_test_host.c"],
    hdrs = ["mbox_test_host.h"],
    archive_symbol_prefix = "mbox_test_host",
    testonly = True,
    deps = [
        "//sw/tests/common:common",
        "//sw/tests/common:linker",
        "//sw/tests/common:crt",
    ],
)
