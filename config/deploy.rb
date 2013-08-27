# Todo
# - implement a restore from backup task
# - implement a cleanup task when a deploy fails - its not good if the apache conf gets malformed
# - review directory permissions
# - passenger executes rails as the user that owns evironment.rb - if root owns it it runs as nobody

# Requires
# ---------------------------------------------------------------
require 'rubygems'
require 'bonethug/conf'
require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'
require 'mina/whenever'

# Config
# ---------------------------------------------------------------

# load the conf
conf = Bonethug::Conf.new
cnf = conf.to_hash

# pull config from environment vars
env = ENV['to']
raise 'could not find deployment environment' unless conf.get('deploy.environments').has_key? env

# build config
deploy    = conf.node_merge('deploy.common','deploy.environments.'+env)
resources = conf.get('resources','Array') || []
log_dirs  = conf.get('log_dirs','Array') || []

# vhost name
vhost = deploy.get('project_slug') + '_' + env

# composer?
use_composer = ['silverstripe','silverstripe3','drupal','php'].include? deploy.get('project_type')

# directories we need to track
resources += ['backups']
resources.push 'vendor' if use_composer

# logs
log_dirs.push 'log' unless log_dirs.include? 'log'

# shared paths
shared = resources + log_dirs + ['tmp']
shared.push 'composer.phar' if use_composer

# shared config
set :deploy_to,     deploy.get('base_dir') + '/' + vhost
set :repository,    deploy.get('repository')
set :branch,        ENV['branch'] || deploy.get('default_branch')
set :domain,        deploy.get('domain')
set :user,          deploy.get('user')
set :port,          deploy.get('port')
set :rails_env,     env
set :shared_paths,  shared
 

# Tasks
# ---------------------------------------------------------------

desc "Load Environment"
task :environment do
  # invoke :'rbenv:load'
end

