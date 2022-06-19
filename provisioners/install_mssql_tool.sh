#!/usr/bin/env bash
set -o nounset
set -o errexit


#Download appropriate package for the OS version
#Choose only ONE of the following, corresponding to your OS version

#Red Hat Enterprise Server 6 (only supported up to driver version 17.7)
curl https://packages.microsoft.com/config/rhel/6/prod.repo > /etc/yum.repos.d/mssql-release.repo

#Red Hat Enterprise Server 7 and Oracle Linux 7
curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/mssql-release.repo

#Red Hat Enterprise Server 8 and Oracle Linux 8
curl https://packages.microsoft.com/config/rhel/8/prod.repo > /etc/yum.repos.d/mssql-release.repo

yum remove unixODBC-utf16 unixODBC-utf16-devel #to avoid conflicts
ACCEPT_EULA=Y yum install -y msodbcsql17
# optional: for bcp and sqlcmd
ACCEPT_EULA=Y yum install -y mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
# source ~/.bashrc
# optional: for unixODBC development headers
yum install -y unixODBC-devel
