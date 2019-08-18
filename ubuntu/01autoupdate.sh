
echo "[ubuntu] --- enable automatic updates ---"

apt-get -y update
apt-get -y install unattended-upgrades
unattended-upgrades -v
