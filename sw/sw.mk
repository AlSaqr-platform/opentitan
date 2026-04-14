SCARV_TESTS_DIR := $(TESTS_DIR)/scarv

SCARV_TEST_NAMES := \
	cluster_offload \
	mbox_ext_irq

OT_TESTS += $(foreach test,$(SCARV_TEST_NAMES),$(SCARV_TESTS_DIR)/$(test)/$(test).elf)

PULP_SW_DIR  := $(PULP_REGR_DIR)
PULP_TEST_DIRS := $(filter-out %deeploy %neureka, $(wildcard $(PULP_SW_DIR)/opentitan-cluster/*))
NEUREKA_TEST_DIRS := $(wildcard $(PULP_SW_DIR)/opentitan-cluster/neureka/*)
DEEPLOY_TEST_DIRS := $(wildcard $(PULP_SW_DIR)/opentitan-cluster/deeploy/*/*)

PULP_BUILD_TARGETS := $(addsuffix /build,$(PULP_TEST_DIRS))
NEUREKA_BUILD_TARGETS := $(addsuffix /build,$(NEUREKA_TEST_DIRS))
DEEPLOY_BUILD_TARGETS := $(addsuffix /build,$(DEEPLOY_TEST_DIRS))

$(PULP_SW_DIR)/opentitan-cluster/deeploy/%/build:
	$(MAKE) -C $(PULP_SW_DIR)/opentitan-cluster/deeploy/$* clean pulp_nn all

$(PULP_SW_DIR)/opentitan-cluster/neureka/%/build:
	$(MAKE) -C $(PULP_SW_DIR)/opentitan-cluster/neureka/$* clean all MODE=1

$(PULP_SW_DIR)/%/build:
	$(MAKE) -C $(PULP_SW_DIR)/$* clean all

pulpd-sw-all: $(PULP_BUILD_TARGETS) $(NEUREKA_BUILD_TARGETS) $(DEEPLOY_BUILD_TARGETS)
