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
ROOT_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
TECH_DIR := $(ROOT_DIR)/target/gf22
VER_DIR  := $(TECH_DIR)/sourcecode/verilog

# required to source the verilog models of the tech memories
include $(TECH_DIR)/tech.mk

GIT ?= git
BENDER ?= bender
VSIM ?= vsim
DPI-LIB ?= work-dpi
run_script := scripts/opentitan_start.tcl
SRAM ?= ""
BOOTMODE ?= 0
QUESTA =
IDMA_ROOT ?= $(shell $(BENDER) path idma)
QUESTASIM_HOME ?= /tools/siemens/questa_2022.3/questasim
BENDER_GIT_DIR ?= .bender/git/checkouts

cl-bin         ?= none
OT_CLUSTER     = $(cl-bin)

library        ?= work
dpi-library    ?= work-dpi

# Ensure half-built targets are purged
.DELETE_ON_ERROR:

# --------------
# RTL SIMULATION
# --------------
top_level ?= testbench_asynch_astral

vsim_args += +notimingchecks +nospecify

ifdef flash_preload
  VLOG_ARGS += +define+FLASH_PRELOAD
endif

ifdef jtag_sec_boot
  VLOG_ARGS += +define+JTAG_SEC_BOOT
endif

ifdef vip
compile_script := scripts/compile_opentitan_vip.tcl
else
compile_script := scripts/compile_opentitan.tcl
endif

ifdef nogui
	GUI := -c
endif

ifeq ($(debug), 1)
vopt_args += -debug +designfile
vsim_args += -qwavedb=+signal+memory
else
vsim_args += -c
do_command += run -all
endif

VLOG_ARGS += -incr -64 -nologo -quiet -suppress vlog-2583 -suppress vlog-13314 \"+incdir+\$$ROOT/hw/include\" +nospecify +notimingchecks -timescale \"1 ns / 1 ps\"
XVLOG_ARGS += -64bit -compile -vtimescale 1ns/1ns -quiet +nospecify +notimingchecks

define generate_vsim
	echo 'set ROOT [file normalize [file dirname [info script]]/$3]' > $1
	$(BENDER) script $(VSIM) --vlog-arg="$(VLOG_ARGS)" $2 | grep -v "set ROOT" >> $1
	echo >> $1
endef

.PHONY: init build sim update clean secure_boot_jtag secure_boot_spi

generate_idma_rtl:
	$(MAKE) -C $(shell find $(BENDER_GIT_DIR) -type d -name 'idma*' | head -n 1) idma_hw_all

build:  $(dpi-library)/elfloader.so scripts/compile_opentitan.tcl scripts/compile_opentitan_vip.tcl $(OT_ROOT)/hw/tb/vips
	$(QUESTA) qsim -c -do 'source $(compile_script); quit'

build_tech_mem: build
	vlog -incr -work $(library) ${VER_DIR}/../tc_sram.sv
	vlog -incr -work $(library) ${VER_DIR}/std_primitives.v

	$(foreach mem,$(REGFILECUTS),\
		vlog -incr +define+INITIALIZE_MEM -work $(library) $(VER_DIR)/$(mem).v;\
	)
	$(foreach mem,$(SRAMCUTS),\
		vlog -incr +define+INITIALIZE_MEM -work $(library) $(VER_DIR)/$(mem).v;\
	)

sim_no_gui: generate_idma_rtl build
	qopt -work $(library) ${top_level} -o ${top_level}_opt
	qsim -c ${top_level}_opt -t 1ps -suppress 3999 -suppress 8360 \
	-do "$(do_command)" \
	+SRAM=${SRAM} +OT_CLUSTER=${OT_CLUSTER} +BOOTMODE=${BOOTMODE} -sv_lib $(dpi-library)/elfloader

