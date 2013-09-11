class fts::config (
   $port              = $fts::params::port,
   $restport          = $fts::params::restport,
   $logport           = $fts::params::logport,
   $db_connect_string = $fts::params::db_connect_string,
   $db_type           = $fts::params::db_type,
   $db_username       = $fts::params::db_username,
   $msg_password      = $fts::params::msg_password,
   $msg_username      = $fts::params::msg_username,
   $bdii_infosys      = $fts::params::bdii_infosys,
   $host_alias        = $fts::params::host_alias,
   $site_name         = $fts::params::site_name
) inherits fts::params  {
   firewall{"100 Allow ${port} access to fts":
      proto => 'tcp',
      state => 'NEW',
      dport => $port,
      action => 'accept'
   }
   firewall{"100 Allow ${restport} access to fts rest interface":
      proto => 'tcp',
      state => 'NEW',
      dport => $restport,
      action => 'accept'
   }
   firewall{"100 Allow ${logport} access to fts log viewer":
      proto => 'tcp',
      state => 'NEW',
      dport => $logport,
      action => 'accept'
   }   
   firewall{"100 Allow 2170 access to bdii":
      proto => 'tcp',
      state => 'NEW',
      dport => 2170,
      action => 'accept'
   }   

  Fts3config {
    notify => [Service['fts-server'],
               Service['fts-records-cleaner'],
               Service['fts-bdii-cache-updater'],
               Service['fts-bringonline']],

  }

  fts3config{'/Port':                value => $port}
  fts3config{'/SiteName':                value => $site_name}
  fts3config{'/DbConnectString':     value => $db_connect_string}
  fts3config{'/DbType':              value => $db_type}
  fts3config{'/DbUserName':          value => $db_username}
  fts3config{'/DbPassword':          value => $db_password}
  fts3config{'/DbThreadsNum':        value => '30'}
  fts3config{'/Infosys':             value => $bdii_infosys}
  fts3config{'/Alias':               value => $host_alias}
  fts3config{'/MonitoringMessaging': value => 'true'}
  fts3config{'roles/Public':         value => 'vo:transfer'}
  fts3config{'roles/production':     value => 'all:config'}

  # Maybe not needed with newer fts.
  # 
  file{'/etc/fts3/fts3config':
    ensure  => file,
    replace => false,
    backup  => false,
    mode    => '0644',
    owner   => 'fts3',
    group   => 'fts3'
  }

  augeas{'/etc/fts3/fts-msg-monitoring.conf':
      incl    => "/etc/fts3/fts-msg-monitoring.conf",
      lens    => "shellvars.lns",
      context => "/files/etc/fts3/fts-msg-monitoring.conf",
      changes => ["set FQDN ${::fqdn}",
                  "set PASSWORD ${msg_password}",
                  "set USERNAME ${msg_username}"
                 ],
      notify => [Service['fts-msg-bulk'],Service['fts-msg-cron']],
  }


  package{'policycoreutils-python':
    ensure => present
  }
  exec{"http_port_resetport":
     command => "/usr/sbin/semanage port -a -t http_port_t -p tcp ${restport}",
     unless  => "/usr/sbin/semanage port  -l | /bin/grep '^http_port_t ' | /bin/grep -q ${restport}",
     require => Package['policycoreutils-python'],
     before  => Service['httpd']
  }
  exec{"http_port_logport":
     command => "/usr/sbin/semanage port -a -t http_port_t -p tcp ${logport}",
     unless  => "/usr/sbin/semanage port  -l | /bin/grep '^http_port_t ' | /bin/grep -q ${logport}",
     require => Package['policycoreutils-python'],
     before  => Service['httpd']
  }
    # Make sure debug is disabled for the rest interface
  file_line{'fts3_rest_disable_debug':
    path => '/etc/fts3/fts3rest.ini',
    match => '^debug\s*=.*',
    line => 'debug = false',
    before => Service['httpd'],
    notify => Service['httpd']
  }
}

