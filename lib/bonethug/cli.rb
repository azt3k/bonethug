module Bonethug
  class CLI

    def self.handle

      # what are we doing?
      task = ARGV[0] || 'help'

      case task

      when 'help'

        display_help

      when 'install'

        # handle args
        type = ARGV[1]
        location = ARGV[2] || '.'

        # validate
        unless type
          puts 'Usage: bonethug install [type] [location]'
          return
        end
        
        # run the installer
        Installer.install type, location

      when 'init', 'update'

        # handle args
        location = ARGV[1] || '.'

        # validate
        unless location
          puts 'Usage: bonethug #{task} [location]'
          return
        end

        # run the initaliser
        Installer.bonethugise(location, task.to_sym)

      when 'deploy', 'setup', 'remote-backup', 'local-backup', 'sync-backup-to', 'sync-backup-from', 'sync-local-to', 'sync-local-from', 'init-db'

        # handle args
        environment = ARGV[1]

        # validate
        unless environment
          puts 'Usage: bonethug #{task} [environment]' 
          return
        end

        case task

        # Setup and Deploy
        when 'deploy'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb deploy --verbose"
        when 'setup'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb setup --verbose"

        # remote db scripts
        when 'init-db'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb init_db --verbose"          

        # Snapshot Backup
        when 'remote-backup'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb backup --verbose"                   
        when 'local-backup'
          exec "export to=#{environment} && bundle exec astrails-safe .bonethug/backup.rb"

        # Synchronised backup
        when 'sync-backup-to'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb sync_to --verbose"
        when 'sync-backup-from'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb sync_from --verbose"

        when 'sync-local-to'
          exec "ruby .bonethug/syncer.rb sync_local_to #{environment}"
        when 'sync-local-from'
          exec "ruby .bonethug/syncer.rb sync_local_from #{environment}"                 
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

    def self.display_help
      puts 'Usage: bonethug task [argument]...'
    end

  end
end