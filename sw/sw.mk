SCARV_TESTS := \
	cluster_offload \
	mbox_ext_irq \
	idma_test

PULP_SW_DIR  := $(PULP_REGR_DIR)
<<<<<<< HEAD
=======

GENERIC_TEST := $(TESTS_DIR)/cluster_offload
SNOOPER_TEST := $(TESTS_DIR)/snooper_test

$(GENERIC_TEST)/cluster_offload.elf:
	$(MAKE) -C $(GENERIC_TEST) clean all
$(SNOOPER_TEST)/snooper_test.elf:
	$(MAKE) -C $(SNOOPER_TEST) clean all

>>>>>>> b1d99340e5 (Added Snooper test, generated rv_plic_regs.h)
PULP_TEST_DIRS := $(filter-out %deeploy %neureka, $(wildcard $(PULP_SW_DIR)/opentitan-cluster/*))
NEUREKA_TEST_DIRS := $(wildcard $(PULP_SW_DIR)/opentitan-cluster/neureka/*)
DEEPLOY_TEST_DIRS := $(wildcard $(PULP_SW_DIR)/opentitan-cluster/deeploy/*/*)
