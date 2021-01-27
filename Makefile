.PHONY: html pdf
.DEFAULT_GOAL := help

MKD  := uptane-deployment-considerations-release.md
HTML := uptane-deployment-considerations-release.html
PDF  := uptane-deployment-considerations-release.pdf
VER  := $(shell git rev-parse --short HEAD)
DATE := $(shell git show -s --format=%cs)

# Sets release version to a simple tag if the current commit is 
# tagged, otherwise gives the current commit's id and date. Will
# be overwritten if RELEASE_VERSION is set in the shell env.
# RELEASE_VERSION will appear in the document title.
RELEASE_VERSION ?= $(shell git describe --tags --exact-match 2>/dev/null || echo $(DATE)-DRAFT-$(VER))

clean: ## Remove the generated files
	@rm -rf $(HTML) $(PDF) .refcache/

help: ## Print this message and exit
	@echo "\033[1;37mRequires Docker\033[0m"
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9a-zA-Z_-]+:.*?## / {printf "\033[36m%s\033[0m : %s\n", $$1, $$2}' $(MAKEFILE_LIST) \
		| column -s ':' -t

html: ## Create an HTML version of the deployment considerations, using docker
	@docker run --rm -it -v $(PWD):/data uptane/pandoc $(MKD) --filter pandoc-include --metadata=title:"Uptane Deployment Considerations v.$(RELEASE_VERSION)" -o $(HTML) --self-contained

pdf: ## Create a PDF version of the deployment considerations, using docker
	@docker run --rm -it -v $(PWD):/data uptane/pandoc $(MKD) --filter pandoc-include --metadata=title:"Uptane Deployment Considerations v.$(RELEASE_VERSION)" -o $(PDF)

