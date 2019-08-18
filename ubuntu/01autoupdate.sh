#!/bin/bash

# This automatic updates stuff is questionable.
# 1. When updates are fetched?
# 2. When server is rebooted?

echo "[ubuntu] --- enable automatic updates ---"

apt-get -y update
apt-get -y install unattended-upgrades
unattended-upgrades -v
