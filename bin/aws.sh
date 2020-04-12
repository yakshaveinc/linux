#!/bin/bash

GITROOT=$(git rev-parse --show-toplevel)

podman run --rm -it -v "$GITROOT/.aws":/root/.aws:Z -v "$(pwd):/aws":Z amazon/aws-cli "$@"
