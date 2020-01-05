#!/bin/sh

# print command before executing
set -o xtrace

# calling snapcraft interactively from container without installing
podman run --rm -it -v "$PWD":/src:Z -w /src yakshaveinc/snapcraft:core18 snapcraft "$@"

