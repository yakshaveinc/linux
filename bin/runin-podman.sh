#!/usr/bin/env bash

# name of current dir
NAME=$(basename "$PWD")

podman run -v "$(pwd):/root/$NAME":Z -w "/root/$NAME" -it "$@"
# -t   -- allocate TTY
# -i   -- keep STDIN open

# running podman/docker is not trivial and not convenient  - need to be aware
# to :z :Z flags to volumes, -it flags to execute commands in the shell, need
# to understand how share/unshare works if container specifies USER directive
#
# `runin-podman.sh` tries to address some problems with that
#
# [ ] you can not reentry the container if you quit
# [x] current directory is not mounted by default (with necessary :Z flag for Fedora)
# [x] container is not interactive be default
# [ ] there is no default image
#
# all these problem are addressed by https://github.com/containers/toolbox but
# it also add a serious security issue
#
# [x] `toolbox` makes the whole HOME directory r/w accessible
#
# that means SSH keys are readable, setup / test scripts can mess with
# dotfiles. while the `toolbox` may be useful for OS developers, who need to
# test package installation and rollback, it is not secure enough to run
# random projects from GitHub in isolation
#
# ---
#
# more concerns over using :Z and $HOME mounts
# * https://github.com/kaitai-io/kaitai_struct_visualizer/pull/44/files#r543594607
# * https://github.com/containers/podman/issues/8786
