#!/usr/bin/env bash
#
# Securely run current directory in unprivileged Linux container.
#
# * Mounts current dir to `/workdir` volume (`whalebrew` convention)
# * Containers are interactive with terminal attached `-it`
# * Cleaned up automatically `--rm`
#
USAGE="Usage: runin-podman.sh <image> [arguments..]

Set VERBOSE to any value to print script messages to stderr."


# Exit when any command fails
set -e

#######################################
# Runs container while relabelling volumes for SELinux,
# passing arguments. Container is destroyed on exit.
# Globals:
#   DIRNAME
# Arguments:
#   image name and the rest of command line parameters
#######################################
run_with_selinux() {
   podman run -it --rm -v "$PWD:/workdir":Z -w "/workdir" "$@"
   # -t   -- allocate TTY
   # -i   -- keep STDIN open
   # --rm -- remove after stop
}

#######################################
# Runs container, without SELinux limitations.
# passing arguments to it. Container is destroyed on exit.
# Globals:
#   DIRNAME
# Arguments:
#   image name and the rest of command line parameters
#######################################
just_run() {
   podman run -it --rm --security-opt label=disable \
      -v "$PWD:/workdir" -w "/workdir" "$@"
   # -t   -- allocate TTY
   # -i   -- keep STDIN open
   # --rm -- remove after stop
   # --security-opt label=disable -- disable SELinux
}


#### To save container before removal 
#
# podman container clone <id>
# podman start --attach <id>
#
#### What is SELinux anyway?
#
# SELinux is a stuff that labels files on disk. Then reads labels to checks
# if a process can access these files. :z :Z flags to volumes in
# run_with_selinux() function are instuction to relabel files so that `podman`
# can read/write them.
#
# The problem with labels is that there can be only one on a file. So if your
# file had label, and you mounted a volume with it passing :z or :Z, you label
# will be lost. If you pass you home to `podman` this way, some programs may
# stop working, and you may experience a problem logging in.
#
# That's why `runin-podman.sh` uses just_run() function that turns off SELunux.
#
#### Other things to be aware if
#
# If an image contains USER directive, there might be need to use share/unshare
# commands to give container write access to volumes.
#
# Concerns over using :z :Z and $HOME mounts.
# * https://github.com/kaitai-io/kaitai_struct_visualizer/pull/44/files#r543594607
# * https://github.com/containers/podman/issues/8786
#
#### This script and alternatives
#
# [ ] you can not reentry the container if you quit
# [x] current directory is not mounted by default (with necessary :Z flag for Fedora)
# [x] container is not interactive be default
# [ ] there is no default image
#
# all these problem are addressed by https://github.com/containers/toolbox but
# it also adds a serious security issue
#
# [x] `toolbox` makes the whole HOME directory r/w accessible
#
# that means SSH keys are readable, setup / test scripts can mess with
# dotfiles. while the `toolbox` may be useful for OS developers, who need to
# test package installation and rollback, it is not secure enough to run
# random projects from GitHub in isolation


IMAGE=$1
VERBOSE=${VERBOSE:+true}   # set to `true` command if any value is set
VERBOSE=${VERBOSE:-false}  # set to `false` command if unset

if [ -z "$IMAGE" ]; then
  echo "$USAGE"
  if "$VERBOSE"; then
    echo >&2
    echo "Error: missing required <image> argument" >&2
  fi
  exit 1
fi


CMD="podman image exists $IMAGE"
if $CMD; then
  if "$VERBOSE"; then
    echo "runin: Using existing '$IMAGE' image ..." >&2
  fi
else
  if "$VERBOSE"; then
    echo "runin: Pulling '$IMAGE' image ..." >&2
  fi
  podman pull "$IMAGE"
fi

just_run "$@"
#run_with_selinux "$@"
