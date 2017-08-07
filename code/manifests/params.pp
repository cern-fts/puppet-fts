#Class: fts::params
class fts::params {
  $port              = 8443
  $restport          = 8446
  $logport           = 8449
  $version           = hiera('fts3_version','present')
  $rest_version      = hiera('fts3_rest_version','present')
  $monitoring_version    = hiera('fts3_monitoring_version','present')
  $rest_debug        = hiera('fts3_rest_debug','false')
  $db_connect_string = hiera('fts3_db_connect_string',undef)
  $db_type           = hiera('fts3_db_type','mysql')
  $db_username       = hiera('fts3_db_username','ora_user')
  $db_password       = hiera('fts3_db_password','ora_pass')
  $msg_username      = hiera('fts3_msg_username','msg_username')
  $msg_password      = hiera('fts3_msg_password','msg_pass')
  $msg_broker        = hiera('fts3_msg_broker','dashb-mb.cern.ch:61113')
  $bdii_infosys      = hiera('fts3_bdii_infosys','lcg-bdii.cern.ch:2170')
  $host_alias        = hiera('fts3_host_alias',$::fqdn)
  $site_name         = hiera('fts3_site_name','SITE_NAME')
  $open_files        = hiera('fts3_open_files','16384')
  $authorizedVOs     = hiera('fts3_authorizedVOs','*')
  $monitoring_messages = hiera('fts3_monitoring_messages',true)

  $optimizer_max_success = hiera('fts3_optimizer_max_success_rate', 100)
  $optimizer_med_success = hiera('fts3_optimizer_med_success_rate', 98)
  $optimizer_low_success = hiera('fts3_optimizer_low_success_rate', 97)
  $optimizer_base_success = hiera('fts3_optimizer_base_success_rate', 96)

  $fts3_repo         = hiera('fts3_fts_repo',"http://grid-deployment.web.cern.ch/grid-deployment/dms/fts3/repos/el${::operatingsystemmajrelease}/x86_64")
  $repo_includepkgs  = hiera('fts3_repo_includepkgs',['fts-*','gfal2-*','python-fts','srm-ifce','davix-*,CGSI-gSOAP'])

  # Specify ORACLE client packages if you need to, only relavent if db_type is oracle.
  $orapkgs           = hiera('fts3_orapkgs',['oracle-instantclient-basic','oracle-instantclient-sqlplus','rlwrap'])

}
