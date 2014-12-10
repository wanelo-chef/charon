default['charon']['user'] = 'ftpd'

default['charon']['git']['repository'] = 'https://github.com/wanelo/charon.git'

default['charon']['config']['pipe_path'] = '/var/run/named.pipe'
default['charon']['config']['vhost'] = '/'
default['charon']['config']['exchange'] = 'charon'
default['charon']['config']['durable'] = true
default['charon']['config']['routing_key'] = 'charon.uploads'
default['charon']['config']['host'] = 'localhost'
default['charon']['config']['port'] = 5672
default['charon']['config']['user'] = 'guest'
default['charon']['config']['password'] = 'guest'
default['charon']['config']['nfs_path'] = '/var/nfs'

default['charon']['service']['pure_ftpd_fmri'] = 'svc:/application/management/pure-ftpd'
