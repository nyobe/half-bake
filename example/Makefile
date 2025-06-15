include ../cas.mk

MAKEFLAGS += --no-builtin-rules
.DEFAULT_GOAL := bin/main

$(shell mkdir -p bin)
GO = $(shell which go)

# simple example of content-based dependency tracking.
# cas_inputs creates a sentinel file that is only updated when the contents of the inputs change.
# you can test this by touching one of the inputs (main.go or lib.go) and observing that `make bin/main` does not rebuild.
# actually editing one of the input files will cause a rebuild.
#
# for correctness the toolchain should be included as part of the target inputs.
# cas_get_deps allows filtering the inputs based on a pattern, to allow extracting just the source file inputs.
bin/main: $(call cas_inputs,bin/main,$(GO) main.go lib.go)
	$(GO) build -o $@ $(call cas_get_deps,%.go)

