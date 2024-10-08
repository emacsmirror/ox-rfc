export EMACS ?= emacs
export EMACS_CLEAN ?= -Q
export EMACS_BATCH := $(EMACS_CLEAN) --batch -L $(ORG_DIR)/lisp
export PACKAGE_NAME := ox-rfc
export PROJDIR := $(shell pwd)
export

all: build test

build: ox-rfc.info
	$(EMACS) $(EMACS_BATCH) --eval \
	    "(progn                                \
	      (setq byte-compile-error-on-warn t)  \
	      (batch-byte-compile))" $(PROJDIR)/$(PACKAGE_NAME).el

ox-rfc.org: README.org

%.info: %.org
	$(EMACS) $(EMACS_BATCH) -l ox-texinfo $< -f org-texinfo-export-to-info

test:
	$(MAKE) -C ert-tests test

debug:
	$(MAKE) -C ert-tests debug

clean:
	$(MAKE) -C ert-tests clean
	rm -f *~ *.elc *.info *.texi

install:


docker-build:
	$(MAKE) -C ert-tests docker-build

docker-run:
	docker run -v $(PROJDIR):/work -it org-rfc-test
