# Copyright 2026 Fondazione Chips-IT.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:opentitan.bzl", "opentitan_ram_binary")

package(default_visibility = ["//visibility:public"])

opentitan_ram_binary(
    name = "cfi_syscall_cluster",
    srcs = [
        "cfi_syscall_cluster.c",
    ],
    hdrs = [
        "cfi_syscall_cluster.h",
    ],
    archive_symbol_prefix = "cfi_syscall_cluster",
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
