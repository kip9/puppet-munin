# # Barley extensions to regular nginx config
# Contains barley specific configuration files
class barley::app {
  Class['mysql::server'] -> Class['barley::app']

  # Require PHP CLI
  require php::cli

  # include params
  include barley::params

  # include nginx
  include ::nginx

  # Nginx user
  user { "${nginx::params::nx_daemon_user}": ensure => 'present', }

  # Nginx root folder
  file { '/var/www':
    ensure  => 'directory',
    owner   => "${nginx::params::nx_daemon_user}",
    mode    => '0744',
    require => User["${nginx::params::nx_daemon_user}"],
  }

  # SSH keys folder
  file { '/var/www/.ssh/':
    ensure  => 'directory',
    owner   => "${nginx::params::nx_daemon_user}",
    mode    => '0700',
    require => [User["${nginx::params::nx_daemon_user}"], File['/var/www/']],
  }

  # SSH public key for template access on github
  file { '/var/www/.ssh/id_rsa.pub':
    ensure  => 'present',
    owner   => "${nginx::params::nx_daemon_user}",
    mode    => '0644',
    source  => "puppet:///modules/barley/other/ssh/id_rsa.pub",
    require => [User["${nginx::params::nx_daemon_user}"], File['/var/www/.ssh/']],
  }

  # SSH private key for template access on github
  file { '/var/www/.ssh/id_rsa':
    ensure  => 'present',
    owner   => "${nginx::params::nx_daemon_user}",
    mode    => '0600',
    source  => "puppet:///modules/barley/other/ssh/id_rsa",
    require => [User["${nginx::params::nx_daemon_user}"], File['/var/www/.ssh/']],
  }

  # SSH known hosts entry for github
  file { '/var/www/.ssh/known_hosts':
    ensure  => 'present',
    owner   => "${nginx::params::nx_daemon_user}",
    mode    => '0644',
    source  => "puppet:///modules/barley/other/ssh/known_hosts",
    require => [User["${nginx::params::nx_daemon_user}"], File['/var/www/.ssh/']],
  }

  # Barley config files
  file { "${nginx::params::nx_conf_dir}/barley":
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => 0744,
  }

  file { "${nginx::params::nx_conf_dir}/barley/barley-errors.conf":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => 0744,
    content => template("barley/nginx/config/barley-errors.conf.erb"),
    notify  => Service['nginx'],
  }

  file { "${nginx::params::nx_conf_dir}/barley/barley-headers.conf":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => 0744,
    content => template("barley/nginx/config/barley-header.conf.erb"),
    notify  => Service['nginx'],
  }

  file { "${nginx::params::nx_conf_dir}/barley/barley-locations.conf":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => 0744,
    content => template("barley/nginx/config/barley-locations.conf.erb"),
    notify  => Service['nginx'],
  }

  file { "${nginx::params::nx_conf_dir}/conf.d/mappings.conf":
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => 0744,
    source => "puppet:///modules/barley/nginx/config/mappings.conf",
    notify => Service['nginx'],
  }

  file { "${nginx::params::nx_conf_dir}/conf.d/0-log_format.conf":
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => 0744,
    source => "puppet:///modules/barley/nginx/config/log_format.conf",
    notify => Service['nginx'],
  }

  # # Logs
  file { "${nginx::params::nx_conf_dir}/logs/":
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => 0744,
  }

  file { "${nginx::params::nx_conf_dir}/logs/barley.plain/":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => 0744,
    require => File["${nginx::params::nx_conf_dir}/logs/"],
  }

  # App DB config
  file { '/var/www/barley.plain/application/config/development/database.php':
    ensure  => 'present',
    owner   => "${nginx::params::nx_daemon_user}",
    mode    => 0600,
    source  => "puppet:///modules/barley/application/config/development/database.php",
    notify  => Exec['barley_db_migrate'],
    require => Database['barley'],
  }

  exec { 'barley_db_migrate':
    cwd         => "${barley::params::app_dir}",
    command     => 'php index.php migrations up',
    environment => ['BARLEY_ENVIRONMENT=development',],
    path        => ['/usr/bin', '/bin',],
  }

  # App Virtual Host
  nginx::resource::vhost { 'barley.plain':
    ensure       => present,
    www_root     => "${barley::params::app_dir}",
    includes     => [
      "${nginx::params::nx_conf_dir}/barley/barley-errors.conf",
      "${nginx::params::nx_conf_dir}/barley/barley-headers.conf",
      "${nginx::params::nx_conf_dir}/barley/barley-locations.conf",
      ],
    add_location => false,
  }

  # Localhost maintenance/monitoring virtual Host
  nginx::resource::vhost { 'localhost':
    ensure       => present,
    www_root     => '/var/www',
    add_location => false,
  }

  # Mod status
  nginx::resource::location { 'localhost.status':
    ensure              => 'present',
    location            => '/status/',
    stub_status         => true,
    location_cfg_append => {
      'access_log' => 'off',
      'allow'      => '127.0.0.1'
    },
    vhost         => 'localhost',
  }

}