.PHONY: build test clean prepare update docker

GO = CGO_ENABLED=0 GO111MODULE=on go

MICROSERVICES=cmd/device-gpio-go

.PHONY: $(MICROSERVICES)

DOCKERS=docker_device_gpio_go
.PHONY: $(DOCKERS)

VERSION=$(shell cat ./VERSION 2>/dev/null || echo 1.0.0)
GIT_SHA=$(shell git rev-parse HEAD)
GOFLAGS=-ldflags "-X github.com/edgexfoundry/device-gpio-go.Version=$(VERSION)"

build: $(MICROSERVICES)

cmd/device-gpio-go:
	$(GO) build $(GOFLAGS) -o $@ ./cmd

test:
	$(GO) test ./... -coverprofile=coverage.out
	$(GO) vet ./...
	gofmt -l .
	[ "`gofmt -l .`" = "" ]
	./bin/test-attribution-txt.sh
	./bin/test-go-mod-tidy.sh


clean:
	rm -f $(MICROSERVICES)

docker: $(DOCKERS)

docker_device_gpio_go:
	docker build \
		--label "git_sha=$(GIT_SHA)" \
		--build-arg http_proxy \
        --build-arg https_proxy \
		-t edgexfoundry/docker-device-gpio-go:$(GIT_SHA) \
		-t edgexfoundry/docker-device-gpio-go:$(VERSION)-dev \
		.
