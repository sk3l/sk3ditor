##
# Dockerfile for sk3ditor application

# Our docker Hub account name
# HUB_NAMESPACE = "<hub_name>"

##
# Application information
MAJOR?= 1
MINOR?= 0
APP_AUTHOR:= sk3l
APP_NAME:= sk3ditor
APP_VERSION?= latest

##
# Dockerfile information
DOCKERFILE:= "sk3ditor.dockerfile"
DOCKER_REPO:= $(APP_AUTHOR)/$(APP_NAME)

##
# Image information
IMAGE_NAME:= "$(APP_AUTHOR)/$(APP_NAME)"
IMAGE_TAG:= "$(IMAGE_NAME):$(APP_VERSION)"

CUR_DIR = $(shell echo "${PWD}")
MKFILE_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Assign development user name passed to container
DEV_USER?= $(shell echo "${USER}")
DEV_USER_OPTS:=--build-arg dev_user=$(DEV_USER)

# Establish bind mount between host and container
# (default=nothing shared)
MNT_OPTS:=-v :/home/$(DEV_USER)/code
PROJ_DIR_VAR:=PROJ_DIR
ifdef $(PROJ_DIR_VAR)
    MNT_OPTS=-v $(PROJ_DIR):/home/$(DEV_USER)/code:shared
endif

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
	@docker build           \
		--tag $(IMAGE_TAG)  \
		-f $(DOCKERFILE)    \
		$(DEV_USER_OPTS)    \
		.

#.PHONY: create
#create: ## Create the container instance
#	docker create --name ${CONT_NAME} --network=${BT_NET} --ip=${BT_IP} --publish ${BT_PUB} ${BT_DB_MNT} ${IMAGE_NAME}

#.PHONY: init
#init: build create

.PHONY: run
run: ## Run container on port configured in `config.env`
	@docker run      \
		--rm         \
		-i           \
		--tty        \
		$(MNT_OPTS)  \
		$(IMAGE_TAG)

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
	@image_hash=$(shell docker images -q $(IMAGE_TAG)); \
	if [ -n "$$image_hash" ]; then \
		docker rmi $(IMAGE_TAG); \
	else \
		echo "No image $(IMAGE_TAG) defined"; \
	fi

.PHONY: destroy
destroy: rm rmi

clean: destroy

# ## Full versioned release
# release: build publish ## Make a release by building and publishing the `{version}` ans `latest` tagged containers to ECR
#
# ## Docker publish
# publish: repo-login publish-latest publish-version ## Publish the `{version}` ans `latest` tagged containers to ECR
#
# publish-latest: tag-latest ## Publish the `latest` taged container to ECR
# 	@echo 'publish latest to $(DOCKER_REPO)'
# 	docker push $(DOCKER_REPO):latest
#
# publish-version: tag-version ## Publish the `{version}` taged container to ECR
# 	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
# 	docker push $(DOCKER_REPO):$(VERSION)
#
# ## Docker tagging
# tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags
#
# tag-latest: ## Generate container `{version}` tag
# 	@echo 'create tag latest'
# 	docker tag $(IMAGE_NAME) $(IMAGE_NAME):latest
#
# tag-version: ## Generate container `latest` tag
# 	@echo 'create tag $(VERSION)'
# 	docker tag $(IMAGE_NAME) $(IMAGE_NAME):$(APP_VERSION)

# HELPERS

