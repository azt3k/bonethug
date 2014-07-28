require 'rbconfig'
require 'bonethug/conf'
require 'bonethug/configurator'

module Bonethug
  class CLI

    @@tasks = [
      'help',
      'auth',
      'install',
      'init-db',
      'init-local-db',
      'setup-db',
      'setup-env',
      'vhost-local',
      'init',
      'update',
      'run',
      'rake',
      'drush',
      'drush-local',
      'sake',
      'sync-state',
      'deploy',
      'setup',
      'remote-backup',
      'local-backup',
      'sync-backup-to',
      'sync-backup-from',
      'force-unlock',
      'cleanup',
      'clean',
      'watch'
    ]

    def self.tasks
      @@tasks
    end

    def self.handle(bin_name = 'thug')

      # what are we doing?
      task = ARGV[0] || 'help'

      case task

      when 'help'

        display_help

      when 'tasks'

        @@tasks.each do |task|
          puts task
        end

      when 'version'

        puts 'bonethug v' + VERSION + ' - build date: ' + BUILD_DATE
        exit

      when 'auth'

        # handle args
        env = ARGV[1]

        # validate
        unless env
          puts 'Usage: ' + bin_name + ' auth [environment]'
          return
        end

        exec "export to=#{env} && bundle exec mina -f .bonethug/deploy.rb auth --verbose"

      when 'install'

        # handle args
        type = ARGV[1]
        location = ARGV[2] || '.'

        # validate
        unless type
          puts 'Usage: ' + bin_name + ' install [type] [location]'
          return
        end

        # run the installer
        Installer.install type, location

      when 'init-db', 'init-local-db', 'setup-db'

        # handle args
        env = ARGV.last
        admin_user = ARGV.length == 3 ? ARGV[1] : 'root'

        # validate
        if !env || env == task
          puts 'Usage: ' + bin_name + ' ' + task + ' [admin_user] [environment]'
          return
        end

        if task == 'init-local-db'
          Installer.execute_init_mysql_db_script env, admin_user
        elsif task == 'setup-db'
          exec "export to=#{env} && export admin_user=#{admin_user} && bundle exec mina -f .bonethug/deploy.rb setup_db --verbose"
        else
          exec "export to=#{env} && export admin_user=#{admin_user} && bundle exec mina -f .bonethug/deploy.rb init_db --verbose"
        end

      when 'setup-env'

        # handle args
        env = ARGV.last

        # validate
        if !env || env == task
          puts 'Usage: ' + bin_name + ' setup-env [environment]'
          return
        end

        # find the file
        gem_dir = File.expand_path File.dirname(__FILE__) + '/../..'
        script = gem_dir + '/scripts/ubuntu_setup.sh'

        if env == 'show'

          puts "---------------"
          puts "Pre"
          puts "---------------\n"
          puts File.read script

          puts "\n---------------"
          puts "Parsed"
          puts "---------------"
          puts Installer.parse_sh File.read(script)

        elsif env == 'local'
          exec 'sudo bash ' + script

        else
          exec "export to=#{env} && bundle exec mina -f .bonethug/deploy.rb setup_env --verbose"

        end

      when 'vhost-local'

        # get env
        env = ARGV.last
        env = 'development' if env == 'vhost-local'

        # exec env
        exec_path   = File.expand_path('.')

        # load config
        conf = Conf.new.add exec_path + '/config/cnf.yml'
        conf.add(exec_path + '/config/database.yml' => { root: 'dbs.default' }) if File.exist? exec_path + '/config/database.yml'
        deploy = conf.node_merge 'deploy.common', 'deploy.environments.' + env

        # vhost name
        vhost = deploy.get('project_slug') + '_' + env

        # build the vhost conf
        vh_cnf = conf.get 'vhost'
        vh_cnf = conf.get 'apache' unless vh_cnf
        vh_cnf = vh_cnf.get env

        # exit if we have no env
        unless vh_cnf
          puts "unable to find vhost conf for " + env
          exit
        end

        # get the conf path
        conf_path = vh_cnf.get('conf_path') || '/etc/apache2/sites-available'

        # load the appropriate config for the web server
        vh = Configurator.vhost vh_cnf, exec_path, deploy.get('project_type'), env

        # check if we have a custom config for the webserver type
        case vh_cnf.get('type')
        when "nginx"

          # to be implemented
          puts 'to be implemented'
          exit

        else # apache

          # install the vhost
          system "echo \"#{vh}\" > #{conf_path}/#{vhost}.conf"

        end

        # handle hosts file update
        path = RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwin/i ? '/c/Windows/System32/drivers/etc/hosts' : '/etc/hosts'
        hosts = "
          ## BONETHUG-#{vhost} ##
            #{Configurator.hosts vh_cnf}
          ## END_BONETHUG-#{vhost} ##
        "

        # write the to the hosts file
        # this needs work
        system "sed -i '/## BONETHUG-#{vhost} ##/,/## END_BONETHUG-#{vhost} ##/ s/.*//g' #{path}"
        escaped = (hosts).gsub(/"/, '\"')
        system "echo \"#{escaped}\" >> #{path}"

        # reload apache - linux - but need a debian specific look up
        system "a2ensite #{vhost} && service apache2 restart" if RbConfig::CONFIG['target_os'] =~ /linux/i

      when 'init', 'update'

        # handle args
        location = ARGV[1] || '.'
        stage = ARGV[2] || 0

        # validate
        unless location
          puts 'Usage: ' + bin_name + ' #{task} [location]'
          return
        end

        # run the initaliser
        Installer.bonethugise location, task.to_sym, stage.to_i

      when  'run',
            'rake',
            'drush',
            'drush-local',
            'sake'

        # get env
        environment = ARGV.last

        # handle args
        if task == 'run'
          cmd_task = ARGV[1]
          args = ARGV[2..(ARGV.length-2)]
        else
          case task
          when 'rake'
            cmd_task = 'rake'
          when 'drush', 'drush-local'
            cmd_task = File.expand_path('./vendor/drush/drush/drush') + ' -r ' + File.expand_path('./public')
          when 'sake'
            cmd_task = 'public/framework/sake'
          end
          args = ARGV[1..(ARGV.length-2)]
        end

        if task == 'drush-local'

          env_cmd = RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwin/i ? 'set' : 'export'
          cmd = env_cmd + " APPLICATION_ENV=#{environment} && #{cmd_task} #{args.join(' ')}"
          puts
          exec cmd

        else

          # build command
          run = "\"run[#{cmd_task} #{args.join(' ')}]\""

          # do it!
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb #{run} --verbose"

        end

      when  'sync-state'

        # operation whitelist
        operations = ['pull-from-local', 'push-to-local', 'pull-from-remote', 'push-to-remote']

        # args
        operation1 = ARGV[1]
        env1       = ARGV[2]
        operation2 = ARGV[3]
        env2       = ARGV[4]

        puts

        # validate operation whitelist
        valid_operation = operations.include?(operation1) and operations.include?(operation2)

        # ensure there is both a pull and push operation
        if valid_operation
          has_pull = (operation1 == 'pull-from-local' or operation2 == 'pull-from-local' or operation1 == 'pull-from-remote' or operation2 == 'pull-from-remote')
          has_push = (operation1 == 'push-to-local'   or operation2 == 'push-to-local'   or operation1 == 'push-to-remote'   or operation2 == 'push-to-remote')
          valid_operation = has_push and has_push
        end

        # validate
        unless operation1 and operation2 and env1 and env2 and valid_operation
          puts 'Usage: thug sync-state [pull-from-{local|remote}] [environment] [push-to-{local|remote}] [environment]'
          exit
        end

        # process env data
        pull_env = (operation1 == 'pull-from-remote' or operation1 =='pull-from-local') ? env1 : env2
        push_env = (operation1 == 'push-to-remote'   or operation1 =='push-to-local')   ? env1 : env2

        # process operation1
        case operation1
        when 'pull-from-local'
          pull_operation = 'local'
        when 'pull-from-remote'
          pull_operation = 'remote'
        when 'push-to-local'
          push_operation = 'local'
        when 'push-to-remote'
          push_operation = 'remote'
        end

        # process operation2
        case operation2
        when 'pull-from-local'
          pull_operation = 'local'
        when 'pull-from-remote'
          pull_operation = 'remote'
        when 'push-to-local'
          push_operation = 'local'
        when 'push-to-remote'
          push_operation = 'remote'
        end

        # stop here if its a local to local because we wont know the file system location of the non-calling local
        if pull_operation == 'local' and push_operation == 'local'
          puts 'local to local sync is not supported at this time'
          exit
        end

        # Do Sync
        if pull_operation == 'local' or push_operation == 'local'
          Syncer.sync pull_operation, pull_env, push_operation, push_env
        else
          # this will call ruby .bonethug/syncer.rb local #{pull_env} remote #{push_env}
          exec "export to=#{pull_env} && export remote_env=#{push_env} && bundle exec mina -f .bonethug/deploy.rb sync_state --verbose"
        end


      when  'deploy',
            'setup',
            'remote-backup',
            'local-backup',
            'sync-backup-to',
            'sync-backup-from',
            'force-unlock',
            'cleanup'

        # handle args
        environment = ARGV[1]

        # validate
        unless environment
          puts 'Usage: thug #{task} [environment]'
          return
        end

        case task

        # Setup and Deploy
        when 'deploy'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb deploy --verbose"
        when 'setup'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb setup --verbose"

        # remote mina scripts
        when 'force-unlock'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb deploy:force_unlock --verbose"
        when 'cleanup'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb deploy:cleanup --verbose"

        # Snapshot Backup
        when 'remote-backup'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb backup --verbose"
        when 'local-backup'
          exec "export to=#{environment} && bundle exec astrails-safe .bonethug/backup.rb"

        # Synchronised backup
        when 'sync-backup-to'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb sync_backup_to --verbose"
        when 'sync-backup-from'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb sync_backup_from --verbose"

        end

      when 'watch'

        # handle args
        type = ARGV[1] || 'coffee_sass'
        location = ARGV[2] || '.'
        watch_only = ARGV[3] || nil

        # run the installer
        Watcher.watch type, location, watch_only

      when 'clean'

        location = ARGV[1] || '.'
        Installer.clean location

      else

        # We didn't find a task
        puts 'Task not found'

      end

    end

    def self.display_help(bin_name = 'thug')
      puts 'Usage:  ' + bin_name + '  task [argument]...'
    end

  end
end