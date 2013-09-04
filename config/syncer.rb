#!/usr/bin/env ruby

# Requires
# ---------------------------------------------------------------
require 'rubygems'
require 'bonethug/conf'

# Config
# ---------------------------------------------------------------

# load the conf
conf = Bonethug::Conf.new
cnf = conf.to_hash

# args
env = ARGV[1]
type = ARGV[0]

# pull config from environment vars
raise 'could not find deployment environment' unless conf.get('deploy.environments').has_key? env

# build config
deploy    = conf.node_merge('deploy.common','deploy.environments.'+env)
resources = conf.get('resources','Array') || []
log_dirs  = conf.get('log_dirs','Array') || []
vendor  = conf.get('vendor','Array') || []

# vhost name
vhost = deploy.get('project_slug') + '_' + env

# composer?
use_composer = ['silverstripe','silverstripe3','drupal','php'].include? deploy.get('project_type')

# directories we need to track
resources += ['backups']

# logs
log_dirs.push 'log' unless log_dirs.include? 'log'

# do the common work
path = deploy.get('base_dir') + '/' + vhost
ssh_pass = rsync.get('pass') ? "sshpass -p #{rsync.get('pass')}" : ""
queue! %[#{ssh_pass} ssh #{rsync.get('user')}@#{rsync.get('host')} mkdir -p #{path}]

(resources + log_dirs).each do |item|
  case type
  when "sync-local-from"
    exec "rsync -r -a -v -e \"#{ssh_pass} ssh -l #{rsync.get('user')}\" --delete --copy-dirlinks #{rsync.get('host')}:#{path}/current/#{item} ./"
  when "sync-local-to"
    exec "rsync -r -a -v -e \"#{ssh_pass} ssh -l #{rsync.get('user')}\" --delete --copy-dirlinks ./#{item} #{rsync.get('host')}:#{path}/current/"
  end
end