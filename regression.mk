TARGET ?= opentitan-cluster

.PHONY: test-rt-$(TARGET)
## Run Carfield tests on pulp-runtime
test-rt-$(TARGET): $(PULP_RUNTIME_DIR) $(PULP_REGR_DIR)
	$(bwruntest)  -t 3600 --yaml --max-procs 2 \
		$(TARGET).yaml
