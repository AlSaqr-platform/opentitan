# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Generate a baremetal application

# Name of the program $(PROGRAM).c will be added as a source file
PROGRAM = snooper_test

# STANDALONE MODE
ifneq ($(NO_STANDALONE),)
PROGRAM_CFLAGS += -DNO_STANDALONE
PROGRAM_CFLAGS += -Wno-int-conversion -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wno-implicit-int -g -O0 -DDEBUG
endif
PROGRAM_CFLAGS += -g -O0 -DDEBUG

PROGRAM_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
$(info PROGRAM_DIR is: $(PROGRAM_DIR))

PROGRAM_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# --- ADDED FOR OPENTITAN LIBRARIES ---
# Since this Makefile is inside sw/tests/snooper_test, the OpenTitan root is 3 levels up.
# abspath resolves the "../../.." into a clean, absolute path.
OPENTITAN_DIR := $(abspath $(PROGRAM_DIR)/../../..)

# Add the OpenTitan root to the include paths
PROGRAM_CFLAGS += -I$(OPENTITAN_DIR)


# ------------------------------------------------

# Any extra source files to include in the build. Use the upper case .S
# extension for assembly files

utils_dir = $(PROGRAM_DIR)/inc/
directories = drivers/inc drivers/src string_lib/inc string_lib/src
EXTRA_SRCS = $(foreach d, $(directories), -I$(utils_dir)$d)
# Add the specific OpenTitan library source files to be compiled using EXTRA_SRCS
EXTRA_SRCS += $(OPENTITAN_DIR)/sw/device/lib/dif/dif_rv_plic.c
EXTRA_SRCS += $(OPENTITAN_DIR)/sw/device/lib/runtime/irq.c       
EXTRA_SRCS += $(OPENTITAN_DIR)/sw/device/lib/base/mmio.c
EXTRA_SRCS += $(OPENTITAN_DIR)/sw/device/lib/base/bitfield.c
EXTRA_SRCS += $(OPENTITAN_DIR)/sw/device/lib/base/memory.c  # <--- Added for memcpy & misalignment32_of

include ${PROGRAM_DIR}/../common/common.mk

# Override the common.mk linking rule to safely append libgcc at the end
# without poisoning the $(OBJS) variable used by 'make clean'.
$(PROGRAM).elf: $(OBJS) $(LINKER_SCRIPT)
	$(CC) $(CFLAGS) -T $(LINKER_SCRIPT) $(OBJS) -lgcc -o $@