## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# PRIMARY FILEBUCKET
# This configures puppet agent and puppet inspect to back up file contents when
# they run. The Puppet Enterprise console needs this to display file contents
# and differences.

# Define filebucket 'main':
filebucket { 'main':
  server => 'master.inf.puppetlabs.demo',
  path   => false,
}

# Make filebucket 'main' the default backup location for all File resources:
File { backup => 'main' }

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node default {
  notify { "hello $::fqdn": }
#  notice(hiera("password"))
$all_groups = ['oinstall','dba' ,'oper']
 group { $all_groups :
  ensure      => present,
}
 user { 'oracle' :
  ensure      => present,
  gid         => 'oinstall',
  groups      => ['oinstall','dba','oper'],
  shell       => '/bin/bash',
  password    => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
  home        => "/home/oracle",
  comment     => "This user oracle was created by Puppet",
  require     => Group[$all_groups],
  managehome  => true,
}
 sysctl { 'kernel.msgmnb':                 ensure => 'present', permanent => 'yes', value => '65536',}
sysctl { 'kernel.msgmax':                 ensure => 'present', permanent => 'yes', value => '65536',}
sysctl { 'kernel.shmmax':                 ensure => 'present', permanent => 'yes', value => '2588483584',}
sysctl { 'kernel.shmall':                 ensure => 'present', permanent => 'yes', value => '2097152',}
sysctl { 'fs.file-max':                   ensure => 'present', permanent => 'yes', value => '6815744',}
sysctl { 'net.ipv4.tcp_keepalive_time':   ensure => 'present', permanent => 'yes', value => '1800',}
sysctl { 'net.ipv4.tcp_keepalive_intvl':  ensure => 'present', permanent => 'yes', value => '30',}
sysctl { 'net.ipv4.tcp_keepalive_probes': ensure => 'present', permanent => 'yes', value => '5',}
sysctl { 'net.ipv4.tcp_fin_timeout':      ensure => 'present', permanent => 'yes', value => '30',}
sysctl { 'kernel.shmmni':                 ensure => 'present', permanent => 'yes', value => '4096', }
sysctl { 'fs.aio-max-nr':                 ensure => 'present', permanent => 'yes', value => '1048576',}
sysctl { 'kernel.sem':                    ensure => 'present', permanent => 'yes', value => '250 32000 100 128',}
sysctl { 'net.ipv4.ip_local_port_range':  ensure => 'present', permanent => 'yes', value => '9000 65500',}
sysctl { 'net.core.rmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
sysctl { 'net.core.rmem_max':             ensure => 'present', permanent => 'yes', value => '4194304', }
sysctl { 'net.core.wmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
sysctl { 'net.core.wmem_max':             ensure => 'present', permanent => 'yes', value => '1048576',}
 class { 'limits':
  config => {
             '*'       => { 'nofile'  => { soft => '2048'   , hard => '8192',   },},
             'oracle'  => { 'nofile'  => { soft => '65536'  , hard => '65536',  },
                             'nproc'  => { soft => '2048'   , hard => '16384',  },
                             'stack'  => { soft => '10240'  ,},},
             },
  use_hiera => false,
}
 $install = [ 'binutils.x86_64', 'compat-libstdc++-33.x86_64', 'glibc.x86_64',
	'ksh.x86_64','libaio.x86_64', 'libgcc.x86_64', 'libstdc++.x86_64', 
	'make.x86_64','compat-libcap1.x86_64', 'gcc.x86_64', 'gcc-c++.x86_64',
	'glibc-devel.x86_64','libaio-devel.x86_64','libstdc++-devel.x86_64',
	 'sysstat.x86_64','unixODBC-devel','glibc.i686','libXext.x86_64','libXtst.x86_64']
 package { $install:
  ensure  => present,
}

$puppetDownloadMntPoint = "/vagrant"
oradb::installdb{ '12.1.0.2_Linux-x86-64':
  version                => '12.1.0.2',
  file                   => 'linuxamd64_12102_database',
  databaseType           => 'SE',
  oracleBase             => '/oracle',
  oracleHome             => '/oracle/product/12.1/db',
  bashProfile            => true,
  user                   => 'oracle',
  group                  => 'dba',
  group_install          => 'oinstall',
  group_oper             => 'oper',
  downloadDir            => '/data/install',
  zipExtract             => true,
  puppetDownloadMntPoint => $puppetDownloadMntPoint,
}

# oradb::installdb{ '112040_Linux-x86-64':
#   version                => '11.2.0.1',
#   file                   => 'linux.x64_11gR2_database',
#   databaseType           => 'SE',
#   oracleBase             => '/oracle',
#   oracleHome             => '/oracle/product/11.2/db',
# #  eeOptionsSelection     => true,
# #  eeOptionalComponents   => 'oracle.rdbms.partitioning:11.2.0.4.0,oracle.oraolap:11.2.0.4.0,oracle.rdbms.dm:11.2.0.4.0,oracle.rdbms.dv:11.2.0.4.0,oracle.rdbms.lbac:11.2.0.4.0,oracle.rdbms.rat:11.2.0.4.0',
#   user                   => 'oracle',
#   group                  => 'dba',
#   group_install          => 'oinstall',
#   group_oper             => 'oper',
#   downloadDir            => '/install',
#   zipExtract             => true,
#   puppetDownloadMntPoint => $puppetDownloadMntPoint,
#   #remote_file            => false
# }
oradb::listener{'startlistener':
  action       => 'start',  # running|start|abort|stop
  oracleBase   => '/oracle',
  oracleHome   => '/oracle/product/11.2/db',
  user         => 'oracle',
  group        => 'dba',
  listenername => 'listener' # which is the default and optional
}
oradb::database{ 'testDb_Create':
  oracleBase              => '/oracle',
  oracleHome              => '/oracle/product/11.2/db',
  version                 => '11.2',
  user                    => 'oracle',
  group                   => 'dba',
  downloadDir             => '/install',
  action                  => 'create',
  dbName                  => 'test',
  dbDomain                => 'oracle.com',
  dbPort                  => '1521',
  sysPassword             => 'Welcome01',
  systemPassword          => 'Welcome01',
  dataFileDestination     => "/oracle/oradata",
  recoveryAreaDestination => "/oracle/flash_recovery_area",
  characterSet            => "AL32UTF8",
  nationalCharacterSet    => "UTF8",
  initParams              => {'open_cursors'        => '1000',
                              'processes'           => '600',
                              'job_queue_processes' => '4' },
  sampleSchema            => 'TRUE',
  memoryPercentage        => "40",
  memoryTotal             => "800",
  databaseType            => "MULTIPURPOSE",
  emConfiguration         => "NONE",
  require                 => Oradb::Listener['startlistener'],
}
}
