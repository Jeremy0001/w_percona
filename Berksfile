# -*- mode: ruby -*-
# vi: set ft=ruby :
source 'https://supermarket.chef.io'

cookbook 'ubuntu'
cookbook 'apt'
cookbook 'apt-repo', git: 'https://github.com/sometimesfood/chef-apt-repo.git'
cookbook 'git'
cookbook 'monit', git: 'https://github.com/phlipper/chef-monit.git'
cookbook 'firewall', "~> 1.4.0"
cookbook 'ntp'
cookbook 'sudo'
cookbook 'timezone-ii'

cookbook 'percona', '~> 0.16.1'
cookbook 'xinetd', git: 'https://github.com/joelhandwell/cookbook-xinetd.git'

group :wrapper do
  cookbook 'w_percona', path: './'
end
