require 'fileutils'

module Bonethug

  #arguments can be for example db:migrate
  def self.call_rake(arguments)
    if RUBY_PLATFORM =~ /mswin/
      rake_cmd = "rake.bat" #very important because windows will break with just "rake"
    else
      rake_cmd = "rake"
    end
    puts "calling #{rake_cmd} " + arguments
    puts system("#{rake_cmd} " + arguments)
    puts $?
  end

  def self.setup_gitpull(target = '.')

    path = File.expand_path target
    `chown www-data #{path}`

  end

end