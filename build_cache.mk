# build_cache.mk provides a content-addressed cache for makefile targets

_mkfile_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
_cached_run.sh := $(_mkfile_dir)cached-run.sh

# Cache configuration
BUILD_CACHE_DIR ?= .cas
export BUILD_CACHE_DIR

# Macro for cached builds
# The assumption is this will be paired hash_target for dependencies, so this consumes the marker file implicitly
define cas_run
	@$(_cached_run.sh) $^ $@ '$(1)'
endef

# Cache management targets
.PHONY: cache-stats cache-clean
cache-stats:
	@echo "Cache directory: $(BUILD_CACHE_DIR)"
	@if [ -d "$(BUILD_CACHE_DIR)" ]; then \
		echo "Cache entries:"; \
		echo "  by-content: $$(ls $(BUILD_CACHE_DIR)/by-content | wc -l)"; \
		echo "  by-deps: $$(ls $(BUILD_CACHE_DIR)/by-deps | wc -l)"; \
		echo "Cache size: $$(du -sh $(BUILD_CACHE_DIR) | cut -f1)"; \
	else \
		echo "Cache directory does not exist"; \
	fi

cache-gc:
	find $(BUILD_CACHE_DIR) -type f -mtime +7 -delete
	find $(BUILD_CACHE_DIR) -type d -empty -delete

