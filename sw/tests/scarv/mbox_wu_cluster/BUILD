# Copyright 2026 ETH Zurich, University of Bologna and Fondazione Chips-IT.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:opentitan.bzl", "opentitan_ram_binary")

package(default_visibility = ["//visibility:public"])

opentitan_ram_binary(
    name = "mbox_wu_cluster",
    srcs = ["mbox_wu_cluster.c"],
    hdrs = ["mbox_wu_cluster.h"],
    archive_symbol_prefix = "mbox_wu_cluster",
    testonly = True,
    deps = [
        "//sw/tests/common:common",
        "//sw/tests/common:linker",
        "//sw/tests/common:crt",
    ],
)
