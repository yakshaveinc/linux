#!/usr/bin/env bash
#
# Securely run current directory in unprivileged Linux container.
#
# * Mounts current dir to `/workdir` volume (`whalebrew` convention)
# * Containers are interactive with terminal attached `-it`
# * Cleaned up automatically `--rm`
# * SELinux labels are disabled
#
USAGE="Usage: runin-podman.sh <image> [arguments..]

To print script messages to stderr, set VERBOSE to any value.

  VERBOSE=1 runin-podman.sh alpine

To save container before exit.

   podman container clone <id>
   podman start --attach <id>"


# Exit when any command fails
set -e

#######################################
# Runs container while relabelling volumes for SELinux,
# passing arguments. Container is destroyed on exit.
# Globals:
#   DIRNAME
# Arguments:
#   image name and additional podman parameters
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
#   image name and additional podman parameters
#######################################
just_run() {
   podman run -it --rm --security-opt label=disable \
      -v "$PWD:/workdir" -w "/workdir" "$@"
   # -t   -- allocate TTY
   # -i   -- keep STDIN open
   # --rm -- remove after stop
   # --security-opt label=disable -- disable SELinux
}


#######################################
# Reads UID for USER from image filesystem.
# Globals:
#   IMAGE
#   IMGUSER
#   VERBOSE
# Outputs:
#   Writes UID to stdout, exits on error
image_uid() {
  # Create but don't run
  # https://unix.stackexchange.com/questions/331645/extract-file-from-docker-image/370221#370221
  container=$(podman create "$IMAGE")
  if "$VERBOSE"; then
    echo "runin: Checking /etc/passwd for '$IMGUSER' in ${container::12}" >&2
  fi
  passwdline=$(podman cp "$container:/etc/passwd" - | grep --text "^$IMGUSER:")
  if [[ -z "$passwdline" ]]; then
    echo >&2
    echo "Error: No USER in /etc/passwd (container ${container::12} is not removed)" >&2
    exit 1
  fi
  podman rm "$container" > /dev/null
  echo "$passwdline" | cut -f3 -d:
}

#### What is SELinux anyway? Why it is turned off?
#
# SELinux is a stuff that labels files on disk. Then reads labels to check
# if a process can access these files. :z :Z flags to volumes in
# run_with_selinux() function are instuction to relabel files so that `podman`
# can read/write them.
#
# The problem with labels is that file can only have one label. So if your
# file had label, and you mounted a volume with it passing :z or :Z, your label
# will be lost. If you pass you home to `podman` this way, some programs may
# stop working, and you may experience a problem logging in.
#
# That's why `runin-podman.sh` uses just_run() function that turns off SELunux.
#
# Concerns over using :z :Z and $HOME mounts.
# * https://github.com/kaitai-io/kaitai_struct_visualizer/pull/44/files#r543594607
# * https://github.com/containers/podman/issues/8786
#

#### Images with USER
#
# When an image contains USER directive, the container won't be able to write
# to volumes, because podman assigns that container UID and GID that are different
# from chown/chmod attributes on filesystem. That's why such images are executed
# with --userns=keep-id which does some magic mapping.
#
# https://github.com/containers/podman/discussions/16258

#### This script (non-)implemented features compared to alternatives
#
# [ ] reentry the container if you quit
# [x] mount volumes without SELinux (which otherwise requires :Z or :z flags)
# [x] container is interactive by default
# [x] current dir (PWD) is a volume at /workdir
# [ ] default image if no image is specified

#### Comparison with containers/toolbox
#
# Some script features are addressed by https://github.com/containers/toolbox but
# it has a serious security issue that in addition to PWD, `toolbox` also makes the
# whole HOME directory r/w accessible.
#
# That means SSH keys are readable, setup / test scripts can mess with
# dotfiles. While the `toolbox` may be useful for OS developers, who need to
# test package installation and rollback, it is not secure enough to run
# random projects from GitHub in isolation.


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


# Inspect the image before running it

CMD="podman image exists $IMAGE"
if $CMD; then
  if "$VERBOSE"; then
    echo "runin: Using existing '$IMAGE' image" >&2
  fi
else
  if "$VERBOSE"; then
    echo "runin: Pulling '$IMAGE' image" >&2
  fi
  podman pull "$IMAGE"
fi

# Detect if an image uses USER as it needs special handling
# https://github.com/containers/podman/discussions/16258#discussioncomment-3962829
if "$VERBOSE"; then
  echo "runin: Checking if '$IMAGE' uses USER" >&2
fi
IMGUSER=$(podman image inspect --format '{{.Config.User}}' "$IMAGE")
if [[ -z "$IMGUSER" ]]; then
  just_run "$@"
  #run_with_selinux "$@"
else
  if "$VERBOSE"; then
    echo "runin: Image '$IMAGE' runs with custom USER '$IMGUSER'" >&2
    echo "runin: Getting UID for '$IMGUSER' USER for mapping filesystem access" >&2
  fi
  IMGUID=$(image_uid)
  if "$VERBOSE"; then
    echo "runin: Running podman with --userns=keep-id:uid=$IMGUID" >&2
  fi
  just_run "--userns=keep-id:uid=$IMGUID" "$@"
fi
