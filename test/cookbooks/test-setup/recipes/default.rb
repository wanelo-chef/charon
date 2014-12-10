include_recipe 'test-setup::_node'

execute 'mkfifo %s' % node['test_setup']['pipe_path'] do
  action :run
  umask 0022
end
