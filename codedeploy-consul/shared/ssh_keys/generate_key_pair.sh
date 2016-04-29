#!/bin/bash

KEY_PATH="shared/ssh_keys"
KEY_NAME=codedeploy-consul

PRIVATE_KEY_PATH="$KEY_PATH/$KEY_NAME.pem"
PUBLIC_KEY_PATH="$KEY_PATH/$KEY_NAME.pub"

if [ ! -d "$KEY_PATH" ]; then
  echo "Directory [$KEY_PATH] does not exist. This script must be run from the 'codedeploy-consul' directory."
  exit 1
fi

openssl genrsa -out $PRIVATE_KEY_PATH 1024
chmod 700 $PRIVATE_KEY_PATH
ssh-keygen -y -f $PRIVATE_KEY_PATH > $PUBLIC_KEY_PATH
chmod 700 $PUBLIC_KEY_PATH

echo ""
echo "Public key: $PUBLIC_KEY_PATH"
echo "Private key: $PRIVATE_KEY_PATH"
echo ""
