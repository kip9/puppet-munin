class barley::base {
  # Run apt-get update before package install
  exec { "apt-update": command => "/usr/bin/apt-get update" }
  Exec["apt-update"] -> Package <| |>

}