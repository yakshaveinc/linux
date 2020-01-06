#!/usr/bin/env bash

# name of current dir
NAME=$(basename "$PWD")

# https://unix.stackexchange.com/questions/432816/grab-id-of-os-from-etc-os-release/498788#498788
ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
VERSION=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')

OSTORUN="$ID/$VERSION"

if lxc info "$NAME" &> /dev/null
then
  echo "Running existing container '$NAME'"
else
  echo "Creating container '$NAME' ($OSTORUN)"
  lxc launch "images:$OSTORUN" "$NAME"
  if [[ ! -e ~/go/bin/ufs ]]; then
    echo "Mounting $PWD as /root/$NAME read-only"
    lxc config device add "$NAME" "$NAME-shared" disk source="$PWD" path="/root/$NAME"
  else
    echo "Sharing writeable $PWD as /root/$NAME"
    lxc config device add IPython shared9p proxy listen=tcp:127.0.0.1:3333 connect=tcp:127.0.0.1:3333 bind=host
    echo "Install https://github.com/aperezdc/9pfuse and "
    echo "run `9pfuse -D 127.0.0.1:3333 /root/$NAME` on guest."
  fi
fi

# https://stackoverflow.com/questions/7120426/how-to-invoke-bash-run-commands-inside-the-new-shell
lxc exec "$NAME" -- /bin/sh -c "cd $NAME; bash"

