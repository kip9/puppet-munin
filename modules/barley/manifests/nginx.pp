# # Barley extensions to regular nginx config
# Contains barley specific configuration files
class barley::nginx inherits ::nginx {
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
  }

  file { "${nginx::params::nx_conf_dir}/barley/barley-headers.conf":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => 0744,
    content => template("barley/nginx/config/barley-header.conf.erb"),
  }

  file { "${nginx::params::nx_conf_dir}/barley/barley-locations.conf":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => 0744,
    content => template("barley/nginx/config/barley-locations.conf.erb"),
  }

}