# Class: rabbitmq::server
#
# This module manages the installation and config of the rabbitmq server
#   it has only been tested on certain version of debian-ish systems
# Parameters:
#  [*port*] - port where rabbitmq server is hosted
#  [*delete_guest_user*] - rather or not to delete the default user
#  [*package_name*] - name of rabbitmq package
#  [*version*] - version of rabbitmq-server to install
#  [*service_name*] - name of rabbitmq service
#  [*service_ensure*] - desired ensure state for service
#  [*node_ip_address*] - ip address for rabbitmq to bind to
#  [*basedir*] - default directory for data, defaults to /var/lib/rabbitmq
#  [*config*] - contents of config file. You can either provide this parameter,
#               or use one of these: rabbitmq::config::shovel, rabbitmq::config::cluster, rabbitmq::config::stomp
#  [*env_config*] - contents of env-config file
# Requires:
#  stdlib
# Sample Usage:
#
# Use rabbitmq::config::shovel to define shovel(s).
#
class rabbitmq::server (
  $port = '5672',
  $delete_guest_user = false,
  $package_name = 'rabbitmq-server',
  $version = 'UNSET',
  $service_name = 'rabbitmq-server',
  $service_ensure = 'running',
  $node_ip_address = 'UNSET',
  $basedir = '/var/lib/rabbitmq',
  $config='UNSET',
  $env_config='UNSET',
  $connection_loglevel = 'error'
) {

  validate_bool($delete_guest_user)
  validate_re($port, '\d+')

  if $version == 'UNSET' {
    $version_real = '2.4.1'
    $pkg_ensure_real   = 'present'
  } else {
    $version_real = $version
    $pkg_ensure_real   = $version
  }

  file { '/etc/rabbitmq':
    ensure  => directory,
    owner   => '0',
    group   => '0',
    mode    => '0644',
    require => Package[$package_name],
  }

  if $config == 'UNSET' {

    # Build rabbitmq.config using concat/fragments and templates
    concat { 'rabbitmq_config_file':
      path    => '/etc/rabbitmq/rabbitmq.config',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$package_name],
      notify  => Class['rabbitmq::service']
    }

    concat::fragment { 'rabbitmq_config_header':
      target  => 'rabbitmq_config_file',
      order   => 0,
      content => template("${module_name}/rabbitmq_config_header.erb"),
    }

    # Listen port is defined in the trailer template
    concat::fragment { 'rabbitmq_config_trailer':
      target  => 'rabbitmq_config_file',
      order   => 99,
      content => template("${module_name}/rabbitmq_config_trailer.erb")
    }
  } else {
    # Entire content of rabbitmq.config is provided by the user:
    file { 'rabbitmq.config':
      ensure  => file,
      path    => '/etc/rabbitmq/rabbitmq.config',
      content => $config,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$package_name],
      notify  => Class['rabbitmq::service'],
    }
  }

  file { $basedir:
    ensure  => directory,
    owner   => 'rabbitmq',
    group   => 'rabbitmq',
    require => Package[$package_name]
  }

  file { "${basedir}/mnesia":
    ensure  => directory,
    owner   => 'rabbitmq',
    group   => 'rabbitmq',
    require => Package[$package_name]
  }

  if $env_config == 'UNSET' {
    $env_config_real = template("${module_name}/rabbitmq-env.conf.erb")
  } else {
    $env_config_real = $env_config
  }

  $plugin_dir = "/usr/lib/rabbitmq/lib/rabbitmq_server-${version_real}/plugins"

  package { $package_name:
    ensure => $pkg_ensure_real,
    notify => Class['rabbitmq::service'],
  }

  file { 'rabbitmq-env.config':
    ensure  => file,
    path    => '/etc/rabbitmq/rabbitmq-env.conf',
    content => $env_config_real,
    owner   => '0',
    group   => '0',
    mode    => '0644',
    require => File["${basedir}/mnesia"],
    notify  => Class['rabbitmq::service'],
  }

  class { 'rabbitmq::service':
    ensure       => $service_ensure,
    service_name => $service_name,
  }

  if $delete_guest_user {
    # delete the default guest user
    rabbitmq_user{ 'guest':
      ensure   => absent,
      provider => 'rabbitmqctl',
    }
  }
}
