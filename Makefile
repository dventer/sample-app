# set default shell
SHELL=/bin/bash -o pipefail -o errexit
TAG ?= $(shell git rev-parse --short HEAD)
REGISTRY=venter
APP=sample-app

.PHONY: build
build: ## Build docker image
	echo "Building docker image ..."
	@docker build -t ${REGISTRY}/${APP}:$(TAG) .


.PHONY: push
push:
	docker push ${REGISTRY}/${APP}:${TAG}

.PHONY: create-cluster
create-cluster:
	@scripts/create-cluster.sh

.PHONY: delete-cluster
delete-cluster:
	@kind delete cluster --name=$(shell kind get clusters)

.PHONY: deploy
deploy:
	@helm upgrade --install ${APP} charts/${APP} \
	--set image.repository=${REGISTRY}/${APP} \
	--set image.tag=${TAG}

.PHONY: rollback
rollback: 
	@helm rollback ${APP}
