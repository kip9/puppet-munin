###
# Example staging node
###

# Base barley setup
include barley::base

# Configure default php-ini
php::ini { '/etc/php.ini':
  display_errors => 'On',
  memory_limit   => '128M',
  date_timezone  => 'America/New_York',
}

# Install mcrypt and mysql modules for php
php::module { ['mcrypt', 'mysql']: }

# Install FPM
include php::fpm::daemon

php::fpm::conf { 'www':
  listen  => '127.0.0.1:9000',
  user    => 'www-data',
  # For the user to exist
  require => Package['nginx'],
}

# Install mysql

class { 'mysql::server':
  config_hash => {
    'root_password'  => 'plainmade',
    'default_engine' => 'InnoDB',
    'bind_address'   => '0.0.0.0',
  }
  ,
}

$db_name = 'barley'
$db_user = 'barley'
$db_password = 'plainmade'

# Setup barley database
mysql::db { "${db_name}":
  user     => "${db_user}",
  password => "${db_password}",
}

# External access to DB
database_user { "${db_user}@%": password_hash => mysql_password("${db_password}") }

database_grant { "${db_user}@%": privileges => ['all'], }

database_grant { "${db_user}@%/${db_name}": privileges => ['all'], }

# Setup hosts file
host { 'barley-vagrant-base.vagrant.plainmade':
  ensure       => present,
  ip           => '127.0.0.1',
  name         => 'barley-vagrant-base.vagrant.plainmade',
  host_aliases => ['barley-vagrant-base',],
}

host { 'barley-vagrant-base':
  ensure => absent,
  name   => 'barley-vagrant-base',
}

host { 'barley.plain':
  ensure => present,
  ip     => '127.0.0.1',
  name   => 'barley.plain',
}

host { 'demo.barley.plain':
  ensure => present,
  ip     => '127.0.0.1',
  name   => 'demo.barley.plain',
}

host { 'admin.barley.plain':
  ensure => present,
  ip     => '127.0.0.1',
  name   => 'admin.barley.plain',
}

# Install nginx
include barley::app

# Install various tools
class { 'barley::utils':
}

# Instal munin client
class { 'munin::client':
  allow => '127.0.0.1'
}

# Install munin for nginx
class { 'barley::munin::nginx':
}

# Dependencies between munin and plugin
Class['munin::client'] -> Class['barley::munin::nginx']
