# Class: fts::config
class fts::config (
  $port              = $fts::params::port,
  $restport          = $fts::params::restport,
  $logport           = $fts::params::logport,
  $db_connect_string = $fts::params::db_connect_string,
  $db_type           = $fts::params::db_type,
  $db_username       = $fts::params::db_username,
  $db_password       = $fts::params::db_password,
  $msg_password      = $fts::params::msg_password,
  $msg_username      = $fts::params::msg_username,
  $msg_broker        = $fts::params::msg_broker,
  $bdii_infosys      = $fts::params::bdii_infosys,
  $host_alias        = $fts::params::host_alias,
  $site_name         = $fts::params::site_name,
  $rest_debug        = $fts::params::rest_debug,
  $open_files        = $fts::params::open_files,
  $authorizedVOs     = $fts::params::authorizedVOs,
  $monitoring_messages = $fts::params::monitoring_messages,
  $enable_bringonline = $fts::params::enable_bringonline,
  $enable_msg        = $fts::params::enable_msg,
) inherits fts::params  {

  firewall{"100 Allow ipv4  access to fts":
    proto  => 'tcp',
    state  => 'NEW',
    dport  => [$port,$restport,$logport,'2170'],
    action => 'accept'
  }
  firewall{"100 Allow ipv6  access to fts":
    provider => 'ip6tables',
    proto  => 'tcp',
    state  => 'NEW',
    dport  => [$port,$restport,$logport,'2170'],
    action => 'accept'
  }

  $services = [ 'fts-server', 'fts-records-cleaner', 'fts-bdii-cache-updater', 'httpd' ]
  
  Fts3config {
    notify => Service[$services],
  }

  if $enable_bringonline {
    Fts3config {
      notify => Service['fts-bringonline'],
   }
  }

  if $enable_msg {
    Fts3config {
      notify => Service['fts-msg-bulk'],
   }
  }

  fts3config{'/Port':                value => $port}
  fts3config{'/SiteName':                value => $site_name}
  fts3config{'/DbConnectString':     value => $db_connect_string}
  fts3config{'/DbType':              value => $db_type}
  fts3config{'/DbUserName':          value => $db_username}
  fts3config{'/DbThreadsNum':        value => '30'}
  fts3config{'/Infosys':             value => $bdii_infosys}
  fts3config{'/Alias':               value => $host_alias}
  fts3config{'/MonitoringMessaging': value => $monitoring_messages}
  fts3config{'/AuthorizedVO':        value => $authorizedVOs}
  fts3config{'roles/Public':         value => 'vo:transfer'}
  fts3config{'roles/production':     value => 'all:config'}
  fts3config{'roles/lcgadmin':     value => 'vo:transfer'}

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
  file{'/etc/fts3/fts-msg-monitoring.conf':
    ensure  => file,
    replace => false,
    mode    => '0644',
    owner   => 'fts3',
    group   => 'fts3'
  }

  augeas{'edit_/etc/fts3/fts-msg-monitoring.conf':
    incl    => '/etc/fts3/fts-msg-monitoring.conf',
    lens    => 'shellvars.lns',
    context => '/files/etc/fts3/fts-msg-monitoring.conf',
    changes => ["set FQDN ${::fqdn}",
                "set PASSWORD ${msg_password}",
                "set USERNAME ${msg_username}",
                "set BROKER ${msg_broker}"
    ],
    notify  => Service['fts-msg-bulk'],
  }

  fts3restconfig{'DEFAULT/debug':
    value  => $rest_debug,
    before => Service['httpd'],
    notify => Service['httpd']
  }

  # Apache Keep Alive on
  apache_directive{'KeepAlive':
    ensure => present,
    args   => 'On',
    notify => Service['httpd']
  }


  # Increase the limits.conf
  Limits::Entry {
    item   => 'nofile',
    value  =>  $open_files,
    notify =>  Service['fts-server']
  }
  limits::entry{'root-soft': type => 'soft', domain => 'root'}
  limits::entry{'fts3-soft': type => 'soft', domain => 'fts3'}
  limits::entry{'root-hard': type => 'hard', domain => 'root'}
  limits::entry{'fts3-hard': type => 'hard', domain => 'fts3'}

  # Web services are quite chatty and compress well.
  augeas{'httpd_logrorate':
    incl    => '/etc/logrotate.d/httpd',
    lens    => 'Logrotate.lns',
    context => '/files/etc/logrotate.d/httpd/rule',
    changes => ['set compress compress',
                'rm delaycompress'
    ]
  }
}

