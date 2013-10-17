require File.expand_path(File.dirname(__FILE__) + "/../bonethug")

namespace :thug do

  def update_version_file(content = nil)

    unless content

      # generate content for version file
      content = '
        module Bonethug
          VERSION = "' + Bonethug::VERSION + '"
          BUILD_DATE = "' + Time.now.to_s + '"
        end
      '

    end

    # handle paths
    ver_path = File.expand_path File.dirname(__FILE__) + '/../bonethug/version.rb'

    # write data
    File.open(ver_path,'w') do |file| 
      file.puts content
    end

  end

  desc "Runs rake build + some other stuff"
  task :vup do

    puts "was " + Bonethug::VERSION

    Bonethug::increment_version
    update_version_file

    puts "now " + Bonethug::VERSION

  end  

  desc "Runs rake build + some other stuff"
  task :build do

    # update version file
    update_version_file

    # invoke the build script
    Rake::Task["build"].invoke

  end

  desc "Runs rake release + bonethug:build"
  task :release do

    # handle path
    path = File.expand_path File.dirname(__FILE__) + '/../../pkg/bonethug-' + Bonethug::VERSION + '.gem'

    # check if there's a build with the current version
    Rake::Task["thug:build"].invoke

    # do the bidniz
    exec 'git commit -am "commit to build" && rake release --trace'

  end

end