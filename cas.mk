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
#   target: $(call cas_inputs,target,dep1 dep2 dep3...)
#       build_command $(call cas_get_deps,%)
#

# Creates a content based marker file
# Args:
#   1: target name (used for naming the hash/marker files)
#   2: space-separated list of dependencies
define cas_inputs
$(eval $(call _cas_make_inputs_rule,$(1),$(2)))\
.cas/inputs/$(1).hash
endef

# Internal: define hash rules for a target
define _cas_make_inputs_rule
# Track dependency list changes with a phony target
.PHONY: .cas/inputs/$(1).list
.cas/inputs/$(1).list: $(2)
	$$(shell mkdir -p $(dir .cas/inputs/$(1).list))
	$$(file >.cas/inputs/$(1).list.tmp,$(sort $(2)))
	@if [ ! -f $$@ ] || ! cmp -s $$@.tmp $$@; then mv $$@.tmp $$@; else rm $$@.tmp; fi

# The marker file depends on all deps, but its timestamp will only be updated when their content changes
.cas/inputs/$(1).hash: .cas/inputs/$(1).list $(2)
	@cat $$< | tr ' ' '\n' | xargs sha1sum > $$@.tmp;
	@if [ ! -f $$@ ] || ! cmp -s $$@.tmp $$@; then \
		if [ -n "$(VERBOSE)" ]; then echo "Updating $$@"; diff --unified $$@ $$@.tmp | grep '^[+-][^+-]' || true; fi; \
		mv $$@.tmp $$@; \
	else \
		if [ -n "$(VERBOSE)" ]; then echo "No changes for $$@"; fi; \
		rm $$@.tmp; \
	fi
endef

# cas_get_deps consumes the input marker file (implicitly assumed to be $^) and filters it to the given pattern.
# this lets you include tools as part of your input digest for correctness, but filter the inputs to just source files for consuming by your command
cas_get_deps = $(filter $(1),$(shell cut -c 43- $^))
