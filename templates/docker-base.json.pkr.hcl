# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source = "github.com/hashicorp/docker"
    }
  }
}

variable "image_name" {
  type = string
}

variable "repository" {
  type = string
}

variable "timezone" {
  type = string
}

variable "version" {
  type = string
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "docker" "autogenerated_1" {
  changes     = ["ENV LANG en_US.UTF-8", "ENV TZ ${var.timezone}", "ENV PATH /opt/puppetlabs/puppet/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"]
  commit      = true
  image       = "centos:centos8"
  run_command = ["--privileged", "-e", "container=docker", "-v", "/sys/fs/cgroup:/sys/fs/cgroup", "-d", "-i", "-t", "{{ .Image }}", "/usr/bin/bash"]
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.docker.autogenerated_1"]

  provisioner "shell" {
    script = "provisioners/pre-req.sh"
  }

  provisioner "shell" {
    script = "provisioners/install_python.sh"
  }

  provisioner "shell" {
    script = "provisioners/install_mssql_tool.sh"
  }

  provisioner "shell" {
    script = "provisioners/pip_installs.sh"
  }

  provisioner "shell" {
    script = "provisioners/install_pyodbc.sh"
  }

  provisioner "shell" {
    script = "provisioners/install_kubectl.sh"
  }

  provisioner "file" {
    destination = "/bin/exporter.sh"
    source      = "templates/bash/python_prometheus.sh"
  }

  provisioner "file" {
    destination = "/bin/mssql_to_s3_exporter.py"
    source      = "templates/python/mssql_to_s3_exporter.py"
  }

  provisioner "file" {
    destination = "/bin/python_prometheus.py"
    source      = "templates/python/python_prometheus.py"
  }

  post-processor "docker-tag" {
    repository = "${var.repository}/${var.image_name}"
    tags = [ "${var.version}" , "latest"]
  }

}
