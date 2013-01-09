# Stomp configuration entry in rabbitmq.config
#
# Parameters:
#  [*stomp_port*] - port stomp should be listening on. Default is 6163
#
# (!) order attribute is important : please don't change it.
class rabbitmq::config::stomp ($stomp_port = '6163') {

  validate_re($stomp_port, '\d+')

  concat::fragment { 'fragment_config_stomp':
    target  => 'rabbitmq_config_file',
    order   => 20,
    content => template("${module_name}/rabbitmq_config_stomp.erb"),
  }
}