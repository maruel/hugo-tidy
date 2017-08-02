# High performance Hugo docker image

This image does one thing well: generate the fastest web site via Hugo.

It uses [Hugo](https://gohugo.io/), colorize code via
[Pygments](http://pygments.org/),
[minify](https://github.com/tdewolff/minify/cmd/minify) the code then generate
[brotli](https://github.com/google/brotli/) and gzip precompressed files so
[Caddy](https://caddyserver.com/) can serve the precompressed version directly
from disk with zero CPU over HTTPS via its native
[LetEncrypt](https://letsencrypt.org/) support.

Visit https://hub.docker.com/r/marcaruel/hugo-tidy/tags/ to see the current
tags.


## Features

- Fast. Generating a simple site takes 1.6 seconds, including syntax
  highlighting
- Runs as single step
- minifies the `.js`, `.css` and `.html`
- pre-generates `.br` and `.gz` files for high performance web serving
- images are properly tagged, so you know what versions are running


## Usage

- Hugo input must be in `./site`
- Generated website is in `./www`

```
docker run --rm -u $(id -u):$(id -g) -v $(pwd):/data marcaruel/hugo-tidy:hugo-0.25.1-alpine-3.6-pygments-2.2.0-brotli-0.6.0
```


## Making your own

Override `ALPINE_VERSION`, `BROTLI_VERSION`, `HUGO_VERSION`, `PYGMENTS_VERSION`
to select newer versions.

Override `REPO` to have it push to your repository.

To push an image on your name with a new version of Hugo, run the following:
```
make push HUGO_VERSION=0.99.1 REPO=user/repo
```


## Background

When searching for a Docker image with Hugo and Pygments included, I found many
but they were all in poor condition in different ways. Many do not have tags,
others use :latest so are not reproducible, many uses containers that are
neededlessly large, others forces you on on what it ran run, none minified, the
rest was stale.  How to fix it? By creating yet-another-image, obviously!


## References

A sample of images (!) as of 2017-03-11:

- https://github.com/alrayyes/docker-alpine-hugo-git-bash : Took inspiration,
  but was stale.
- https://github.com/ctrlok/docker-hugo : Not meant to be used directly, stale.
- https://github.com/giantswarm/hugo-docker : very stale
- https://github.com/jojomi/docker-hugo : Awesome but doesn't contain pygment
- https://github.com/jonathanbp/docker-alpine-hugo : Good but stale.
- https://github.com/Lexty/docker-hugo : Took inspiration, but was missing tags
  and was stale and the Makefile was weirdo.
- https://github.com/piotrkubisa/hugo-docker-images : Too heavy, includes golang
- https://github.com/publysher/docker-hugo : Too heavy, uses debian wheezy (too
  old too)
- https://github.com/wpk-/docker-hugo : Too heavy, includes golang and node
