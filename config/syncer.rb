#!/usr/bin/env ruby

# Requires
# ---------------------------------------------------------------
require 'rubygems'
require 'bonethug/conf'

# Config
# ---------------------------------------------------------------

# load the conf
conf = Bonethug::Conf.new
cnf  = conf.to_hash
envs = conf.get 'deploy.environments'

# args
env_local  = ARGV[1]
env_remote = ARGV[2]
type       = ARGV[0]

# validate
unless env_local and env_remote
  puts 'Usage: syncer.rb ' + type + ' [local_environment] [remote_environment]'
  return
end

# pull config from environment vars
raise 'could not find deployment environment' unless envs.has_key? env_local and envs.has_key? env_remote

# build config
remote_deploy = conf.node_merge 'deploy.common', 'deploy.environments.' + env_local
local_deploy  = conf.node_merge 'deploy.common', 'deploy.environments.' + env_local
resources     = conf.get('resources','Array') || []
log_dirs      = conf.get('log_dirs','Array') || []
remote_vhost  = deploy.get('project_slug') + '_' + env_remote
dbs           = conf.get 'dbs'

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
dbs.each do |index,db|

  db_remote = db.get env_remote
  db_local  = db.get env_local

  if type == "sync-local-to"
    system "#{remote_ssh} \"mysqldump -u #{db_remote.get 'user'} -p #{db_remote.get 'pass'} #{db_remote.get 'name'} --verbose | bzip2 -c\" | bunzip2 -c | mysql -u #{db_local.get 'user'} -p #{db_local.get 'pass'} #{db_local.get 'name'}"
  elsif type == "sync-local-from"
    system "mysqldump -u #{db_local.get 'user'} -p #{db_local.get 'pass'} #{db_local.get 'name'} --verbose | bzip2 -c | #{remote_ssh} \"bunzip2 -c | mysql -u #{db_remote.get 'user'} -p #{db_remote.get 'pass'} #{db_remote.get 'name'}\""
  end

end

puts "Done."
puts "Syncing Files... "

# sync the files
(resources + log_dirs).each do |item|
  case type
  when "sync-local-from"
    system "rsync -r -a -v -e \"#{ssh_pass} ssh -l #{rsync.get('user')}\" --delete --copy-dirlinks #{rsync.get('host')}:#{path}/current/#{item} ./"
  when "sync-local-to"
    system "rsync -r -a -v -e \"#{ssh_pass} ssh -l #{rsync.get('user')}\" --delete --copy-dirlinks ./#{item} #{rsync.get('host')}:#{path}/current/"
  end
end

puts "Done."