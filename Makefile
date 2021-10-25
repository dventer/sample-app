# set default shell
SHELL=/bin/bash -o pipefail -o errexit
TAG ?= $(git rev-parse --short HEAD)
REGISTRY = "venter"


.PHONY: build
build: ## Build image for a particular arch.
	echo "Building docker image ..."
	echo ${REGISTRY}/sample-app:$(TAG)
	@docker build -t ${REGISTRY}/sample-app:$(TAG) .


.PHONY: push
push:
	docker push ${REGISTRY}/controller:$(TAG)
