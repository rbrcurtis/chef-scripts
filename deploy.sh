#!/bin/bash

# Usage: ./deploy.sh [host]

host="${1:-ryan@172.16.245.132}"

# The host key might change when we instantiate a new VM, so
# we remove (-R) the old host key from known_hosts
ssh-keygen -R "${host#*@}" 2> /dev/null

ssh $host "sudo mkdir -p /etc/nginx/certs"
scp ~/Dropbox/ssh/go.mut8ed.com.* $host:
ssh $host 'sudo mv ~/go.mut8ed.com.* /etc/nginx/certs/;sudo chown -R root:root /etc/nginx/certs*'

tar cj . | ssh -o 'StrictHostKeyChecking no' "$host" '
sudo rm -rf ~/chef &&
mkdir ~/chef &&
cd ~/chef &&
tar xj &&
sudo bash install.sh'

