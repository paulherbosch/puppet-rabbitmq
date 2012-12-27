class rabbitmq::repo::rhel (
    $key = 'http://www.rabbitmq.com/rabbitmq-signing-key-public.ascr',
    $version = '2.8.4',
    $relversion = '1',
) {
    exec { "rpm --import ${key}":
        path => ['/bin','/usr/bin','/sbin','/usr/sbin'],
    }

    package { 'rabbitmq-server':
        ensure   => installed,
        provider => rpm,
        source   => "http://www.rabbitmq.com/releases/rabbitmq-server/v${version}/rabbitmq-server-${version}-${relversion}.noarch.rpm",
        require  => Exec["rpm --import ${key}"],
    }

}

