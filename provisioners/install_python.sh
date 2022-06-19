#!/usr/bin/env bash
set -o nounset
set -o errexit

# Install python
yum update -y
yum groupinstall "Development Tools" -y
yum install openssl-devel libffi-devel bzip2-devel -y
yum install wget -y
wget https://www.python.org/ftp/python/3.10.5/Python-3.10.5.tgz
tar xvf Python-3.10.5.tgz
cd Python-3.10.5
./configure --enable-optimizations
make altinstall
yum install python3-pip -y
