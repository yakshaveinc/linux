#!/usr/bin/env bash

# name of current dir
NAME=$(basename "$PWD")

podman run -v "$(pwd):/root/$NAME":Z -w "/root/$NAME" -it "$@"
# -t   -- allocate TTY
# -i   -- keep STDIN open

