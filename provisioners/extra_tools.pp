# TODO: move the base_dir below to a Hiera config
$base_dir = '/root/'

class { 'nodejs':
  repo_url_suffix       => '14.x',
  nodejs_package_ensure => '14.17.0',


# rtk is used for automating repo release process (versioning, tagging)
} -> package { 'rtk':
  ensure   => '2.0.0',
  provider => 'npm',

}
# shellcheck is not officialy released in NPM so it had to be installed via shell commands
exec { 'npm install --dev shellcheck@1.0.0':
  path => ['/bin', '/usr/local/bin', '/usr/bin'],
}

package { ['git', 'unzip', 'wget', 'jq']:
  ensure   => 'present',
  provider => 'yum',
}

class { 'java':
  distribution => 'jdk',
}
