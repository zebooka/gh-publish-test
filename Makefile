.PHONY: help clean publish version
.DEFAULT := help

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR := $(dir $(MAKEFILE_PATH))

help:
	@awk 'BEGIN {FS = ":.*##"; printf "\n\033[1mUsage:\n  make \033[36m<target>\033[0m\n"} \
	/^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-40s\033[0m %s\n", $$1, $$2 } /^##@/ \
	{ printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)



##@ Development

version: ## Display current version
	git describe --tags --candidates=0

targz: clean ## Make .TAR.GZ
	tar -czvf release.tar.gz -C src .

zip: clean ## Make .ZIP


publish: ## Publish new release to GitHub
	git status --short
	test -z "$$(git status --porcelain)" && exit $?
	make targz zip
	gh release create "$$(git describe --tags --candidates=0)" release.tar.gz

clean: ## Clean
	rm -rfv release.tar.gz release.zip
