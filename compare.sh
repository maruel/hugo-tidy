#!/bin/bash
# Copyright 2019 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

set -eu
cd "$(dirname $0)"

echo "Checking out latest of https://github.com/periph/website"
if [ ! -d ./website ]; then
  git clone https://github.com/periph/website
fi
cd website
git clean -f -d -x
git reset --hard
git pull
cd ..

make build
PREVIOUS="$(cat ./website/tag)"
CURRENT="$(cat ./tag)"

./website/gen.sh
mv ./website/www ./website/www1

echo "${CURRENT}" > ./website/tag
./website/gen.sh

echo ""
echo "Comparing:"
echo "  - ${PREVIOUS}"
echo "  - ${CURRENT}"
echo ""
if (diff -r -w -x *.br -x *.gz -q ./website/www1 ./website/www > /dev/null); then
  echo "No content difference found!"
  exit 0
fi

echo "A difference was found, manually inspect the websites if necessary:"
echo "  go get github.com/maruel/serve-dir"
echo "  serve-dir --port=3132 -root=./website/www1"
echo "  serve-dir --port=3133 -root=./website/www"
echo ""
git diff -U0 --word-diff --no-index -- ./website/www1 ./website/www
exit 1
