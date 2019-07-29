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
echo "Comparing ${PREVIOUS} and ${CURRENT}."
echo "If a difference is found, look at the website:"
echo "  ./website/serve.sh"
echo ""
diff -r -u -w -x *.br -x *.gz -q ./website/www1 ./website/www
