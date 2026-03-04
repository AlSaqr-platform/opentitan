PULP_SW_DIR  := $(PULP_REGR_DIR)

GENERIC_TEST := $(TESTS_DIR)/cluster_offload

$(GENERIC_TEST)/cluster_offload.elf:
	$(MAKE) -C $(GENERIC_TEST) clean all

PULP_TEST_DIRS := $(wildcard $(PULP_SW_DIR)/opentitan-cluster/*)

PULP_BUILD_TARGETS := $(addsuffix /build,$(PULP_TEST_DIRS))

$(PULP_SW_DIR)/%/build:
	$(MAKE) -C $(PULP_SW_DIR)/$* clean all

pulpd-sw-all: $(PULP_BUILD_TARGETS)
