#!/bin/sh

# print command before executing
set -o xtrace

# calling snapcraft interactively from container without installing
podman run -it -v $PWD:/src:z -w /src snapcore/snapcraft:beta snapcraft "$@"