desc "Sets up the Project"
task :setup => :environment do

  # make shared resource dirs
  (resources + log_dirs).each do |path|
    queue! %[mkdir -p "#{deploy_to}/shared/#{path}"]
  end

  # set appropriate permissions on the resource dirs
  resources.each do |path|
    queue! %[chown -R www-data:www-data "#{deploy_to}/shared/#{path}"]
    queue! %[chmod -R 0775 "#{deploy_to}/shared/#{path}"]
  end  

  # set appropriate permissions on the logs
  log_dirs.each do |path|
    queue! %[chown -R www-data:www-data "#{deploy_to}/shared/#{path}"]
    queue! %[chmod -R 0666 "#{deploy_to}/shared/#{path}"]
  end

  # make sure the vhost exists
  queue! %[touch /etc/apache2/sites-available/#{vhost}]

  # set up the tmp dir (rails only?)
  queue! %[mkdir -p "#{deploy_to}/shared/tmp"]
  queue! %[touch "#{deploy_to}/shared/tmp/restart.txt"]
  queue! %[cd #{deploy_to}/shared/tmp && chown -R www-data:www-data . && chmod -R 775 .]
 
  # init composer
  if use_composer
    queue! %[mkdir -p "#{deploy_to}/shared/vendor"]
    queue! %[cd #{deploy_to}/shared && curl -s http://getcomposer.org/installer | php] 
  end

  # create the backup folder
  queue! %[mkdir -p "#{deploy_to}/shared/backups"]

end

desc "Updates bundled dependencies"
task :update_packages => :environment do
  invoke :'bundle:update'
  queue! %[php #{deploy_to}/shared/composer.phar update] if use_composer
  queue! %[php #{deploy_to}/current/public/framework/cli-script.php dev/build] if ['silverstripe','silverstripe3'].include? deploy.get('project_type') 
end

desc "Restores application state to the most recent backup"
task :init_db => :environment do
  queue! %[cd #{deploy_to}/current && bundle exec rake db:reset RAILS_ENV="#{env}"] if deploy.get('project_type') == 'rails'
end

desc "Restores application state to the most recent backup"
task :backup => :environment do
  queue! %[cd #{deploy_to}/current && export to=#{env} && bundle exec astrails-safe .bonethug/backup.rb] if deploy.get('project_type') == 'rails'
end

desc "Restores application state to the most recent backup"
task :restore_backup => :environment do
  # to be implemented
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do

    # common deployment tasks
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'

    # rails deploy tasks
    if deploy.get('project_type') == 'rails'
      invoke :'rails:db_migrate'
      invoke :'rails:assets_precompile'
    end

    # update composer
    queue! %[php #{deploy_to}/shared/composer.phar update] if use_composer

    # build the vhosts
    vh_cnf = conf.get('apache.'+env)

    # server aliases
    server_aliases = ''
    aliases = vh_cnf.get('server_aliases')
    if aliases
      aliases.each do |index, server_alias|
        server_aliases += 'ServerAlias '+server_alias + "\n"
      end
    end

    # environment variables
    env_vars = ''
    vars = vh_cnf.get('env_vars')
    if vars
      vars.each do |k, v|
        env_vars += 'SetEnv ' + k + ' ' + v + "\n"
      end
    end

    # server admin
    admin = vh_cnf.get('server_admin')
    server_admin = admin ? 'ServerAdmin '+admin : ''

    vh = "
<VirtualHost *:80>

  ServerName  #{vh_cnf.get('server_name')}
  #{server_aliases}

  #{server_admin}

  DocumentRoot #{deploy_to}/current/public

  #{env_vars}
  PassEnv PATH

  CustomLog #{deploy_to}/shared/log/bytes.log bytes
  CustomLog #{deploy_to}/shared/log/combined.log combined
  ErrorLog  #{deploy_to}/shared/log/error.log

  <Directory #{deploy_to}/current/public>

    Options Indexes MultiViews FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
    
  </Directory>

</VirtualHost>
    "

    # install the vhost
    queue 'rm /etc/apache2/sites-available/'+vhost
    queue 'echo "'+vh+'" > /etc/apache2/sites-available/'+vhost    

    to :launch do

      if ['rails3'].include? deploy.get('project_type')

        # make sure passenger runs the app as apache
        queue! %[cd #{deploy_to}/current/config && chown -R www-data:www-data environment.rb]
        queue! %[cd #{deploy_to}/current && chown -R www-data:www-data config.ru]

      end      

      # ensure that the correct directory permissions are set
      queue! %[cd #{deploy_to}/current/public && chown -R www-data:www-data . && chmod -R 775 .]
      queue! %[cd #{deploy_to}/shared/tmp && chown -R www-data:www-data . && chmod -R 775 .]      
      queue! %[touch #{deploy_to}/current/tmp/restart.txt]
      
      # apply defined permissions
      chowns = conf.get('chown.'+env)
      if chowns
        chowns.each do |index, chown|
          queue! %[cd #{deploy_to}/current/#{chown.get('path')} && chown -R #{chown.get('user')} .]
        end
      end
      
      # apply defined permissions
      chgrps = conf.get('chgrp.'+env)
      if chgrps
        chgrps.each do |index, chgrp|
          queue! %[cd #{deploy_to}/current/#{chgrp.get('path')} && chgrp -R #{chgrp.get('group')} .]
        end
      end      
      
      # apply defined permissions
      chmods = conf.get('chmod.'+env)
      if chmods
        chmods.each do |index, chmod|
          queue! %[cd #{deploy_to}/current/#{chmod.get('path')} && chmod -R #{chmod.get('mode')} .]
        end
      end

      queue! %[a2ensite "#{vhost}"]
      queue! %[/etc/init.d/apache2 reload]
      invoke :'whenever:update'

      queue! %[export APPLICATION_ENV=#{env} && php #{deploy_to}/current/public/framework/cli-script.php dev/build] if ['silverstripe','silverstripe3'].include? deploy.get('project_type')

    end
  end
end