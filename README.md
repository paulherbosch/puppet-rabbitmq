# RabbitMQ Puppet Module
This module manages the RabbitMQ Middleware service.
Based on the puppetlabs / puppetlabs-rabbitmq module by Jeff McCune, Dan Bode and Vincent Janelle.

### rabbitmq::server
Class for installing rabbitmq-server:

    class { 'rabbitmq::server':
      port              => '5673',
      delete_guest_user => true,
    }

Settings in rabbitmq-env.config can be specified with the parameter `env_config`, e.g.

    class { 'rabbitmq::server':
      env_config        => 'MNESIA_BASE=/data/rabbitmq/mnesia',
      delete_guest_user => false,
    }

Enable the rabbitmq management console (browser, default port is 55672)

    rabbitmq_plugin { 'rabbitmq_management':
      ensure   => present,
      provider => 'rabbitmqplugins',
    }

    # Notify rabbitmq service to activate the plugin:
    Rabbitmq_plugin['rabbitmq_management'] ~> Class['rabbitmq::service']
    

### Clustering
To use RabbitMQ clustering and H/A facilities, use rabbitmq::config::cluster
with parameters `cluster_disk_nodes` and optional `erlang_cookie`, e.g.:

    class { 'rabbitmq::config::cluster':
      cluster_disk_nodes => ['rabbit1', 'rabbit2'],
    }

Currently all cluster nodes are registered as disk nodes (not ram).

**NOTE:** You still need to use `x-ha-policy: all` in your client 
applications for any particular queue to take advantage of H/A, this module 
merely clusters RabbitMQ instances.

### Stomp configuration
To configure stomp, enable the plugin and use rabbitmq::config::stomp if you want to change the default port (6163).

    rabbitmq_plugin {'rabbitmq_stomp':
      ensure => present,
      provider => 'rabbitmqplugins',
    }

    class { 'rabbitmq::config::stomp':
      stomp_port => '6162',
    }

    # Notify rabbitmq service to activate the plugin:
    Rabbitmq_plugin['rabbitmq_stomp'] ~> Class['rabbitmq::service']

### Shovel plugin configuration

Enable and configure the RabbitMQ shovel plugin

    rabbitmq_plugin {'rabbitmq_shovel':
      ensure   => present,
      provider => 'rabbitmqplugins',
    }

    rabbitmq::config::shovel { 'myshovel':
      shovel_source_broker        => 'source.example.com',
      shovel_source_exchange      => 'source_exchange',
      shovel_source_queue         => 'source_queue',
      shovel_destination_exchange => 'destination_exchange',
    }

    # Notify rabbitmq service to activate the plugin:
    Rabbitmq_plugin['rabbitmq_shovel'] ~> Class['rabbitmq::service']

## Native Types

**NOTE:** Unfortunately, you must specify the provider explicitly for these types

### rabbitmq_user

query all current users: `$ puppet resource rabbitmq_user`

    rabbitmq_user { 'dan':
      admin    => true,
      password => 'bar',
      provider => 'rabbitmqctl',
    }

### rabbitmq_vhost

query all current vhosts: `$ puppet resource rabbitmq_vhost`

    rabbitmq_vhost { 'myhost':
      ensure => present,
      provider => 'rabbitmqctl',
    }

### rabbitmq\_user\_permissions

    rabbitmq_user_permissions { 'dan@myhost':
      configure_permission => '.*',
      read_permission      => '.*',
      write_permission     => '.*',
      provider => 'rabbitmqctl',
    }

### rabbitmq_plugin

query all currently enabled plugins `$ puppet resource rabbitmq_plugin`

    rabbitmq_plugin {'rabbitmq_stomp':
      ensure => present,
      provider => 'rabbitmqplugins',
    }
