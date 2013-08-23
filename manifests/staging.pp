###
# Example staging node
###

# Install nginx
include barley::nginx


# Configure default php-ini
php::ini { '/etc/php.ini':
  display_errors => 'On',
  memory_limit   => '128M',
  date_timezone  => 'America/New_York',
}

# Install PHP CLI
include php::cli

# Install mcrypt and mysql modules for php
php::module { [ 'mcrypt', 'mysql' ]: }

# Install FPM
include php::fpm::daemon
php::fpm::conf { 'www':
  listen  => '127.0.0.1:9001',
  user    => 'nginx',
  # For the user to exist
  require => Package['nginx'],
}

# Install mysql

class { 'mysql::server':
  config_hash => {
    'root_password' => 'plainmade',
    'default_engine' => 'InnoDB',
  },
}

# Setup barley database
mysql::db { 'barley':
  user  =>  'barley',
  password  => 'plainmade',
}

# Setup hosts file
host {'barley.plain':
  ensure  =>  present,
  ip      =>  '127.0.0.1',
  name    =>  'barley.plain',
}

host {'demo.barley.plain':
  ensure  =>  present,
  ip      =>  '127.0.0.1',
  name    =>  'demo.barley.plain',
}

host {'admin.barley.plain':
  ensure  =>  present,
  ip      =>  '127.0.0.1',
  name    =>  'admin.barley.plain',
}
