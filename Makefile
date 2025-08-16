.ONESHELL:
SHELL := /bin/bash
AUTONITY_REPO      := https://github.com/autonity/autonity.git
AUTONITY_DIR       := autonity
AUTONITY_TAG       := v1.1.2

AUTONITY_ABI_DIR   := autonity-abi
ABI_DIR            := $(AUTONITY_ABI_DIR)/abi
DEV_DIR            := $(AUTONITY_ABI_DIR)/docdev
USER_DIR           := $(AUTONITY_ABI_DIR)/docuser

CONTRACTS          := UpgradeManager SupplyControl Stabilization OmissionAccountability Oracle LiquidLogic InflationController Autonity Auctioneer ACU Accountability

.PHONY: all clone build prepare-artifacts clean

all: prepare-artifacts

clone:
	@if [ ! -d "$(AUTONITY_DIR)" ]; then
		echo "Cloning Autonity repository..."
		git clone $(AUTONITY_REPO) $(AUTONITY_DIR)
	else
		echo "Autonity directory already exists."
	fi
	cd $(AUTONITY_DIR)
	git checkout tags/$(AUTONITY_TAG) -b $(AUTONITY_TAG) 2>/dev/null || git checkout tags/$(AUTONITY_TAG)

build: clone
	echo "Building contracts..."
	cd $(AUTONITY_DIR)
	go mod tidy
	make contracts

prepare-artifacts: build
	echo "Preparing ABI/devdoc/userdoc as JSON into $(AUTONITY_ABI_DIR)..."
	mkdir -p "$(ABI_DIR)" "$(DEV_DIR)" "$(USER_DIR)"

	# Bersihkan file lama
	rm -f "$(ABI_DIR)"/*.json "$(DEV_DIR)"/*.json "$(USER_DIR)"/*.json || true

	for contract in $(CONTRACTS); do
		src_base="$(AUTONITY_DIR)/params/generated/$${contract}"
		abi_src="$$src_base.abi"
		dev_src="$$src_base.docdev"
		user_src="$$src_base.docuser"
		abi_dst="$(ABI_DIR)/$${contract}.json"
		dev_dst="$(DEV_DIR)/$${contract}.json"
		user_dst="$(USER_DIR)/$${contract}.json"

		# ABI -> .json
		if [ -f "$$abi_src" ]; then
			echo "ABI      : $$contract -> $$abi_dst"
			cp "$$abi_src" "$$abi_dst"
		else
			echo "Warning  : ABI for $$contract not found at $$abi_src"
		fi

		# devdoc -> .json
		if [ -f "$$dev_src" ]; then
			echo "devdoc   : $$contract -> $$dev_dst"
			cp "$$dev_src" "$$dev_dst"
		else
			echo "Warning  : devdoc for $$contract not found at $$dev_src"
		fi

		# userdoc -> .json
		if [ -f "$$user_src" ]; then
			echo "userdoc  : $$contract -> $$user_dst"
			cp "$$user_src" "$$user_dst"
		else
			echo "Warning  : userdoc for $$contract not found at $$user_src"
		fi
	done

	echo ""
	echo "=== Summary ==="
	echo "ABI files   in $(ABI_DIR):"
	ls -lah "$(ABI_DIR)" || true
	echo ""
	echo "devdoc files in $(DEV_DIR):"
	ls -lah "$(DEV_DIR)" || true
	echo ""
	echo "userdoc files in $(USER_DIR):"
	ls -lah "$(USER_DIR)" || true

clean:
	echo "Cleaning up..."
	rm -rf "$(AUTONITY_DIR)" "$(AUTONITY_ABI_DIR)"
