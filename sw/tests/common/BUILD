# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:opentitan.bzl", "OPENTITAN_CPU", "opentitan_rom_binary")
load("//rules:exclude_files.bzl", "exclude_files")
load("//rules:linker.bzl", "ld_library")
load(
    "//rules:opentitan_test.bzl",
    "manual_test",
    "opentitan_functest",
)
load("//rules:cross_platform.bzl", "dual_cc_library", "dual_inputs")
load("@rules_pkg//pkg:mappings.bzl", "pkg_files")
config_setting(
    name = "no_standalone",
    values = {"define": "NO_STANDALONE=1"},
)

package(default_visibility = ["//visibility:public"])

ld_library(
    name = "linker",
    script = "link.ld",
    testonly = True,
)

cc_library(
    name = "common",
    srcs = ["utils.c", "host_uart.c"],
    hdrs = ["utils.h", "mailboxes.h", "host_uart.h", "idma.h"],
    copts = [
    ]
    + select({
        ":no_standalone": [
            "-DNO_STANDALONE",
        ],
        "//conditions:default": [],
    }),
    includes = ["."],
    target_compatible_with = [OPENTITAN_CPU],
    alwayslink = True,
)

cc_library(
    name = "crt",
    srcs = [
        "crt0.S",
    ],
    target_compatible_with = [OPENTITAN_CPU],
    alwayslink = True,
)

cc_library(
    name = "regs",
    # Headers are sourced from the Cheshire repository via the @cheshire_sw
    # external repository, which is resolved at build time through the CHS_ROOT
    # environment variable (set to `bender path cheshire` in the Carfield build).
    # No files are hardcoded or duplicated inside OpenTitan.
    deps = ["@cheshire_sw//:regs"],
    target_compatible_with = [OPENTITAN_CPU],
)


