# Set POSIX sh for maximum interoperability
SHELL := /bin/sh
PATH  := $(GOPATH)/bin:$(PATH)

# Import config
# You can change the default config with `make config="config_special.env" build`
config ?= config.env
include $(config)

# Set an output prefix, which is the local directory if not specified
PREFIX?=$(shell pwd)

VERSION := $(shell cat VERSION.txt)
GITCOMMIT := $(shell git rev-parse --short HEAD)
GITBRANCH := $(shell git rev-parse --abbrev-ref HEAD)
GITUNTRACKEDCHANGES := $(shell git status --porcelain --untracked-files=no)
GITIGNOREDBUTTRACKEDCHANGES := $(shell git ls-files -i --exclude-standard)
ifneq ($(GITUNTRACKEDCHANGES),)
    GITCOMMIT := $(GITCOMMIT)-dirty
endif
ifneq ($(GITIGNOREDBUTTRACKEDCHANGES),)
    GITCOMMIT := $(GITCOMMIT)-dirty
endif

VERSION_TAG := $(VERSION)
LATEST_TAG := latest
BUILD_TAG := $(GITBRANCH)-$(GITCOMMIT)

BUILD_PATH := ./cmd/manager

# Set any default go build tags
BUILDTAGS :=

# Set the build dir, where built cross-compiled binaries will be output
BUILDDIR := ${PREFIX}/cross

CTIMEVAR=-X $(PKG)/version.GitCommit=$(GITCOMMIT) -X $(PKG)/version.Version=$(VERSION)
GO_LDFLAGS=-ldflags "-w $(CTIMEVAR)"
GO_LDFLAGS_STATIC=-ldflags "-w $(CTIMEVAR) -extldflags -static"

# List the GOOS and GOARCH to build
GOOSARCHES = linux/amd64

PACKAGES = $(shell go list -f '{{.ImportPath}}/' ./... | grep -v vendor)
PACKAGES_FOR_UNIT_TESTS = $(shell go list -f '{{.ImportPath}}/' ./... | grep -v vendor | grep -v e2e)

# Run all the e2e tests by default
E2E_TEST_SELECTOR ?= .*

ARGS ?= /usr/bin/jenkins-operator --local --namespace=$(NAMESPACE) $(EXTRA_ARGS)

.DEFAULT_GOAL := help

.PHONY: all
all: status checkmake clean build verify install docker-build docker-images ## Build the image
	@echo "+ $@"

.PHONY: check-env
check-env: ## Checks the environment variables
	@echo "+ $@"
	@echo "NAME: $(NAME)"
ifeq ($(NAME),)
	$(error You must provide application name)
endif
	@echo "VERSION: $(VERSION)"
ifeq ($(VERSION),)
	$(error You must provide application version)
endif
	@echo "PKG: $(PKG)"
ifeq ($(PKG),)
	$(error You must provide application package)
endif
	@echo "VERSION_TAG: $(VERSION_TAG)"
	@echo "LATEST_TAG: $(LATEST_TAG)"
	@echo "BUILD_TAG: $(BUILD_TAG)"
ifneq ($(GITUNTRACKEDCHANGES),)
	@echo "Changes: \n$(GITUNTRACKEDCHANGES)"
endif

.PHONY: go-init
HAS_GIT := $(shell which git)
HAS_GO := $(shell which go)
go-init: ## Ensure build time dependencies
	@echo "+ $@"
ifndef HAS_GIT
	$(warning You must install git)
endif
ifndef HAS_GO
	$(warning You must install go)
endif

.PHONY: go-dependencies
HAS_DEP := $(shell which dep)
go-dependencies: ## Ensure build dependencies
	@echo "+ $@"
	@echo "Ensure Golang runtime dependencies"
ifndef HAS_DEP
	go get -u github.com/golang/dep/cmd/dep
endif
	dep ensure -v

.PHONY: dep
dep: go-dependencies ## Ensure build dependencies

.PHONY: build
build: $(NAME) ## Builds a dynamic executable or package
	@echo "+ $@"

