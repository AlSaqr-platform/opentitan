# Copyright (c) 2022 ETH Zurich and University of Bologna
# Copyright and related rights are licensed under the Solderpad Hardware
# License, Version 0.51 (the "License"); you may not use this file except in
# compliance with the License.  You may obtain a copy of the License at
# http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
# or agreed to in writing, software, hardware and materials distributed under
# this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
#
#

load("//rules:opentitan.bzl", "OPENTITAN_CPU", "opentitan_ram_binary")
load("//rules:exclude_files.bzl", "exclude_files")
load("//rules:linker.bzl", "ld_library")
load(
    "//rules:opentitan_test.bzl",
    "manual_test",
    "opentitan_functest",
)
load("//rules:cross_platform.bzl", "dual_cc_library", "dual_inputs")
load("@rules_pkg//pkg:mappings.bzl", "pkg_files")

package(default_visibility = ["//visibility:public"])


opentitan_ram_binary(
    name = "sram_hmac_smoketest",
    srcs = [
    	"sram_hmac_smoketest.c",
    ],
    hdrs = [
        "sram_hmac_smoketest.h",
    ],
    archive_symbol_prefix = "sram_hmac_smoketest",
    testonly = True,
    deps = [
        "//sw/tests/opentitan/common:common",
        "//sw/tests/opentitan/common:linker",
        "//sw/tests/opentitan/common:crt",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/lib/base:memory",
        "//sw/device/lib/base:mmio",
        "//sw/device/lib/dif:hmac",
        "//sw/device/lib/testing:hmac_testutils",
	"//sw/device/silicon_creator/rom:alsaqr_print"

    ],
)