.PHONY: build-all build-extension clean

PG_VERSION ?= 16

build-all:
	@for ext in $$(yq e '.extensions | keys | .[]' extensions.yml); do \
		$(MAKE) build-extension EXTENSION=$$ext PG_VERSION=$(PG_VERSION); \
	done

build-extension:
	@if [ -z "$(EXTENSION)" ]; then \
		echo "Usage: make build-extension EXTENSION=<extension-name> [PG_VERSION=<version>]"; \
		exit 1; \
	fi
	@./scripts/build-extension.sh $(EXTENSION) $(PG_VERSION)

clean:
	@rm -rf build artifacts