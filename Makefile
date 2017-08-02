# Copyright 2017 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# This makefile currently assumes linux host. Please submit a PR to port it to
# your preferred OS.

# Override these at the command like, like "make push HUGO_VERSION=0.20 REPO=user/repo".
# https://hub.docker.com/_/alpine/
ALPINE_VERSION?=3.6
# https://github.com/google/brotli
BROTLI_VERSION?=0.6.0
# https://github.com/gohugoio/hugo/releases
HUGO_VERSION?=0.25.1
# https://pypi.python.org/pypi/Pygments
PYGMENTS_VERSION?=2.2.0
# https://www.musl-libc.org/download.html
MUSL_VERSION?=1.1.16

REPO?=marcaruel/hugo-tidy
TAG_NAME=hugo-${HUGO_VERSION}-alpine-${ALPINE_VERSION}-pygments-${PYGMENTS_VERSION}-brotli-${BROTLI_VERSION}

NPROCS=$(shell grep -c ^processor /proc/cpuinfo)
BASE_DIR=$(shell pwd)
MUSL_DIR=${BASE_DIR}/musl-install

all: push_all

.PHONY: build clean push

# Fetch if missing, do not update. Works around non-static build on go 1.8+
# TODO(maruel): pin it.
minify:
	go get -v -d github.com/tdewolff/minify/cmd/minify
	CGO_ENABLED=0 go build -a -o minify -installsuffix cgo github.com/tdewolff/minify/cmd/minify

musl:
	git clone git://git.musl-libc.org/musl -b v${MUSL_VERSION}

musl/obj/musl-gcc: musl
	cd musl && git fetch && git checkout v${MUSL_VERSION} && ./configure --prefix=${MUSL_DIR} --disable-shared && make -j${NPROCS}

musl-install: musl/obj/musl-gcc
	cd musl && make install

brotli:
	git clone https://github.com/google/brotli -b v${BROTLI_VERSION}

# This is important to build brotli as a static executable. You can verify with:
#   readelf -d bro
#
brotli/bin/bro: brotli musl/obj/musl-gcc
	cd brotli && git fetch && git checkout v${BROTLI_VERSION} && CC="${MUSL_DIR}/bin/musl-gcc -static" make -j${NPROCS} bro

build: minify brotli/bin/bro
	docker build --build-arg "ALPINE_VERSION=${ALPINE_VERSION}" --build-arg "HUGO_VERSION=${HUGO_VERSION}" --build-arg "PYGMENTS_VERSION=${PYGMENTS_VERSION}" --tag ${REPO}:latest .
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
	rm -rf brotli minify musl musl-install
