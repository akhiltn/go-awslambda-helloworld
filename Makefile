BUILD_DIR := bin
.DEFAULT_GOAL := help

all: clean tidy fmt test build package

build: ## The binaries are all renamed 'bootstrap' as is required by AWS AL2 runtime
	$(eval GOOS := linux)
	$(eval GOARCH := amd64)
	go build -v --tags lambda.norpc -o ${BUILD_DIR}/ ./cmd/...
	find ${BUILD_DIR}/ -mindepth 1 -maxdepth 1 -type f -exec sh -c "mv -f {} bootstrap && mkdir -p {} && mv -f bootstrap {}/bootstrap" \;

clean: ## Remove all build and test artifacts
	rm -rf ${BUILD_DIR}
	rm -rf dist
	rm -f test-report.json
	rm -f coverage.out

fmt: ## Format code for all lambdas
	go fmt ./...

tidy: ## Add missing and remove unused modules
	go mod vendor
	go mod tidy -v

test: ## Execute test cases and produce coverage reports
ifeq ($(MAKECMDGOALS), ci)
	go test -v -coverpkg=./... -coverprofile=coverage.out -json ./... > test-report.json || (cat test-report.json; exit 1)
else
	go test -v -coverpkg=./... -coverprofile=coverage.out ./...
endif

cover: test ## Execute test cases and show coverage in the browser
	go tool cover --html=coverage.out

package: ## Create lambda deployable zip packages for each lambda
	@mkdir -p dist
	find bin/ -mindepth 1 -maxdepth 1 -type d -exec zip -j '{}.zip' '{}/bootstrap' \; && mv ${BUILD_DIR}/*.zip dist/;

help: ## Show make target documentation
	@awk -F ':|##' '/^[^\t].+?:.##/ {\
	printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF \
	}' ${MAKEFILE_LIST}

ci: clean test build package

.PHONY: ci help package cover test tidy fmt clean build all
