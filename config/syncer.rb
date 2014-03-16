#!/usr/bin/env ruby

# Requires
# ---------------------------------------------------------------
require 'rubygems'
require 'bonethug/conf'

# Config
# ---------------------------------------------------------------

# exec env
exec_path   = File.expand_path(File.dirname(__FILE__) + '/..')
env         = ENV['to']

# load config
conf = Bonethug::Conf.new.add(exec_path + '/config/cnf.yml')
conf.add(exec_path + '/config/database.yml' => { root: 'dbs.default' }) if File.exist? exec_path + '/config/database.yml'

# extract some data
cnf  = conf.to_hash
envs = conf.get('deploy.environments').to_hash

# args
env_local  = ARGV[1]
env_remote = ARGV[2]
type       = ARGV[0]

# validate

unless env_local and env_remote
  puts 'Usage: syncer.rb ' + type + ' [local_environment] [remote_environment]'
  return
end

unless envs.has_key? env_local
  puts 'could not find local environment'
  return
end

unless envs.has_key? env_remote
  puts 'could not find remote environment'
  return
end

# build config
dbs           = conf.get 'dbs'
remote_deploy = conf.node_merge 'deploy.common', 'deploy.environments.' + env_remote
local_deploy  = conf.node_merge 'deploy.common', 'deploy.environments.' + env_local
resources     = conf.get('resources','Array') || []
log_dirs      = conf.get('log_dirs','Array') || []
remote_vhost  = remote_deploy.get('project_slug') + '_' + env_remote

# directories we need to track
resources += ['backups']

# logs
log_dirs.push 'log' unless log_dirs.include? 'log'

# do the common work
remote_path = remote_deploy.get('base_dir') + '/' + remote_vhost
remote_ssh  = "ssh -p #{remote_deploy.get 'port'} #{remote_deploy.get 'user'}@#{remote_deploy.get 'domain'}"

# output
puts "Cloning Databases... "

# output
dbs.each do |index, db|

  db_remote = db.get env_remote
  db_local  = db.get env_local

  if type == "sync-local-from"
    cmd = "#{remote_ssh} \"mysqldump -u #{db_remote.get 'user'} -p#{db_remote.get 'pass'} #{db_remote.get 'name'} --verbose | bzip2 -c\" | bunzip2 -c | mysql -u #{db_local.get 'user'} -p#{db_local.get 'pass'} #{db_local.get 'name'}"
  elsif type == "sync-local-to"
    cmd = "mysqldump -u #{db_local.get 'user'} -p#{db_local.get 'pass'} #{db_local.get 'name'} --verbose | bzip2 -c | #{remote_ssh} \"bunzip2 -c | mysql -u #{db_remote.get 'user'} -p#{db_remote.get 'pass'} #{db_remote.get 'name'}\""
  end

  puts cmd
  system cmd

end

puts "Done."
puts "Syncing Files... "

# sync the files
(resources + log_dirs).each do |item|

  case type
  when "sync-local-from"
    cmd = "rsync -zrav -e \"ssh -p #{remote_deploy.get('port')} -l #{remote_deploy.get('user')}\" --delete --copy-dirlinks #{remote_deploy.get('domain')}:#{remote_path}/current/#{item} #{exec_path}/#{item}"
  when "sync-local-to"
    cmd = "rsync -zrav -e \"ssh -p #{remote_deploy.get('port')} -l #{remote_deploy.get('user')}\" --delete --copy-dirlinks #{exec_path}/#{item} #{remote_deploy.get('domain')}:#{remote_path}/current/#{item}"
  end

  puts cmd
  system cmd

end

puts "Done."