sim_rtl: generate_idma_rtl build
	qopt -debug +designfile -work $(library) ${top_level} -o ${top_level}_opt
	qsim -qwavedb=+signal+memory ${top_level}_opt -t 1ps -suppress 3999 -suppress 8360 \
	-do "set StdArithNoWarnings 1; set NumericStdNoWarnings 1;"	\
	+SRAM=${SRAM} +OT_CLUSTER=${OT_CLUSTER} +BOOTMODE=${BOOTMODE} -sv_lib $(dpi-library)/elfloader

sim_rtl_tech_mem: generate_idma_rtl build_tech_mem
	qopt  $(vopt_args) -work $(library) ${top_level} -o ${top_level}_opt
	qsim  $(vsim_args) ${top_level}_opt -t 1ps -suppress 3999 -suppress 8360 \
	$(vsim_args) +init_mem_data=0 \
	-do "$(do_command)" \
	+SRAM=${SRAM} +OT_CLUSTER=${OT_CLUSTER} +BOOTMODE=${BOOTMODE} -sv_lib $(dpi-library)/elfloader

sim_gls:
	$(MAKE) -C target/gf22/questasim int_gls_sim

update:
	$(BENDER) update

clean:
	rm -rf scripts/compile*
	rm -rf work
	rm -rf work-dpi
	rm -rf *.log
	rm -rf transcript
	rm -rf modelsim.ini
	rm -rf vsim.wlf
	rm -rf uart

common_defs  += -D FEATURE_ICACHE_STAT
common_targs += -t cv32e40p_use_ff_regfile
common_defs  += -D PRIVATE_ICACHE
common_defs  += -D HIERARCHY_ICACHE_32BIT
common_defs  += -D ICACHE_USE_FF
common_defs  += -D CLUSTER_ALIAS

scripts/compile_opentitan.tcl: Bender.yml
	$(BENDER) script $(VSIM) --vlog-arg="$(VLOG_ARGS)" -t use_idma -t rtl -t test -t snitch_cluster $(common_defs) $(common_targs) > $@
# 	$(call generate_vsim, $@, -t use_idma -t rtl -t test -t snitch_cluster ,..)

scripts/compile_opentitan_vip.tcl: Bender.yml
	$(call generate_vsim, $@, -t use_idma -t rtl -t test_ot_vip -t snitch_cluster, ..)

secure_boot_jtag:
	make clean sim BOOTMODE=0 SRAM=sw/tests/opentitan/flash_preload_hmac_smoketest/flash_preload_hmac_smoketest.elf jtag_sec_boot=1

secure_boot_spi:
	make clean sim BOOTMODE=1 vip=1

$(OT_ROOT)/hw/tb/vips:
	rm -rf $@
	mkdir $@
	wget --no-check-certificate --content-disposition "https://freemodelfoundry.com/fmf_vlog_models/flash/s25fs256s.v" -O ./hw/tb/vips/s25fs256s.v

init: update scripts/compile_opentitan.tcl scripts/compile_opentitan_vip.tcl $(OT_ROOT)/hw/tb/vips

# DPI
dpi := $(patsubst hw/tb/dpi/%.cc, ${dpi-library}/%.o, $(wildcard hw/tb/dpi/*.cc))


dpi_hdr := $(wildcard hw/tb/dpi/*.h)
dpi_hdr := $(addprefix $(root-dir), $(dpi_hdr))
CFLAGS := -I$(QUESTASIM_HOME)/include         \
          -I$(RISCV)/include                  \
          -std=c++11 -Ihw/tb/dpi -O3

$(dpi-library)/elfloader.o: $(dpi_hdr)
	mkdir -p $(dpi-library)
	$(CXX) -shared -fPIC -std=c++0x -Bsymbolic $(CFLAGS) -c  hw/tb/dpi/elfloader.cc -o $@

$(dpi-library)/elfloader.so: $(dpi)
	$(CXX) -shared -m64 -o $(dpi-library)/elfloader.so $? -L$(RISCV)/lib -Wl,-rpath,$(RISCV)/lib
