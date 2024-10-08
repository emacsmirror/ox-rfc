# Adapted from: git@github.com:choppsv1/ietf-docs.git
# Adapted from: git@github.com:rolandwalker/emacs-travis.git
TESTDIR := $(shell pwd)
PROJDIR ?= $(TESTDIR)/..

ORG_RELEASE ?= 9.6.30
ORG_DIR := /tmp/org-$(ORG_RELEASE)
# ORG_URL := https://code.orgmode.org/bzg/org-mode/archive/release_$(ORG_RELEASE).tar.gz
ORG_URL := https://git.savannah.gnu.org/cgit/emacs/org-mode.git/snapshot/org-mode-release_$(ORG_RELEASE).tar.gz
ORG_EX := $(ORG_DIR)/lisp/ox.el

EMACS ?= emacs
EMACS_CLEAN ?= -Q
# So bizarre emacs 25 (only) has no exec-path maybe b/c of cannot dump.
EMACS_BATCH := $(EMACS_CLEAN) --batch --eval "(add-to-list 'exec-path \"/usr/bin\")" -L $(ORG_DIR)/lisp
EMACS_TEST_VERSION_LATEST := 29.4
EMACS_TEST_VERSIONS := $(EMACS_TEST_VERSION_LATEST) 28.2 27.2

AUTOLOADS_FILE := $(TESTDIR)/$(PACKAGE_NAME)-autoloads.el
CURL := curl -fL --silent
TRAVIS_FILE := $(PROJDIR)/.travis.yml

.PHONY: autoloads build clean test test-autoloads test-travis

$(ORG_EX):
	curl -fLO $(ORG_URL) | file $(notdir $(ORG_URL))
	mkdir -p $(ORG_DIR)
	(cd $(ORG_DIR) && $(CURL) $(ORG_URL) | tar --strip-components=1 -xzf -)
	(cd $(ORG_DIR) && make autoloads lisp)


build: $(ORG_EX)
	$(EMACS) $(EMACS_BATCH) --eval \
	    "(progn                                \
	      (setq byte-compile-error-on-warn t)  \
	      (batch-byte-compile))" $(PROJDIR)/$(PACKAGE_NAME).el

autoloads:
	$(EMACS) $(EMACS_BATCH) --eval                       \
	    "(progn                                          \
	      (setq generated-autoload-file \"$(AUTOLOADS_FILE)\") \
	      (update-directory-autoloads \"$(PROJDIR)\"))"

test-autoloads : autoloads
	@$(EMACS) $(EMACS_BATCH) -L .. -l "$(AUTOLOADS_FILE)"      || \
	 ( echo "failed to load autoloads: $(AUTOLOADS_FILE)" && false )

test-travis:
	@if test -z "$$TRAVIS" && test -e $(TRAVIS_FILE); then travis-lint $(TRAVIS_FILE); fi

test: build test-autoloads
	$(EMACS) $(EMACS_BATCH) -L .. -l ert -l unit-test.el -f ert-run-tests-batch-and-exit
	$(EMACS) $(EMACS_BATCH) -L .. -l ert -l ox-rfc-test.el -f ert-run-tests-batch-and-exit

debug: build test-autoloads
	$(EMACS) $(EMACS_BATCH) -L .. -l ert -l ox-rfc-debug.el -f ert-run-tests-batch-and-exit

clean:
	@rm -rf $(ORG_DIR)
	@rm -f auto $(AUTOLOADS_FILE) *.elc $(TESTDIR)/draft-*.xml

# docker build --build-arg=UVERSION=16.04 --build-arg=EVERSION=24.3 -t org-rfc-test:24.3 .
docker-build:
	for f in $(EMACS_TEST_VERSIONS); do docker docker build --build-arg=UVERSION=22.04 --build-arg=EVERSION=$${f} -t org-rfc-test:$${f} .; done
	docker tag org-rfc-test:$(EMACS_TEST_VERSION_LATEST) org-rfc-test

docker-push:
	for f in $(EMACS_TEST_VERSIONS); do docker tag org-rfc-test:$$f choppsv1/org-rfc-test:$$f; done
	for f in $(EMACS_TEST_VERSIONS); do docker push choppsv1/org-rfc-test:$$f; done

docker-run:
	docker run -v $(PROJDIR):/work -it org-rfc-test

EVERSION ?= $(EMACS_TEST_VERSION_LATEST)
DOCKER := docker run -v $(PROJDIR):/work -it org-rfc-test:$(EVERSION)
docker-test:
	$(DOCKER) bash -c "cp -pr /work /work-test; cd /work-test && make test"
