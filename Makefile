PACKAGE = org-trello
VERSION = $$(grep "^;; Version: " $(PACKAGE).el | cut -f3 -d' ')
ARCHIVE = $(PACKAGE)-$(VERSION).tar
EMACS ?= emacs
CASK ?= cask
SRCREGEX = test/*.el
# Alternative: uncomment to lint all tracked Emacs Lisp files
# SRCREGEX = $(shell git ls-files '*.el')
LANG=en_US.UTF-8

.PHONY: all clean lint test

activate:
	nix develop

pr:
	hub pull-request -b org-trello:master

build:
	${CASK} build

clean-cask:
	[ -d .cask ] && rm -rf .cask/ || echo

clean-dist:
	[ -d dist ] && rm -rf dist/ || echo

clean: clean-dist clean-cask
	rm -rf ${ARCHIVE}
	${CASK} clean-elc

install:
	@command -v cask >/dev/null 2>&1 || { \
		echo "Error: 'cask' not found in PATH. Please install from https://github.com/cask/cask"; \
		exit 1; \
	}
	[ ! -d .cask ] && ${CASK} install || echo

lint-parens:
	@for file in $(SRCREGEX); do \
		echo "Checking parentheses on $$file..."; \
		${EMACS} -Q --batch --eval "(progn (find-file \"$$file\") (check-parens))" || { echo "Mismatched parentheses in $$file"; exit 1; }; \
	done

lint-elc:
	@for file in $(SRCREGEX); do \
		echo "Running 'byte-compile-file' on $$file..."; \
		${CASK} exec ${EMACS} -Q --batch -L . -L test --eval "(byte-compile-file \"$$file\")" || true; \
	done

lint: lint-parens lint-elc  # Composite target

test: install
	${CASK} exec ert-runner

pkg-file:
	${CASK} pkg-file

pkg-el: pkg-file
	${CASK} package

package: clean pkg-el
	cp dist/$(ARCHIVE) .
	make clean-dist

info:
	${CASK} info

release:
	./release.sh $(VERSION) $(PACKAGE)

version:
	@echo "application $(PACKAGE): $(VERSION)\npackage: $(ARCHIVE)"