.PHONY: $(NAME)
$(NAME): $(wildcard *.go) $(wildcard */*.go) VERSION.txt
	@echo "+ $@"
	CGO_ENABLED=0 go build -tags "$(BUILDTAGS)" ${GO_LDFLAGS} -o build/_output/bin/jenkins-operator $(BUILD_PATH)

.PHONY: static
static: ## Builds a static executable
	@echo "+ $@"
	CGO_ENABLED=0 go build \
				-tags "$(BUILDTAGS) static_build" \
				${GO_LDFLAGS_STATIC} -o $(NAME) $(BUILD_PATH)

.PHONY: fmt
fmt: ## Verifies all files have been `gofmt`ed
	@echo "+ $@"
	@go fmt $(PACKAGES)

.PHONY: lint
HAS_GOLINT := $(shell which golint)
lint: ## Verifies `golint` passes
	@echo "+ $@"
ifndef HAS_GOLINT
	go get -u github.com/golang/lint/golint
endif
	@golint $(PACKAGES)

.PHONY: goimports
HAS_GOIMPORTS := $(shell which goimports)
goimports: ## Verifies `goimports` passes
	@echo "+ $@"
ifndef HAS_GOIMPORTS
	go get -u golang.org/x/tools/cmd/goimports
endif
	@goimports -l -e $(shell find . -type f -name '*.go' -not -path "./vendor/*")

.PHONY: test
test: ## Runs the go tests
	@echo "+ $@"
	@RUNNING_TESTS=1 go test -tags "$(BUILDTAGS) cgo" $(PACKAGES_FOR_UNIT_TESTS)

.PHONY: e2e
CURRENT_DIRECTORY := $(shell pwd)
e2e: build docker-build ## Runs e2e tests, you can use EXTRA_ARGS
	@echo "+ $@"
	@echo "Docker image: $(DOCKER_REGISTRY):$(GITCOMMIT)"
	kubectl config use-context $(ENVIRONMENT)
	cp deploy/service_account.yaml deploy/namespace-init.yaml
	cat deploy/role.yaml >> deploy/namespace-init.yaml
	cat deploy/role_binding.yaml >> deploy/namespace-init.yaml
	cat deploy/operator.yaml >> deploy/namespace-init.yaml
	sed -i 's|\(image:\).*|\1 $(DOCKER_REGISTRY):$(GITCOMMIT)|g' deploy/namespace-init.yaml
ifeq ($(ENVIRONMENT),minikube)
	sed -i 's|\(imagePullPolicy\): IfNotPresent|\1: Never|g' deploy/namespace-init.yaml
	sed -i 's|\(args:\).*|\1\ ["--minikube"\]|' deploy/namespace-init.yaml
endif

	@RUNNING_TESTS=1 go test -parallel=1 "./test/e2e/" -tags "$(BUILDTAGS) cgo" -v -timeout 30m -run "$(E2E_TEST_SELECTOR)" \
		-root=$(CURRENT_DIRECTORY) -kubeconfig=$(HOME)/.kube/config -globalMan deploy/crds/jenkinsio_v1alpha1_jenkins_crd.yaml -namespacedMan deploy/namespace-init.yaml $(EXTRA_ARGS)

.PHONY: vet
vet: ## Verifies `go vet` passes
	@echo "+ $@"
	@go vet $(PACKAGES)

.PHONY: staticcheck
HAS_STATICCHECK := $(shell which staticcheck)
staticcheck: ## Verifies `staticcheck` passes
	@echo "+ $@"
ifndef HAS_STATICCHECK
	wget https://github.com/dominikh/go-tools/releases/download/2019.1.1/staticcheck_linux_amd64
	chmod +x staticcheck_linux_amd64
	mkdir -p $(HOME)/bin
	mv staticcheck_linux_amd64 $(HOME)/bin/staticcheck
endif
	@staticcheck $(PACKAGES)

.PHONY: cover
cover: ## Runs go test with coverage
	@echo "" > coverage.txt
	@for d in $(PACKAGES); do \
		IMG_RUNNING_TESTS=1 go test -race -coverprofile=profile.out -covermode=atomic "$$d"; \
		if [ -f profile.out ]; then \
			cat profile.out >> coverage.txt; \
			rm profile.out; \
		fi; \
	done;

.PHONY: verify
verify: fmt lint test staticcheck vet ## Verify the code
	@echo "+ $@"

.PHONY: install
install: ## Installs the executable
	@echo "+ $@"
	go install -tags "$(BUILDTAGS)" ${GO_LDFLAGS} $(BUILD_PATH)

.PHONY: run
run: ## Run the executable, you can use EXTRA_ARGS
	@echo "+ $@"
	kubectl config use-context $(ENVIRONMENT)
	go run -tags "$(BUILDTAGS)" ${GO_LDFLAGS} $(BUILD_PATH)/main.go $(ARGS)

.PHONY: clean
clean: ## Cleanup any build binaries or packages
	@echo "+ $@"
	go clean
	rm $(NAME) || echo "Couldn't delete, not there."
	rm -r $(BUILDDIR) || echo "Couldn't delete, not there."

.PHONY: spring-clean
spring-clean: ## Cleanup git ignored files (interactive)
	git clean -Xdi

define buildpretty
mkdir -p $(BUILDDIR)/$(1)/$(2);
GOOS=$(1) GOARCH=$(2) CGO_ENABLED=0 go build \
		-o $(BUILDDIR)/$(1)/$(2)/$(NAME) \
		-a -tags "$(BUILDTAGS) static_build netgo" \
		-installsuffix netgo ${GO_LDFLAGS_STATIC} $(BUILD_PATH);
md5sum $(BUILDDIR)/$(1)/$(2)/$(NAME) > $(BUILDDIR)/$(1)/$(2)/$(NAME).md5;
sha256sum $(BUILDDIR)/$(1)/$(2)/$(NAME) > $(BUILDDIR)/$(1)/$(2)/$(NAME).sha256;
endef

.PHONY: cross
cross: $(wildcard *.go) $(wildcard */*.go) VERSION.txt ## Builds the cross-compiled binaries, creating a clean directory structure (eg. GOOS/GOARCH/binary)
	@echo "+ $@"
	$(foreach GOOSARCH,$(GOOSARCHES), $(call buildpretty,$(subst /,,$(dir $(GOOSARCH))),$(notdir $(GOOSARCH))))

