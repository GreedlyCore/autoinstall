# Adapted from the reference project's Makefile/pdf.sh/latexmkrc workflow.
# Settings precedence: command line > usercfg.mk > defaults below.
-include usercfg.mk

SOURCE ?= src/main
TARGET ?= $(notdir $(SOURCE))
LATEXMK ?= latexmk
MKRC ?= latexmkrc
BACKEND ?= -pdf
LATEXMKFLAGS ?=

# Keep generated font metrics and font caches with the other build artifacts.
export TEXMFVAR := $(CURDIR)/artifacts/texmf-var
export VARTEXFONTS := $(TEXMFVAR)/fonts

# Upstream TeX Live installs may not be registered in the shell's PATH.
# Prefer tools already on PATH; otherwise use the latest standard installation.
ifeq ($(shell command -v "$(LATEXMK)" 2>/dev/null),)
TEXLIVE_BIN ?= $(patsubst %/latexmk,%,$(lastword $(sort $(wildcard /usr/local/texlive/*/bin/*/latexmk))))
endif
ifneq ($(strip $(TEXLIVE_BIN)),)
export PATH := $(TEXLIVE_BIN):$(PATH)
endif

.DEFAULT_GOAL := all
.NOTPARALLEL:
.PHONY: all pdf check-tools clean distclean rebuild help

all: pdf

check-tools:
	@command -v "$(LATEXMK)" >/dev/null 2>&1 || { \
		printf '%s\n' 'latexmk was not found on PATH or in /usr/local/texlive/. Set TEXLIVE_BIN to your TeX Live bin directory or see README.md.' >&2; \
		exit 1; \
	}

# latexmk tracks dependencies and reruns LaTeX until references are resolved.
# Copy only after a successful build, preserving the last final PDF on failure.
pdf: check-tools
	mkdir -p artifacts build
	"$(LATEXMK)" -norc -r "$(MKRC)" $(LATEXMKFLAGS) $(BACKEND) \
		-outdir=artifacts -jobname="$(TARGET)" "$(SOURCE).tex"
	cp -- "artifacts/$(TARGET).pdf" "build/$(TARGET).pdf"
	@printf 'Final PDF: build/%s.pdf\n' "$(TARGET)"

# These directories are reserved for generated files.
clean:
	rm -rf -- artifacts

distclean: clean
	rm -f -- "build/$(TARGET).pdf"

rebuild:
	$(MAKE) clean
	$(MAKE) pdf

help:
	@printf '%s\n' \
		'make / make pdf   Build build/main.pdf; cache and logs in artifacts/' \
		'make rebuild      Clear the cache and build again' \
		'make clean        Remove artifacts/; keep the final PDF' \
		'make distclean    Also remove the final PDF' \
		'Override settings: make BACKEND=-lualatex or edit usercfg.mk'
