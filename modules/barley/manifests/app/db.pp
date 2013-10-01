class barley::app::db {
  Class['barley::app'] -> Class['barley::app::db']

  # include params
  include barley::params

  # include nginx
  include ::nginx

  # App DB config
  file { '/var/www/barley.plain/application/config/development/database.php':
    ensure  => 'present',
    owner   => "${nginx::params::nx_daemon_user}",
    mode    => 0600,
    source  => "puppet:///modules/barley/application/config/development/database.php",
    notify  => Exec['barley_db_migrate'],
    require => [Database['barley'],],
  }

  exec { 'barley_db_migrate':
    cwd         => "${barley::params::app_dir}",
    command     => 'php index.php migrations up',
    environment => ['BARLEY_ENVIRONMENT=development',],
    path        => ['/usr/bin', '/bin',],
  }
}