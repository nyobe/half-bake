# cas.mk provides content-based dependency tracking for make targets.
# Instead of using file timestamps to detect changes, it uses SHA1 hashes
# and tracks the dependency list explicitly. This means:
#   - Rebuilds happen only when content actually changes
#   - Changes to the dependency list are detected and force rebuilds
#
# Enable verbose output to see why rebuilds happen:
#   make VERBOSE=1
#
# Usage:
#   target: $(call cas_inputs,target_name,dep1 dep2 dep3...)
#       build_command $(call cas_get_deps,%)
#
# Example:
#   main: $(call cas_inputs,main,main.go lib.go)
#       go build -o $@ $(call cas_get_deps,%.go)
#

# Creates a content based markerfile
# Args:
#   1: target name (used for naming the hash/marker files)
#   2: space-separated list of dependencies
define cas_inputs
$(eval $(call _cas_make_inputs_rule,$(1),$(2)))
.cas/$(1).deps
endef

# Internal: define hash rules for a target
define _cas_make_inputs_rule
# Export dependencies as an target specific env var, to avoid hitting argument list too long error when invoking sha1sum
.cas/$(1).deps: export DEPS = $(sort $(2))

# The marker file depends on all deps, but its timestamp will only be updated when their content changes
.cas/$(1).deps: $(2)
	@mkdir -p .cas
	@echo "$$$$DEPS" | tr ' ' '\n' | xargs sha1sum > $$@.tmp
	@if [ ! -f $$@ ] || ! cmp -s $$@.tmp $$@; then \
                if [ -n "$(VERBOSE)" ]; then echo "Updating $$@"; diff --unified $$@ $$@.tmp | grep '^[+-][^+-]' || true; fi; \
		mv $$@.tmp $$@; \
	else \
		if [ -n "$(VERBOSE)" ]; then echo "No changes for $$@"; fi; \
		rm $$@.tmp; \
	fi
endef

# Extract filtered dependencies from the marker file
cas_get_deps = $(filter $(1),$(shell cut -c 43- $^))

