SCARV_TESTS_DIR := $(TESTS_DIR)/scarv

SCARV_TEST_NAMES := \
	cluster_offload \
	mbox_ext_irq

OT_TESTS += $(foreach test,$(SCARV_TEST_NAMES),$(SCARV_TESTS_DIR)/$(test)/$(test).elf)

PULP_SW_DIR  := $(PULP_REGR_DIR)
PULP_TEST_DIRS := $(filter-out %deeploy %neureka, $(wildcard $(PULP_SW_DIR)/opentitan-cluster/*))
NEUREKA_TEST_DIRS := $(wildcard $(PULP_SW_DIR)/opentitan-cluster/neureka/*)
DEEPLOY_TEST_DIRS := $(wildcard $(PULP_SW_DIR)/opentitan-cluster/deeploy/*/*)
