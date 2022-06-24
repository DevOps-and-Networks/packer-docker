#!/usr/bin/env bash
wget https://releases.hashicorp.com/packer/1.8.1/packer_1.8.1_linux_amd64.zip
unzip packer_1.8.1_linux_amd64.zip
mv packer /usr/local/bin/.
rm packer_1.8.1_linux_amd64.zip
