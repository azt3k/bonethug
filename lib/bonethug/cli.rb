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
        puts 'Usage: bonethug install [type] [location]' if type.empty?
        
        # run the installer
        Installer.install type, location

      when 'watch'

        # handle args
        type = ARGV[1] || 'all'
        location = ARGV[2] || '.'
        puts 'Usage: bonethug watch [type] [location]' if type.empty?        
        
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