# Copyright 2017 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# This makefile currently assumes linux host. Please submit a PR to port it to
# your preferred OS.

# Override these at the command like, like "make push HUGO_VERSION=0.20 REPO=user/repo".
# https://hub.docker.com/_/alpine/
ALPINE_VERSION?=3.9
# https://github.com/google/brotli/releases
BROTLI_VERSION?=1.0.5
# https://github.com/gohugoio/hugo/releases
HUGO_VERSION?=0.42.2
# https://github.com/tdewolff/minify/releases
MINIFY_VERSION?=2.3.5
# https://www.musl-libc.org/download.html
MUSL_VERSION?=1.1.19

REPO?=marcaruel/hugo-tidy
TAG_NAME=hugo-${HUGO_VERSION}-alpine-${ALPINE_VERSION}-brotli-${BROTLI_VERSION}-minify-${MINIFY_VERSION}

BASE_DIR=$(shell pwd)
MUSL_DIR=${BASE_DIR}/musl-install
# This is needed to build minify, as we need to make sure cgo is disabled.
export GOPATH=${BASE_DIR}/go

all: push_all

.PHONY: build clean push_all push_latest push_version

minify:
	# We cannot use the prebuilt binaries, since we need to build with CGO disabled.
	# Work around non-static build on go 1.8+
	go get -v -d -u github.com/tdewolff/minify/cmd/minify
	cd ${BASE_DIR}/go/src/github.com/tdewolff/minify && git checkout v${MINIFY_VERSION} && cd -
	CGO_ENABLED=0 go build -a -o minify -installsuffix cgo github.com/tdewolff/minify/cmd/minify

musl:
	git clone git://git.musl-libc.org/musl -b v${MUSL_VERSION}

${MUSL_DIR}/bin/musl-gcc: musl
	cd musl && git fetch && git checkout v${MUSL_VERSION} && ./configure --prefix=${MUSL_DIR} --disable-shared && $(MAKE) -j install

brotli:
	git clone https://github.com/google/brotli -b v${BROTLI_VERSION}

# This is important to build brotli as a static executable. You can verify with:
#   readelf -d brotli
#
brotli/bin/brotli: brotli ${MUSL_DIR}/bin/musl-gcc
	cd brotli && git fetch && git checkout v${BROTLI_VERSION} && CC="${MUSL_DIR}/bin/musl-gcc -static" $(MAKE) -j brotli

build: minify brotli/bin/brotli
	docker build --build-arg "ALPINE_VERSION=${ALPINE_VERSION}" --build-arg "HUGO_VERSION=${HUGO_VERSION}" --tag ${REPO}:latest .
	@echo ""
	@echo "Built ${TAG_NAME}"
	@echo ""

push_version: build
	docker tag ${REPO}:latest ${REPO}:${TAG_NAME}
	docker push ${REPO}:${TAG_NAME}

push_latest: build
	docker push ${REPO}:latest

push_all: push_version push_latest

clean:
	rm -rf brotli minify musl ${MUSL_DIR}
