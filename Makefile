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

OT_ROOT    := $(shell pwd)
BAZEL_OUT  := $(OT_ROOT)/bazel-out/k8-fastbuild-ST-2cc462681f62/bin/
target     ?= opentitan

common_test_path  := sw/tests/$(target)

# MUST PROVIDE TEST NAME
defines     ?=
mem         ?= l3
PAYLOAD     ?= 1024
test_name   ?=
test_path   := $(common_test_path)/$(test_name)
destination := $(OT_ROOT)/$(test_path)/bazel-out/

bazel        := ./bazelisk.sh --output_user_root=$(OT_ROOT)/bazel-build/ build $(defines)
bazel_tests  := $(common_test_path)/$(test_name)

rom_path     := sw/device/silicon_creator/rom
rom_out_vmem :=$(BAZEL_OUT)/$(rom_path)/rom_with_fake_keys_sim_verilator.39.scr.vmem
rom_out_dis  :=$(BAZEL_OUT)/$(rom_path)/rom_with_fake_keys_sim_verilator.dis
rom_dest     :=$(OT_ROOT)/$(common_test_path)/bootrom/
rom_dis      := boot_rom.dis
rom_vmem     := boot_rom.vmem
bootrom_sv   := $(OT_ROOT)/hw/ip/rom_ctrl/rtl/boot_rom.sv

flash_bazel_output_vmem := $(BAZEL_OUT)/$(test_path)/$(test_name)_prog_sim_verilator.fake_test_key_0.signed.64.scr.vmem
flash_bazel_output_dis := $(BAZEL_OUT)/$(test_path)/$(test_name)_prog_sim_verilator.dis

sram_bazel_output_bin := $(BAZEL_OUT)/$(test_path)/$(test_name)_sim_verilator.elf
sram_bazel_output_dis := $(BAZEL_OUT)/$(test_path)/$(test_name)_sim_verilator.dis

include opentitan.mk

.PHONY: clean-sram
clean-sram:
	rm -rf  $(destination)

.PHONY:clean-flash
clean-flash:
	rm -rf  $(destination)

.PHONY: clean-rom
clean-rom:
	rm -rf  $(rom_dest)/* $(bootrom_sv)

.PHONY: bazel-compile-rom
bazel-compile-rom:
	$(bazel) --define DISABLE_VERILATOR_BUILD=true //sw/device/silicon_creator/rom:all

.PHONY: bazel-compile-test
bazel-compile-test:
	$(bazel) --define DISABLE_VERILATOR_BUILD=true //$(bazel_tests):all

.PHONY: compile-bazel-flash
compile-bazel-flash: bazel-compile-test clean-flash
	mkdir -p  $(destination)
	cp -r $(flash_bazel_output_vmem) $(destination)/$(test_name)_signed.vmem
	cp -r $(flash_bazel_output_dis)  $(destination)/$(test_name)_signed.dis

.PHONY: compile-bazel-sram
compile-bazel-sram:  bazel-compile-test clean-sram
	mkdir -p  $(destination)
	cp -r $(sram_bazel_output_bin) $(destination)/$(test_name).elf
	cp -r $(sram_bazel_output_dis) $(destination)/$(test_name).dis

.PHONY: compile-bazel-rom
compile-bazel-rom:   bazel-compile-rom clean-rom
	cp -r $(rom_out_vmem) $(rom_dest)/$(rom_vmem)
	cp -r $(rom_out_dis)  $(rom_dest)/$(rom_dis)
	python3 scripts/vmem_scripts/rom/gen_sec_bootrom.py  $(rom_dest)/$(rom_vmem) $(bootrom_sv)
	python3 scripts/vmem_scripts/rom/vmem2coe_rom.py  $(rom_dest)/$(rom_vmem) $(rom_dest)/boot_rom.coe

.PHONY: gen_flash_preload_vmem
flash-all: compile-bazel-flash
	python3 scripts/vmem_scripts/flash/vmem_datawidth_converter.py      $(destination)/$(test_name)_signed.vmem $(destination)
	python3 scripts/vmem_scripts/flash/vmem32_to_header32_converter.py  $(destination)/$(test_name)_signed.vmem $(destination)

build_bootrom:
	python3 scripts/vmem_scripts/rom/gen_sec_bootrom.py  $(rom_dest)/$(rom_vmem) $(bootrom_sv)