define buildrelease
GOOS=$(1) GOARCH=$(2) CGO_ENABLED=0 go build \
	 -o $(BUILDDIR)/$(NAME)-$(1)-$(2) \
	 -a -tags "$(BUILDTAGS) static_build netgo" \
	 -installsuffix netgo ${GO_LDFLAGS_STATIC} $(BUILD_PATH);
md5sum $(BUILDDIR)/$(NAME)-$(1)-$(2) > $(BUILDDIR)/$(NAME)-$(1)-$(2).md5;
sha256sum $(BUILDDIR)/$(NAME)-$(1)-$(2) > $(BUILDDIR)/$(NAME)-$(1)-$(2).sha256;
endef

.PHONY: release
release: $(wildcard *.go) $(wildcard */*.go) VERSION.txt ## Builds the cross-compiled binaries, naming them in such a way for release (eg. binary-GOOS-GOARCH)
	@echo "+ $@"
	$(foreach GOOSARCH,$(GOOSARCHES), $(call buildrelease,$(subst /,,$(dir $(GOOSARCH))),$(notdir $(GOOSARCH))))

.PHONY: checkmake
HAS_CHECKMAKE := $(shell which checkmake)
checkmake: ## Check this Makefile
	@echo "+ $@"
ifndef HAS_CHECKMAKE
	go get -u github.com/mrtazz/checkmake
endif
	@checkmake Makefile

.PHONY: docker-login
docker-login: ## Log in into the Docker repository
	@echo "+ $@"

.PHONY: docker-build
docker-build: check-env build ## Build the container
	@echo "+ $@"
	docker build . -t $(DOCKER_REGISTRY):$(GITCOMMIT) --file build/Dockerfile

.PHONY: docker-images
docker-images: ## List all local containers
	@echo "+ $@"
	docker images

.PHONY: docker-push
docker-push: ## Push the container
	@echo "+ $@"
	docker tag $(DOCKER_REGISTRY):$(GITCOMMIT) $(DOCKER_ORGANIZATION)/$(DOCKER_REGISTRY):$(BUILD_TAG)
	docker push $(DOCKER_ORGANIZATION)/$(DOCKER_REGISTRY):$(BUILD_TAG)

.PHONY: docker-release-version
docker-release-version: ## Release image with version tag (in addition to build tag)
	@echo "+ $@"
	docker tag $(DOCKER_REGISTRY):$(GITCOMMIT) $(DOCKER_ORGANIZATION)/$(DOCKER_REGISTRY):$(VERSION_TAG)
	docker push $(DOCKER_ORGANIZATION)/$(DOCKER_REGISTRY):$(VERSION_TAG)

.PHONY: docker-release-latest
docker-release-latest: ## Release image with latest tags (in addition to build tag)
	@echo "+ $@"
	docker tag $(DOCKER_REGISTRY):$(GITCOMMIT) $(DOCKER_ORGANIZATION)/$(DOCKER_REGISTRY):$(LATEST_TAG)
	docker push $(DOCKER_ORGANIZATION)/$(DOCKER_REGISTRY):$(LATEST_TAG)

.PHONY: docker-release
docker-release: docker-release-version docker-release-latest ## Release image with version and latest tags (in addition to build tag)
	@echo "+ $@"

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
    DOCKER_FLAGS += -t
endif

.PHONY: docker-run
docker-run: ## Run the container in docker, you can use EXTRA_ARGS
	@echo "+ $@"
	docker run --rm -i $(DOCKER_FLAGS) \
		--volume $(HOME)/.kube/config:/home/jenkins-operator/.kube/config \
		$(DOCKER_REGISTRY):$(GITCOMMIT) $(ARGS)

.PHONY: minikube-run
minikube-run: export WATCH_NAMESPACE = $(NAMESPACE)
minikube-run: export OPERATOR_NAME = $(NAME)
minikube-run: start-minikube ## Run the operator locally and use minikube as Kubernetes cluster, you can use EXTRA_ARGS
	@echo "+ $@"
	kubectl config use-context minikube
	kubectl apply -f deploy/crds/jenkinsio_v1alpha1_jenkins_crd.yaml
	@echo "Watching '$(WATCH_NAMESPACE)' namespace"
	build/_output/bin/jenkins-operator $(EXTRA_ARGS)

.PHONY: deepcopy-gen
deepcopy-gen: ## Generate deepcopy golang code
	@echo "+ $@"
	operator-sdk generate k8s

.PHONY: start-minikube
start-minikube: ## Start minikube
	@echo "+ $@"
	@minikube status && exit 0 || \
	minikube start --kubernetes-version $(MINIKUBE_KUBERNETES_VERSION) --vm-driver=$(MINIKUBE_DRIVER) --memory 4096 --cpus 3

.PHONY: bump-version
BUMP := patch
bump-version: ## Bump the version in the version file. Set BUMP to [ patch | major | minor ]
	@echo "+ $@"
	@go get -u github.com/jessfraz/junk/sembump # update sembump tool
	$(eval NEW_VERSION=$(shell sembump --kind $(BUMP) $(VERSION)))
	@echo "Bumping VERSION.txt from $(VERSION) to $(NEW_VERSION)"
	echo $(NEW_VERSION) > VERSION.txt
	@echo "Updating version from $(VERSION) to $(NEW_VERSION) in README.md"
	sed -i s/$(VERSION)/$(NEW_VERSION)/g README.md
	sed -i s/$(VERSION)/$(NEW_VERSION)/g deploy/operator.yaml
	git add VERSION.txt README.md deploy/operator.yaml
	git commit -vaem "Bump version to $(NEW_VERSION)"
	@echo "Run make tag to create and push the tag for new version $(NEW_VERSION)"

.PHONY: tag
tag: ## Create a new git tag to prepare to build a release
	@echo "+ $@"
	git tag -s -a $(VERSION) -m "$(VERSION)"
	git push origin $(VERSION)

.PHONY: help
help:
	@grep -Eh '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: status
status: ## Shows git and dep status
	@echo "+ $@"
	@echo "Commit: $(GITCOMMIT), VERSION: $(VERSION)"
	@echo
ifneq ($(GITUNTRACKEDCHANGES),)
	@echo "Changed files:"
	@git status --porcelain --untracked-files=no
	@echo
endif
ifneq ($(GITIGNOREDBUTTRACKEDCHANGES),)
	@echo "Ignored but tracked files:"
	@git ls-files -i --exclude-standard
	@echo
endif
	@echo "Dependencies:"
	dep status
	@echo
