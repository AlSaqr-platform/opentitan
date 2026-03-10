PULP_SW_DIR  := $(PULP_REGR_DIR)

CLUSTER_OFFLOAD_TEST := $(TESTS_DIR)/cluster_offload

$(CLUSTER_OFFLOAD_TEST)/cluster_offload.elf:
	$(MAKE) -C $(CLUSTER_OFFLOAD_TEST) clean all

PULP_TEST_DIRS := $(filter-out %deeploy, $(wildcard $(PULP_SW_DIR)/opentitan-cluster/*))
DEEPLOY_TEST_DIRS := $(wildcard $(PULP_SW_DIR)/opentitan-cluster/deeploy/*/*)

PULP_BUILD_TARGETS := $(addsuffix /build,$(PULP_TEST_DIRS))
DEEPLOY_BUILD_TARGETS := $(addsuffix /build,$(DEEPLOY_TEST_DIRS))

$(PULP_SW_DIR)/opentitan-cluster/deeploy/%/build:
	$(MAKE) -C $(PULP_SW_DIR)/opentitan-cluster/deeploy/$* clean pulp_nn all

$(PULP_SW_DIR)/%/build:
	$(MAKE) -C $(PULP_SW_DIR)/$* clean all

pulpd-sw-all: $(PULP_BUILD_TARGETS) $(DEEPLOY_BUILD_TARGETS)
