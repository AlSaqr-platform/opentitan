SCARV_TESTS := \
	cfi_syscall_cluster \
	cluster_offload \
	idma_test \
	mbox_ext_irq \
	mbox_host \
	mbox_wu_cluster \
	snooper_stress_test

PULP_SW_DIR  := $(PULP_REGR_DIR)
PULP_TEST_DIRS := $(filter-out %deeploy %neureka, $(wildcard $(PULP_SW_DIR)/opentitan-cluster/*))
NEUREKA_TEST_DIRS := $(wildcard $(PULP_SW_DIR)/opentitan-cluster/neureka/*)
DEEPLOY_TEST_DIRS := $(wildcard $(PULP_SW_DIR)/opentitan-cluster/deeploy/*/*)
