# build_cache.mk provides a content-addressed cache for makefile targets

_mkfile_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
_cached_run.sh := $(_mkfile_dir)cached-run.sh

# Cache configuration
BUILD_CACHE_DIR ?= .cas
export BUILD_CACHE_DIR

# Macro for cached builds
# The assumption is this will be paired hash_target for dependencies, so this consumes the marker file implicitly
define cas_run
$(eval _cas_normalized_cmd := $(subst $@,TARGET,$(1)))
	@$(_cached_run.sh) $^ $@ '$(1)' '$(_cas_normalized_cmd)'
endef

cache-gc:
	find $(BUILD_CACHE_DIR) -type f -mtime +7 -delete
	find $(BUILD_CACHE_DIR) -type d -empty -delete

