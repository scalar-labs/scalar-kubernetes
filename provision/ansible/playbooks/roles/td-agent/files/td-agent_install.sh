#!/bin/bash
source /etc/os-release

echo "Install td-agent for" $ID

if [[ "$ID" == "centos" ]]; then
  curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent3.sh | sh
elif [[ "$ID" == "debian" ]]; then
  curl -L https://toolbelt.treasuredata.com/sh/install-debian-$(lsb_release -cs)-td-agent3.sh | sh
elif [[ "$ID" == "ubuntu" ]]; then
  curl -L https://toolbelt.treasuredata.com/sh/install-ubuntu-$(lsb_release -cs)-td-agent3.sh | sh
elif [[ "$ID" == "amzn" ]]; then
  curl -L https://toolbelt.treasuredata.com/sh/install-amazon2-td-agent3.sh | sh
fi
