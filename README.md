# High performance Hugo docker image

This image does one thing well: generate the fastest web site via Hugo.

It uses [Hugo](https://gohugo.io/),
[minify](https://github.com/tdewolff/minify/cmd/minify) the code then generate
[brotli](https://github.com/google/brotli/) and gzip precompressed files.

This enables [Caddy](https://caddyserver.com/) to serve the precompressed
version directly from disk with zero CPU over HTTPS via its native
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

```shell
docker run --rm -u $(id -u):$(id -g) -v $(pwd):/data marcaruel/hugo-tidy:latest
```

*Note*: it is highly recommended to pin to a specific version listed at
[hub.docker.com/r/marcaruel/hugo-tidy/tags/](https://hub.docker.com/r/marcaruel/hugo-tidy/tags/).


## Making your own

Override `ALPINE_VERSION`, `BROTLI_VERSION`, `HUGO_VERSION`, to select newer
versions.

Override `REPO` to have it push to your repository.

To push an image on your name with a new version of Hugo, run the following:
```
make push HUGO_VERSION=0.99.1 REPO=user/repo
```


## Release process

Run `./compare.sh` and if it reports not difference, then you can just run `make
push_all`.

Otherwise inspect the differences before pushing:

```shell
# Create a local image.
$ make build

# Push the version without updating latest
$ make push_version

# Update the 'latest' tag
$ make push_latest

# Push and update 'latest'
$ make push_all

# Cleanup
$ make clean
```

## Background

When searching for a Docker image with Hugo included, I found many but they were
all in poor condition in different ways. Many do not have tags, others use
:latest so are not reproducible, many uses containers that are neededlessly
large, others forces you on on what it ran run, none minified, the rest was
stale.  How to fix it? By creating yet-another-image, obviously!
