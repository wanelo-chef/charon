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
directory node['charon']['config']['nfs_path'] do
  action :create
  mode 0755
  owner user
end

package 'ruby' do
  version '2.1'
  ignore_failure true
end

gem_package 'bundler'

install_dir = '/opt/charon'

git install_dir do
  repository node['charon']['git']['repository']
  notifies :run, 'execute[gem build charon.gemspec]'
end

execute 'gem build charon.gemspec' do
  action :nothing
  cwd install_dir
  umask 0022
  notifies :run, 'ruby_block[install charon gemspec]'
end

ruby_block 'install charon gemspec' do
  action :nothing

  block do
    gem = Dir["#{install_dir}/*.gem"].first
    `gem install #{gem}`
    ::File.unlink gem
  end

  notifies :restart, 'service[charon]'
end

config_file = File.join(node['paths']['etc_dir'], 'charon.yml')

template config_file do
  source 'config.yml.erb'
  variables 'pipe_path' => node['charon']['config']['pipe_path'],
    'exchange' => node['charon']['config']['exchange'],
    'durable' => node['charon']['config']['durable'],
    'routing_key' => node['charon']['config']['routing_key'],
    'host' => node['charon']['config']['host'],
    'port' => node['charon']['config']['port'],
    'user' => node['charon']['config']['user'],
    'password' => node['charon']['config']['password'],
    'nfs_path' => node['charon']['config']['nfs_path'],
    'vhost' => node['charon']['config']['vhost']
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

  dependencies [
    {'name' => 'pure-ftpd', 'fmris' => [node['charon']['service']['pure_ftpd_fmri']],
      'grouping' => 'require_all', 'restart_on' => 'restart', 'type' => 'service'}
  ]
end

service 'charon' do
  action :enable
  supports restart: true, status: true, reload: true
end
