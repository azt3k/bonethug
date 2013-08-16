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
        puts 'Usage: bonethug install [{location}]' if type.empty?
        
        # run the installer
        Installer.install type, location 
      
      when 'clean'

        location = ARGV[1] || '.'
        Installer.clean location   

      else

        # We did n't find a task
        puts 'Task not found'

      end

    end

    def self.display_help
      puts 'Usage: bonethug {task} [{arguements}]'
    end

  end
end