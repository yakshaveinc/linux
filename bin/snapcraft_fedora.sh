#!/bin/sh

# print command before executing
set -o xtrace

IMAGE="${IMAGE:-yakshaveinc/snapcraft:core18}"

# calling snapcraft interactively from container without installing
podman run --rm -it -v "$PWD":/src:Z -w /src "$IMAGE" snapcraft "$@"

