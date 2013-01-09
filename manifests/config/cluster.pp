# Clustering configuration entry in rabbitmq.config
#
# Parameters:
#    [*cluster_disk_nodes*]       - which nodes to cluster with (including the current one)
#    [*erlang_cookie*]            - erlang cookie, must be the same for all nodes in a cluster
#    [*wipe_db_on_cookie_change*] - whether to wipe the RabbitMQ data if the specified
#     erlang_cookie differs from the current one. This is a sad parameter: actually,
#     if the cookie indeed differs, then wiping the database is the *only* thing you
#     can do. You're only required to set this parameter to true as a sign that you
#     realise this.
#
# (!) order attribute is important : please don't change it.
class rabbitmq::config::cluster (
  $cluster_disk_nodes = [],
  $erlang_cookie = 'EOKOWXQREETZSHFNTPEY',
  $wipe_db_on_cookie_change = false) {

  concat::fragment { 'fragment_config_cluster':
    target  => 'rabbitmq_config_file',
    order   => 10,
    content => template("${module_name}/rabbitmq_config_cluster.erb"),
  }

  file { 'erlang_cookie':
    path    =>'/var/lib/rabbitmq/.erlang.cookie',
    owner   => rabbitmq,
    group   => rabbitmq,
    mode    => '0400',
    content => $erlang_cookie,
    replace => true,
    before  => Concat['rabbitmq_config_file'],
    require => Exec['wipe_db'],
  }

  # Require authorize_cookie_change
  if $wipe_db_on_cookie_change {
    exec { 'wipe_db':
      command => '/etc/init.d/rabbitmq-server stop; /bin/rm -rf /var/lib/rabbitmq/mnesia',
      require => Package[$rabbitmq::server::package_name],
      unless  => "/bin/grep -qx ${erlang_cookie} /var/lib/rabbitmq/.erlang.cookie"
    }
  } else {
    exec { 'wipe_db':
      command => '/bin/false "Cookie must be changed but wipe_db is false"', # If the cookie doesn't match, just fail.
      require => Package[$rabbitmq::server::package_name],
      unless  => "/bin/grep -qx ${erlang_cookie} /var/lib/rabbitmq/.erlang.cookie"
    }
  }
}
