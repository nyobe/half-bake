include ../cas.mk

.DEFAULT_GOAL := bin/main

$(shell mkdir -p bin)
GO = $(shell which go)

bin/main: $(call cas_inputs,main,$(GO) main.go lib.go)
	$(GO) build -o $@ $(call cas_get_deps,%.go)

