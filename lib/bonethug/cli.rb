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
        if type.empty?
          puts 'Usage: bonethug install [type] [location]'
          return
        end
        
        # run the installer
        Installer.install type, location

      when 'init', 'update'

        # handle args
        location = ARGV[1] || '.'

        # validate
        if location.empty?
          puts 'Usage: bonethug #{task} [location]'
          return
        end

        # run the initaliser
        Installer.bonethugise(location, task.to_sym)

      when 'deploy', 'setup', 'remote-backup', 'local-backup'

        # handle args
        environment = ARGV[1]

        # validate
        if environment.empty?
          puts 'Usage: bonethug #{task} [environment]' 
          return
        end

        case task
        when 'deploy'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb deploy --verbose"
        when 'setup'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb setup --verbose"
        when 'remote-backup'
          exec "export to=#{environment} && bundle exec mina -f .bonethug/deploy.rb backup --verbose"                   
        when 'local-backup'
          exec "export to=#{environment} && bundle exec astrails-safe .bonethug/backup.rb" 
        end 

      when 'watch'

        # handle args
        type = ARGV[1] || 'all'
        location = ARGV[2] || '.'        
        
        # run the installer
        Watcher.watch type, location         
      
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