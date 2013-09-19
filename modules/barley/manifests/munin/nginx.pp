class barley::munin::nginx ($vhost = 'localhost') {
  # Mod status
  nginx::resource::location { "${vhost}.status":
    ensure              => 'present',
    location            => '/status/',
    stub_status         => true,
    location_cfg_append => {
      'access_log' => 'off',
      'allow'      => '127.0.0.1'
    }
    ,
    vhost               => $vhost,
  }

  # Install required perl package for nginx munin plugin
  package { 'liblwp-useragent-determined-perl': ensure => 'latest', }

  # Configure munin plugin
  munin::plugin { ['nginx_request', 'nginx_status',]:
    config  => 'env.url http://localhost/status/',
    require => [Class['munin::client'],],
  }

}