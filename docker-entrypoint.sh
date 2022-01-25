#!/bin/bash
# Copyright 2017 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

set -eu

# Preparation

if [ ! -d site ]; then
  echo "./site is expected, did you forget to map it? Found:"
  ls -la
  exit 1
fi


# If a subcommand is passed, run it as-is. Normally the user would pass
# 'server'.
if [ $# != 0 ] && [ "${1:0:1}" != "-" ]; then
  echo "- Running $(hugo version)"
  echo "  with args: $@"
  /usr/local/bin/hugo --source site --destination ../www.new --buildFuture "$@"
  exit 0
fi


# 1. Remove any stale junk if any.
if [ -e www.old ]; then
  echo "- Removing www.old"
  rm -rf www.old
fi

if [ -e www.new ]; then
  echo "- Removing www.new"
  rm -rf www.new
fi


## Generation

# 2. Do the generation of the static web site.
echo "- Running $(hugo version) $@"
/usr/local/bin/hugo --source site --destination ../www.new --buildFuture "$@"


# 3. Precompress all the files, so caddy can serve pre-compressed files without
# having to compress on the fly, leading to zero-CPU static file serving.

# 3.1. gzip
echo "- Compressing gzip"
# Note: gzip included in busybox doesn't support -k so workaround with sh.
find www.new -type f \( -name '*.html' -o -name '*.js' -o -name '*.css' -o -name '*.xml' -o -name '*.svg' \) \
  -exec /bin/sh -c 'gzip -v -f -9 -c "$1" > "$1.gz"' /bin/sh {} \;

# 3.2. brotli
echo "- Compressing brotli"
find www.new -type f \( -name '*.html' -o -name '*.js' -o -name '*.css' -o -name '*.xml' -o -name '*.svg' \) \
  -exec /bin/sh -c '/usr/local/bin/brotli -q 11 -o "$1.br" "$1"' /bin/sh {} \;


## Making it live

# 4. Now that the new site is ready, switch the old site for the new one.
if [ -d www ]; then
  echo "- Moving www to www.old"
  mv www www.old
fi
echo "- Moving www.new to www"
mv www.new www
echo "- Removing www.old"
rm -rf www.old

# Cheezy.
#chown -R 1000:1000 /data
