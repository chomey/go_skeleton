USER := chomey
USER_REAL_NAME := "Jordan Foo"
USER_EMAIL := "foo.jordan@gmail.com"
SERVICE_NAME := go_skeleton

VER := $(shell echo `cat VERSION`)
HASH := $(shell echo `git log -1 --pretty=format:%h`)
VERSION := $(VER)+$(HASH)
IMAGE_TAG = $(shell echo $(VERSION) | sed 's|[+:]|-|g')
# Replace '+' with '-' in the semver because docker does support tags with '+'
# https://github.com/docker/distribution/issues/1201
IMAGE_NAME := $(USER)/$(SERVICE_NAME):$(IMAGE_TAG)

## for building locally inside a docker container
BUILD_CONTAINER_IMAGE := chomey/go-build-slave:latest
BUILD_CONTAINER_NAME := $(SERVICE_NAME)_builder

SERVICE_PATH_IN_CONTAINER := /go/src/github.com/$(USER)/$(SERVICE_NAME)

# Replace this with your docker-machine ip if running in docker machine, or set this when running like
# RC_HOSTNAME=192.168.X.Y make run
RC_HOSTNAME ?= localhost

####### Rules for development, default to run build in container, no dependency on local dev environment setup #######
# First rule, as the default rule. Don't move it.
build: version start_build_container container_test container_build image clean

test: start_build_container container_test stop_build_container

run:
	docker-compose rm -f 2>/dev/null || true
	VERSION=$(IMAGE_TAG) SERVICE_NAME=$(SERVICE_NAME) ENVIRONMENT_VARIABLE=$(ENVIRONMENT_VARIABLE) docker-compose up

####### Rules for local build container builds #######
pull_build_container:
	docker pull $(BUILD_CONTAINER_IMAGE)

start_build_container: pull_build_container
	docker run --rm -dit -v /var/run/docker.sock:/var/run/docker.sock \
		-v `pwd`:$(SERVICE_PATH_IN_CONTAINER) --name=$(BUILD_CONTAINER_NAME) \
		$(BUILD_CONTAINER_IMAGE) 2>/dev/null || true

stop_build_container:
	docker stop $(BUILD_CONTAINER_NAME) || true

# for container_<command>, run the match local_<command> in build container.
container_%: start_build_container
	docker exec $(BUILD_CONTAINER_NAME) bash -c "make -C $(SERVICE_PATH_IN_CONTAINER) $(subst container_,local_,$@)"

####### Rules for run builds locally, assume local dev environment is setup #######
local_run: local_build
	bin/$(SERVICE_NAME) service/config.json

local_build:
#	bash -c "CGO_ENABLED=0 GOARCH=386 GOOS=darwin go build -ldflags '-X github.com/$(USER)/$(SERVICE_NAME)/service.VERSION=$(VERSION)' -o bin/$(SERVICE_NAME)_darwin_386"
#	bash -c "CGO_ENABLED=0 GOARCH=amd64 GOOS=darwin go build -ldflags '-X github.com/$(USER)/$(SERVICE_NAME)/service.VERSION=$(VERSION)' -o bin/$(SERVICE_NAME)_darwin_amd64"
#	bash -c "CGO_ENABLED=0 GOARCH=386 GOOS=linux go build -ldflags '-X github.com/$(USER)/$(SERVICE_NAME)/service.VERSION=$(VERSION)' -o bin/$(SERVICE_NAME)_linux_386"
	bash -c "CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -ldflags '-X github.com/$(USER)/$(SERVICE_NAME)/service.VERSION=$(VERSION)' -o bin/$(SERVICE_NAME)_linux_amd64"
#	bash -c "CGO_ENABLED=0 GOARCH=386 GOOS=windows go build -ldflags '-X github.com/$(USER)/$(SERVICE_NAME)/service.VERSION=$(VERSION)' -o bin/$(SERVICE_NAME)_windows_386"
#	bash -c "CGO_ENABLED=0 GOARCH=amd64 GOOS=windows go build -ldflags '-X github.com/$(USER)/$(SERVICE_NAME)/service.VERSION=$(VERSION)' -o bin/$(SERVICE_NAME)_windows_amd64"

local_test:
	go test `go list ./... | grep -v /vendor/`

####### Other rules #######
image:
	docker build --build-arg USER_REAL_NAME=$(USER_REAL_NAME) --build-arg USER_EMAIL=$(USER_EMAIL) -t $(IMAGE_NAME) . && docker tag $(IMAGE_NAME) "$(USER)/$(SERVICE_NAME):localdev"

version:
	@echo $(VERSION)

image_tag:
	$(IMAGE_TAG)

clean:
	docker rm -f $(BUILD_CONTAINER_NAME) 2> /dev/null || true
	rm bin/* || true

.PHONY: start_build_container container build run local_run local_build local_test test version image_tag clean container_%