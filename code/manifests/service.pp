#Class: fts::service
class fts::service (
  $enable_bringonline = $fts::params::enable_bringonline,
  $enable_msg         = $fts::params::enable_msg,
) inherits fts::params  {

  include ('fetchcrl')

  service{'fts-server':
    ensure    => running,
    enable    => true,
    subscribe => Package['fts-server']
  }

  service{'fts-records-cleaner':
    ensure => running,
    enable => true,
  }
  service{'fts-bdii-cache-updater':
    ensure => running,
    enable => true,
  }
  service{'httpd':
    ensure    => running,
    enable    => true,
    subscribe => [Package['fts-rest'], Class['fetchcrl']]
  }

  service{['bdii','fts-info-publisher']:
    ensure => running,
    enable => true,
  }

  if $enable_msg {
    service{'fts-msg-bulk':
      ensure    => running,
      enable    => true,
      subscribe => Package['fts-server']
    }
  }
  
  if $enable_brigonline {
    service{'fts-bringonline':
      ensure    => running,
      enable    => true,
      subscribe => Package['fts-server']
    }
  }

}

