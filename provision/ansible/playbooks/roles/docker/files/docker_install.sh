#!/bin/bash
source /etc/os-release

echo "Install Docker for" $ID

if [[ "$ID" == "centos" ]]; then
  yum install -y yum-utils device-mapper-persistent-data lvm2 curl
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install -y docker-ce docker-ce-cli containerd.io
elif [[ "$ID" == "fedora" ]]; then
  dnf -y install dnf-plugins-core curl
  dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  dnf -y install docker-ce docker-ce-cli containerd.io
elif [[ "$ID" == "debian" ]]; then
  apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
  apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
elif [[ "$ID" == "ubuntu" ]]; then
  apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
elif [[ "$ID" == "amzn" ]]; then
  amazon-linux-extras install -y docker
  yum install -y curl
fi

#Install Docker-Compose
curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod 755 /usr/local/bin/docker-compose
