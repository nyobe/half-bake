include ../cas.mk
include ../build_cache.mk

.DEFAULT_GOAL := bin/main

$(shell mkdir -p bin)
GO = $(shell which go)

bin/main: $(call cas_inputs,main,$(GO) main.go lib.go)
	$(call cas_run,$(GO) build -o $@ $(call cas_get_deps,%.go))

bin/main2: $(call cas_inputs,main2,$(GO) main.go lib.go)
	$(call cas_run,$(GO) build -o $@ $(call cas_get_deps,%.go))

