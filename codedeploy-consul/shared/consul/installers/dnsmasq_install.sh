#!/bin/bash

set -ex

sudo apt-get -y update

echo "Installing dnsmasq..."
sudo apt-get install -y dnsmasq-base dnsmasq

echo "Configuring dnsmasq..."
sudo sh -c 'echo "server=/consul/127.0.0.1#8600" > /etc/dnsmasq.d/10-consul'

echo "Restarting dnsmasq..."
sudo service dnsmasq restart

echo "dnsmasq installation complete."
