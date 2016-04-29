#!/bin/bash

set -ex

sudo apt-get -y update

# install dependencies
echo "Installing dependencies..."
sudo apt-get install -y curl
sudo apt-get install -y unzip

# install nomad
echo "Fetching nomad..."
cd /tmp/
wget -q https://dl.bintray.com/mitchellh/nomad/nomad_0.1.2_linux_amd64.zip -O nomad.zip

echo "Installing nomad..."
unzip nomad.zip
sudo chmod +x nomad
sudo mv nomad /usr/bin/nomad
sudo mkdir -m 777 /etc/nomad.d
sudo chmod a+w /var/log
sudo chmod a+w /etc/init/

# setup nomad directories
sudo mkdir -p /opt/nomad/data

echo "Nomad installation complete."
