GENERIC_TESTS += $(TESTS_DIR)/cluster_offload/cluster_offload.elf
GENERIC_TESTS += $(TESTS_DIR)/mbox_ext_irq/mbox_ext_irq.elf

$(TESTS_DIR)/cluster_offload/cluster_offload.elf:
	$(MAKE) -C $(TESTS_DIR)/cluster_offload clean all

$(TESTS_DIR)/mbox_ext_irq/mbox_ext_irq.elf:
	$(MAKE) -C $(TESTS_DIR)/mbox_ext_irq clean all

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
