# Copyright 2017 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.
#
# Doc: https://docs.docker.com/engine/reference/builder/

# TODO(make): Use ALPINE_VERSION, should be soon: https://github.com/docker/docker/issues/18119
FROM alpine:3.4
MAINTAINER Marc-Antoine Ruel <d@maruel.net>

ARG HUGO_VERSION
ARG PYGMENTS_VERSION

# Logic
COPY ["./docker-entrypoint.sh", "/usr/local/bin/docker-entrypoint.sh"]

# minify
COPY ["./minify", "/usr/local/bin/minify"]

# pygments
RUN apk update && apk add py-pygments && rm -rf /var/cache/apk/*

# hugo
ADD ["https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz", "/usr/local/hugo.tar.gz"]
RUN tar xzf /usr/local/hugo.tar.gz -C /usr/local/ && \
    mv /usr/local/hugo*/hugo* /usr/local/bin/hugo && \
    rm -rf /usr/local/hugo*

VOLUME /data
WORKDIR /data
ENTRYPOINT ["/bin/sh", "/usr/local/bin/docker-entrypoint.sh"]
