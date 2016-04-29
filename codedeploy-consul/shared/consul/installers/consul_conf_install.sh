#!/bin/bash

set -ex

sudo mv /tmp/consul.conf /etc/init/
sudo mv /tmp/consul.json.tmp /etc/consul.d/
