#!/bin/bash
source /etc/os-release
export LC_ALL=C

echo "Install Python for" $ID

if [[ "$ID" == "centos" ]]; then
  yum install -y epel-release
  yum install -y centos-release-scl
  yum install -y python36 python36-setuptools libselinux-python
  easy_install-3.6 pip
  ln -fs /usr/local/bin/pip /usr/bin/pip
elif [[ "$ID" == "rhel" ]]; then
  yum install -y epel-release
  yum install -y python36 python36-setuptools libselinux-python
  easy_install-3.6 pip
  ln -fs /usr/local/bin/pip /usr/bin/pip
elif [[ "$ID" == "fedora" ]]; then
  yum install -y epel-release
  yum install -y python36-setuptools
  easy_install-3.6 pip
  ln -fs /usr/bin/python3.6 /usr/bin/python3
  ln -fs /usr/local/bin/pip /usr/bin/pip
  yum install -y libselinux-python
elif [[ "$ID" == "debian" ]]; then
  apt-get update && apt-get install -y python3 python3-pip python-minimal
  ln -fs /usr/bin/pip3 /usr/bin/pip
elif [[ "$ID" == "ubuntu" ]]; then
  apt-get update && apt-get install -y python3 python3-pip python-minimal
  ln -fs /usr/bin/pip3 /usr/bin/pip
elif [[ "$ID" == "amzn" ]]; then
  yum install -y python3-pip python3 python3-setuptools
  ln -fs /usr/bin/pip3 /usr/bin/pip
fi

pip install --upgrade pip
