# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

PROGRAM = snooper_fetch_test

ifneq ($(NO_STANDALONE),)
PROGRAM_CFLAGS += -DNO_STANDALONE
PROGRAM_CFLAGS += -Wno-int-conversion -Wno-implicit-function-declaration \
                  -Wno-incompatible-pointer-types -Wno-implicit-int -g -O0 -DDEBUG
endif
PROGRAM_CFLAGS += -g -O0 -DDEBUG

PROGRAM_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
$(info PROGRAM_DIR is: $(PROGRAM_DIR))

OPENTITAN_DIR := $(abspath $(PROGRAM_DIR)/../../../..)

PROGRAM_CFLAGS += -I$(OPENTITAN_DIR)
PROGRAM_CFLAGS += -I$(OPENTITAN_DIR)/hw/top_earlgrey/sw/autogen

include ${PROGRAM_DIR}/../../common/common.mk
