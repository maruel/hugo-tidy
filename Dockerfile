# Copyright 2017 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.
#
# Doc: https://docs.docker.com/engine/reference/builder/

ARG ALPINE_VERSION

FROM alpine:${ALPINE_VERSION}

MAINTAINER Marc-Antoine Ruel <d@maruel.net>

ARG HUGO_VERSION

# Logic
COPY ["./docker-entrypoint.sh", "/usr/local/bin/docker-entrypoint.sh"]

# minify
COPY ["./minify", "/usr/local/bin/minify"]

# brotli
COPY ["./brotli/bin/brotli", "/usr/local/bin/brotli"]

# hugo
ADD ["https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz", "/usr/local/hugo.tar.gz"]
RUN tar xz -f /usr/local/hugo.tar.gz -C /usr/local/bin/ hugo

VOLUME /data
WORKDIR /data
ENTRYPOINT ["/bin/sh", "/usr/local/bin/docker-entrypoint.sh"]
