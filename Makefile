# Copyright 2017 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# This makefile currently assumes linux host. Please submit a PR to port it to
# your preferred OS.

# Override these at the command like, like "make push HUGO_VERSION=0.20 REPO=user/repo".
# https://hub.docker.com/_/alpine?tab=tags
ALPINE_VERSION?=3.15.0
# https://github.com/google/brotli/releases
BROTLI_VERSION?=1.0.9
# https://github.com/gohugoio/hugo/releases
HUGO_VERSION?=0.92.0
# https://www.musl-libc.org/download.html
MUSL_VERSION?=1.2.2

REPO?=marcaruel/hugo-tidy
TAG_NAME=hugo-${HUGO_VERSION}-alpine-${ALPINE_VERSION}-brotli-${BROTLI_VERSION}

BASE_DIR=$(shell pwd)
MUSL_DIR=${BASE_DIR}/musl-install
# Enable go mod support.
export GO111MODULE=on
# Disable cgo support.
export CGO_ENABLED=0


all: push_all

.PHONY: build clean push_all push_latest push_version

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

# Removed "${REPO}:" from tag since I don't want it to be able to fetch
# arbitrary docker images, there's value in hard coding this for safety for now.
build: brotli/bin/brotli
	docker build --build-arg "ALPINE_VERSION=${ALPINE_VERSION}" --build-arg "HUGO_VERSION=${HUGO_VERSION}" --tag ${REPO}:${TAG_NAME} .
	@echo ""
	@echo "Built ${TAG_NAME}"
	@echo ""
	@echo "${TAG_NAME}" > ./tag

push_version: build
	docker push ${REPO}:${TAG_NAME}

push_latest: build
	docker tag ${REPO}:${TAG_NAME} ${REPO}:latest
	docker push ${REPO}:latest

push_all: push_version push_latest

clean:
	rm -rf brotli musl ${MUSL_DIR}
