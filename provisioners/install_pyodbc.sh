#!/usr/bin/env bash
set -o nounset
set -o errexit

#Install pyodbc
yum install python3-pip gcc-c++ python3-devel unixODBC-devel -y
yum install unixODBC -y
yum install epel-release -y
yum install gcc-c++ -y
pip3 install pyodbc
