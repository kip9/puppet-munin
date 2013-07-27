# Install nginx
include nginx

# Configure default php-ini
php::ini { '/etc/php.ini':
  display_errors => 'On',
  memory_limit   => '128M',
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

user { 'kip9':
  ensure => present,
}

user { 'test':
  ensure => present,
}
