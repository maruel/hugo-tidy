# Copyright 2017 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# Override these at the command like, like "make push HUGO_VERSION=0.20 REPO=user/repo".
# https://hub.docker.com/_/alpine/
ALPINE_VERSION?=3.6
# https://github.com/gohugoio/hugo/releases
HUGO_VERSION?=0.25.1
# https://pypi.python.org/pypi/Pygments
PYGMENTS_VERSION?=2.2.0
REPO?=marcaruel/hugo-tidy

all: push

.PHONY: build push

# Fetch if missing, do not update. Works around non-static build on go 1.8+
# TODO(maruel): pin it.
minify:
	go get -v -d github.com/tdewolff/minify/cmd/minify
	CGO_ENABLED=0 go build -a -o minify -installsuffix cgo github.com/tdewolff/minify/cmd/minify

build: ${GOPATH}/bin/minify
	docker build --build-arg "ALPINE_VERSION=${ALPINE_VERSION}" --build-arg "HUGO_VERSION=${HUGO_VERSION}" --build-arg "PYGMENTS_VERSION=${PYGMENTS_VERSION}" --tag ${REPO}:latest .

push: build
	docker tag ${REPO}:latest ${REPO}:hugo-${HUGO_VERSION}-alpine-${ALPINE_VERSION}-pygments-${PYGMENTS_VERSION}
	docker push ${REPO}:hugo-${HUGO_VERSION}-alpine-${ALPINE_VERSION}-pygments-${PYGMENTS_VERSION}
	docker push ${REPO}:latest
