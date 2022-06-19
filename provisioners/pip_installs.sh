#!/usr/bin/env bash
set -o nounset
set -o errexit

#upgrade pip3
pip3 install --upgrade pip

#Install ansible
pip3 install ansible==4.10.0


#Install boto3
pip3 install boto3==1.23.10

#Install awscli
pip3 install awscli==1.24.10

#install botocore
pip3 install botocore==1.26.10

#install docker-py
pip3 install docker-py==1.10.6

#install wheel
pip3 install wheel==0.37.1

#install pandas
pip3 install pandas==1.1.5

#install datetime
pip3 install DateTime==4.4
