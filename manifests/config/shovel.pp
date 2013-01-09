# Shovel configuration entry in rabbitmq.config
#
# Tricky implementation because a comma is required between the list elements
# (in this case shovel definitions) in Erlang config files.
# To keep things in correct order,
# * the header gets order = 28
# * the first shovel definition gets order = 29
# * if there is more than 1 shovel definition, we use a fragment beginning with a comma and followed by the shovel definition.
#     This fragment gets order = 30. So all subsequent shovel definitions get order = 30. This is ok, because the order of these
#     fragments doesn't matter.
# * The trailer gets order = 31
define rabbitmq::config::shovel (
  $shovel_source_broker,
  $shovel_source_exchange,
  $shovel_source_queue,
  $shovel_destination_exchange) {

    if !defined (Concat::Fragment['fragment_config_shovel_header']) {
      concat::fragment { 'fragment_config_shovel_header':
        target  => 'rabbitmq_config_file',
        order   => 28,
        content => template("${module_name}/rabbitmq_config_shovel_header.erb"),
      }
      concat::fragment { "fragment_config_shovel_${name}":
        target  => 'rabbitmq_config_file',
        order   => 29,
        content => template("${module_name}/rabbitmq_config_shovel.erb"),
      }
    } else {
      # Comma required between shovel definitions... :p
      concat::fragment { "fragment_config_shovel_separator_${name}":
        target  => 'rabbitmq_config_file',
        order   => 30,
        content => template("${module_name}/rabbitmq_config_shovel_separator.erb", "${module_name}/rabbitmq_config_shovel.erb"),
      }
    }

    if !defined (Concat::Fragment['fragment_config_shovel_trailer']) {
      concat::fragment { 'fragment_config_shovel_trailer':
        target  => 'rabbitmq_config_file',
        order   => 31,
        content => template("${module_name}/rabbitmq_config_shovel_trailer.erb"),
      }
    }
}
