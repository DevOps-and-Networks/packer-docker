#!/usr/bin/env bash
set -o nounset
set -o errexit

rpm -ivh --force https://yum.puppetlabs.com/puppet7/puppet7-release-el-8.noarch.rpm
yum -y install puppet-agent-7.7.0 pdk-2.1.0.0 epel-release
yum -y groupinstall 'Development Tools'

# Enable the rhui-REGION-rhel-server-optional to install ruby-devel
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
# yum config-manager --set-enabled powertools
yum -y install yum-utils
# yum-config-manager --enable rhui-REGION-rhel-server-optional
yum -y install which make ruby-devel zlib-devel

# Use DNF to install GitHub CLI, required due to Snap currently not supporting Docker
yum -y install dnf dnf-plugins-core
dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
dnf install gh -y

# Install Docker CE as per https://docs.docker.com/engine/install/centos/
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce docker-ce-cli containerd.io
yum list docker-ce --showduplicates | sort -r

# Install Terraform there is no puppet module that support version 1.0.0
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform-1.0.0

# dnf config-manager --disable https://github.com/koalaman/shellcheck
# dnf install shellcheck -y
# Install Terraform there is no puppet module that support version 1.0.0
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install packer-1.7.2

# Puppet Info
/opt/puppetlabs/puppet/bin/ruby --version
/opt/puppetlabs/puppet/bin/gem --version
/opt/puppetlabs/puppet/bin/puppet --version
/opt/puppetlabs/puppet/bin/facter --version
/opt/puppetlabs/puppet/bin/hiera --version
/opt/puppetlabs/pdk/bin/pdk --version
