#
# Cookbook Name:: charon
# Recipe:: default
#
# Copyright (C) 2014 Wanelo, Inc.
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'smf'

user = node['charon']['user']
user user

package 'ruby212-base' do
  version '2.1'
end

gem_package 'bundler'

install_dir = '/opt/charon'

git install_dir do
  repository node['charon']['git']['repository']
end

execute 'gem build charon.gemspec' do
  cwd install_dir
  umask 0022
end

gem_package 'charon' do
  source '%s/charon-0.0.1.gem' % install_dir
end

config_file = File.join(node['paths']['etc_dir'], 'charon.yml')

template config_file do
  source 'config.yml.erb'
  variables 'pipe_path' => node['charon']['config']['pipe_path'],
    'exchange' => node['charon']['config']['exchange'],
    'routing_key' => node['charon']['config']['routing_key'],
    'host' => node['charon']['config']['host'],
    'port' => node['charon']['config']['port'],
    'user' => node['charon']['config']['user'],
    'password' => node['charon']['config']['password'],
    'nfs_path' => node['charon']['config']['nfs_path']
end

smf 'charon' do
  start_command '%{config/bin_dir}/charon start %{config/path} &'
  working_directory '/var/tmp'
  user user
  property_groups 'config' => {
    'path' => config_file,
    'bin_dir' => node['paths']['bin_dir']
  }
  environment({
    'PATH' => node['paths']['bin_path'],
    'LANG' => 'en_us.UTF-8',
    'LC_LANG' => 'en_us.UTF-8'
  })
end

service 'charon' do
  action :enable
  supports restart: true, status: true, reload: true
end
