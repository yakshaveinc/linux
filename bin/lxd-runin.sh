#!/usr/bin/env bash

# name of current dir
NAME=$(basename $PWD)

# https://unix.stackexchange.com/questions/432816/grab-id-of-os-from-etc-os-release/498788#498788
ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
VERSION=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')

OSTORUN="$ID:$VERSION"

if lxc info $NAME &> /dev/null
then
  echo "Running existing container '$NAME'"
else
  echo "Creating container '$NAME' ($OSTORUN)"
  lxc launch $OSTORUN $NAME
  lxc config device add $NAME $NAME-shared disk source=$PWD path=/root/$NAME
fi

# https://stackoverflow.com/questions/7120426/how-to-invoke-bash-run-commands-inside-the-new-shell
lxc exec $NAME -- /bin/sh -c "cd $NAME; bash"

