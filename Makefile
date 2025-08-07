AUTONITY_REPO      := https://github.com/autonity/autonity.git
AUTONITY_DIR       := autonity
AUTONITY_TAG       := v1.1.2
OUTPUT_DIR         := abi-json
CONTRACTS          := UpgradeManager SupplyControl Stabilization OmissionAccountability Oracle LiquidLogic InflationController Autonity Auctioneer ACU Accountability

.PHONY: all clone build prepare-json clean

all: prepare-json

clone:
	@if [ ! -d "$(AUTONITY_DIR)" ]; then \
		echo "Cloning Autonity repository..."; \
		git clone $(AUTONITY_REPO) $(AUTONITY_DIR); \
	else \
		echo "Autonity directory already exists."; \
	fi
	cd $(AUTONITY_DIR) && git checkout tags/$(AUTONITY_TAG) -b $(AUTONITY_TAG)

build: clone
	@echo "Building contracts..."
	cd $(AUTONITY_DIR) && go mod tidy && make contracts

prepare-json: build
	@echo "Preparing selected ABI files as JSON..."
	mkdir -p $(OUTPUT_DIR)
	rm -f $(OUTPUT_DIR)/*.json
	@for contract in $(CONTRACTS); do \
		src_file="$(AUTONITY_DIR)/params/generated/$${contract}.abi"; \
		dest_file="$(OUTPUT_DIR)/$${contract}.json"; \
		if [ -f "$${src_file}" ]; then \
			echo "Copying $${contract}.json..."; \
			cp "$${src_file}" "$${dest_file}"; \
		else \
			echo "Warning: ABI file for $${contract} not found."; \
		fi \
	done
	@echo "Generated JSON files:"
	ls -lah $(OUTPUT_DIR)

clean:
	@echo "Cleaning up..."
	rm -rf $(AUTONITY_DIR) $(OUTPUT_DIR)
