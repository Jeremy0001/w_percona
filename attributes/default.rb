default['percona']['apt']['keyserver'] = 'hkp://keyserver.ubuntu.com:80'
default['percona']['server']['tmpdir'] = '/var/tmp'
default['percona']['server']['slave_load_tmpdir'] = '/var/tmp'
default['percona']['server']['binlog_format'] = 'ROW'
default['percona']['xinetd_enabled'] = false
default['percona']['cluster']['wsrep_sst_auth'] = 'sstdefaultuser:sstdefaultpassword'
default['percona']['conf']['log']['log-error'] = '/var/log/mysql.err'
