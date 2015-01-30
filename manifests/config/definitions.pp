# Minimal rabbitMQ broker config: defines an exchange and a queue at startup of rabbitmq-server,
# and binds the exchange to the queue.
#
# A json file with the definitions is created. In rabbitmq.config we create an entry
# {load_definitions, "/path/to/our/json/file"}
# so that the definitions get loaded when the rabbitMQ service starts.
#
# Parameters:
#  [rabbitmq_exchange] - name of the rabbitMQ exchange
#  [rabbitmq_queue]    - name of hte rabbitMQ queue
class rabbitmq::config::definitions($rabbitmq_exchange = 'default_exchange', $rabbitmq_queue = 'default_exchange', $rabbitmq_remote_user = 'remote', $rabbitmq_remote_passwordhash = 'R5KfDHPjb45PISMNQZptoHaDYfA=') {

  $rabbitmq_definitions_json = '/etc/rabbitmq/rabbitmq_definitions.json'

  # json file with definition of queue and exchange:
  file {'rabbitmq_definitions':
    ensure  => file,
    path    => $rabbitmq_definitions_json,
    content => template("${module_name}/rabbitmq_config_definitions.json.erb"),
    notify  => Class['rabbitmq::service'],
    require => Package['rabbitmq-server'],
  }

  # entry in rabbitmq.config:
  concat::fragment { 'fragment_config_load_definitions':
    target    => 'rabbitmq_config_file',
    order     => 20,
    content   => template("${module_name}/rabbitmq_config_load_definitions.erb"),
    subscribe => File['rabbitmq_definitions'],
  }
}
