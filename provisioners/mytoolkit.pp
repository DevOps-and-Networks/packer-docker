# TODO: move the base_dir below to a Hiera config
$base_dir = '/root/'

class { 'nodejs':
  repo_url_suffix       => '14.x',
  nodejs_package_ensure => '14.17.0',

# nestor is used for triggering and integration testing Jenkins pipelines,
# it is written in node.js, and we ended up using this because there was no
# Python-based Jenkins CLI that works with Jenkins crumb.
} -> package { 'nestor':
  ensure   => '2.2.0',
  provider => 'npm',

# open-sesame is used as a convenient utility tool for allowing inbound rule
# from the public IP where the engineer is working from, it's only used for
# build and development purposes
} -> package { 'open-sesame':
  ensure   => '1.1.0',
  provider => 'npm',

# rtk is used for automating repo release process (versioning, tagging)
} -> package { 'rtk':
  ensure   => '2.0.0',
  provider => 'npm',

}
# shellcheck is not officialy released in NPM so it had to be installed via shell commands
exec { 'npm install --dev shellcheck@1.0.0':
  path => ['/bin', '/usr/local/bin', '/usr/bin'],
}

package { ['git', 'unzip', 'wget', 'jq', 'python38-devel']:
  ensure   => 'present',
  provider => 'yum',
}

archive { '/usr/local/bin/packer-post-processor-json-updater':
  source => 'https://github.com/cliffano/packer-post-processor-json-updater/releases/download/v1.2/packer-post-processor-json-updater_linux_amd64',
} -> file { '/usr/local/bin/packer-post-processor-json-updater':
  ensure => 'file',
  mode   => '0755',
}

class { 'java':
  distribution => 'jdk',
}

class { 'python':
  ensure     => 'present',
  dev        => 'present',
  pip        => 'present',
}

exec { 'pip3 install --upgrade pip==21.1.2':
  path => ['/bin', '/usr/local/bin', '/usr/bin'],
} -> package{ 'awscli':
  ensure   => '1.19.91',
  provider => pip3,
} 


file { '/home/.virtualenvs':
  ensure => 'directory',
  owner  => 'root',
  mode   => '0755',
}

# virtualenv is used for building python virtualenvs
# it can be awaken by activate command
python::pyvenv { '/home/.virtualenvs/py38':
  ensure     => present,
  version    => '3.8',
  owner      => 'root',
  group      => 'root',
}

file_line { 'Set virtualenv alias for activating the current Python 3':
  path => "${base_dir}/.bashrc",
  line => "alias py3='source /home/.virtualenvs/py36/bin/activate'",
}

