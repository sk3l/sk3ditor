MAJOR?=0
MINOR?=1

#VERSION=$(MAJOR).$(MINOR)

APP_NAME:= sk3ditor
DEV_USER?= $(shell echo "${USER}")
# Our docker Hub account name
# HUB_NAMESPACE = "<hub_name>"

# location of Dockerfiles
# DOCKER_FILE_DIR = "dockerfiles"
DOCKERFILE:= "sk3ditor.dockerfile"

IMAGE_NAME:= "${APP_NAME}"
# CONT_NAME:= "${APP_PREFIX}-${COMPONENT_NAME}"


CUR_DIR = $(shell echo "${PWD}")
MKFILE_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# BT_SVC_INI?=--build-arg "app_cfg_file=bitomb.ini"
#BT_DB_MNT?=""
#ifeq (${DEBUG}, 1)
#    BT_DB_MNT=-v "${MKFILE_DIR}/code:/svc/bitomb"
#    BT_SVC_INI=--build-arg "app_cfg_file=development.ini"
#endif
WORK_DIR?=${MKFILE_DIR}

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# DOCKER TASKS
.PHONY: build
build: ## Build the container image
	#docker pull python:3.7-buster
	@docker build                       \
		--tag ${IMAGE_NAME}             \
		--build-arg dev_user=${DEV_USER}\
		-f ${DOCKERFILE}                \
		.

#.PHONY: create
#create: ## Create the container instance
#	docker create --name ${CONT_NAME} --network=${BT_NET} --ip=${BT_IP} --publish ${BT_PUB} ${BT_DB_MNT} ${IMAGE_NAME}

#.PHONY: init
#init: build create

.PHONY: run
run: ## Run container on port configured in `config.env`
	@docker run                                 \
		--rm                                    \
		-i                                      \
		--tty                                   \
		-v "${WORK_DIR}:/home${DEV_NAME}/code"  \
	    ${IMAGE_NAME}

	#./sk3ditor.sh
#	docker start ${CONT_NAME}

#.PHONY: start
#start: ## Run container on port configured in `config.env`
#	docker start ${CONT_NAME}

#.PHONY: stop
#stop: ## Stop a running container
#	docker stop ${CONT_NAME}

#.PHONY: rm
#rm: ## Remove a container
#	docker rm ${CONT_NAME}

.PHONY: rmi
rmi: ## Remove a container image
	docker rmi ${IMAGE_NAME}

.PHONY: destroy
destroy: rm rmi

clean: destroy

#release: build-nc publish ## Make a release by building and publishing the `{version}` ans `latest` tagged containers to ECR

## Docker publish
#publish: repo-login publish-latest publish-version ## Publish the `{version}` ans `latest` tagged containers to ECR
#
#publish-latest: tag-latest ## Publish the `latest` taged container to ECR
#	@echo 'publish latest to $(DOCKER_REPO)'
#	docker push $(DOCKER_REPO)/$(APP_NAME):latest
#
#publish-version: tag-version ## Publish the `{version}` taged container to ECR
#	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
#	docker push $(DOCKER_REPO)/$(APP_NAME):$(VERSION)
#
## Docker tagging
#tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags
#
#tag-latest: ## Generate container `{version}` tag
#	@echo 'create tag latest'
#	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):latest
#
#tag-version: ## Generate container `latest` tag
#	@echo 'create tag $(VERSION)'
#	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

# HELPERS

