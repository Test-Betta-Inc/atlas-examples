#!/usr/bin/env bash

echo Installing Ansible...
set -e

sudo rm -fR /var/lib/apt/lists/*
sudo apt-get update
sudo apt-get install -y python-software-properties
sudo add-apt-repository -y ppa:ansible/ansible
sudo apt-get update
sudo apt-get install -y ansible
