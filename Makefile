.PHONY: help clean publish version
.DEFAULT := help

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR := $(dir $(MAKEFILE_PATH))
RELEASE := $$(git describe --tags --candidates=0)
ASSET := $(CURRENT_DIR)build/$(RELEASE)

help:
	@awk 'BEGIN {FS = ":.*##"; printf "\n\033[1mUsage:\n  make \033[36m<target>\033[0m\n"} \
	/^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-40s\033[0m %s\n", $$1, $$2 } /^##@/ \
	{ printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)



##@ Development

version: ## Display current version
	git describe --tags --candidates=0

tar: clean ## Make .TAR.GZ
	tar -czvf $(ASSET).tar.gz -C src . -C .. Makefile

zip: clean ## Make .ZIP
	cd $(CURRENT_DIR)src && zip -r $(ASSET).zip .
	cd $(CURRENT_DIR) && zip -r $(ASSET).zip Makefile

publish: ## Publish new release to GitHub
	git status --short
	test -z "$$(git status --porcelain)" && exit $?
	make tar zip
	gh release create "$$(git describe --tags --candidates=0)" '$(ASSET).tar.gz#Release (tar.gz)' '$(ASSET).zip#Release (zip)'
	make clean

clean: ## Clean
	test -d $(CURRENT_DIR)build || mkdir -p $(CURRENT_DIR)build
	rm -rfv $(ASSET).tar.gz $(ASSET).zip
