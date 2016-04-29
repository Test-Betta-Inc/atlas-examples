#!/bin/bash

set -ex

REGION=us-east-1

# install dependencies
echo "Installing dependencies..."
sudo apt-get install -y python-pip ruby2.0 awscli

# install consul
echo "Fetching codedeploy-agent..."
aws s3 cp s3://aws-codedeploy-${REGION}/latest/install . --region ${REGION}

echo "Installing codedeploy-agent..."
chmod +x ./install
sudo ./install auto
