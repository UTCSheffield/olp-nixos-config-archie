NIXOS_CONFIG=iso.nix
NIX_ATTR=config.system.build.isoImage
NIXPKGS='<nixpkgs/nixos>'
OUTPUT_DIR=./nixout
OUTPUT_DIR_REAL=./result

build:
	@echo "Cleaning..."
	make clean
	@echo "Building NixOS ISO..."
	nix-build $(NIXPKGS) -A $(NIX_ATTR) -I nixos-config=$(NIXOS_CONFIG) --out-link $(OUTPUT_DIR)
	cp -r -L $(OUTPUT_DIR) $(OUTPUT_DIR_REAL)
	rm -rf ${OUTPUT_DIR}

clean:
	@echo "Cleaning build outputs..."
	sudo rm -rf $(OUTPUT_DIR) $(OUTPUT_DIR_REAL)
