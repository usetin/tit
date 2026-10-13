# tit: build and test with a tin checkout (TIN, default ../tin) and the docs checkout (TIN_DOCS, default ../docs).
#
#   make build    tit into bin/tit
#   make test     the test suite (git, openssl, perl and ssh-keygen are used by parts of it)
#
# TIN points at a checkout of usetin/tin (the compiler, runtime, std and packages); it is built from
# its checked-in seed when needed. TIN_DOCS points at usetin/docs for the manual check.
TIN ?= ../tin
TIN_DOCS ?= ../docs
TINC := $(TIN)/bin/tinc

.PHONY: all build test

all: build

build: $(TINC)
	@mkdir -p bin
	$(TIN)/tin build main.tin -o bin/tit

test: $(TINC)
	TIN_ROOT=$(abspath $(TIN)) TIN_DOCS=$(abspath $(TIN_DOCS)) sh tests/run.sh $(abspath $(TINC))

$(TINC):
	$(MAKE) -C $(TIN) bin/tinc
