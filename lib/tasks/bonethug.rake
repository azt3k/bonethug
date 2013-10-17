require File.expand_path(File.dirname(__FILE__) + "/../bonethug")

namespace :bonethug do

  desc "Runs rake build + some other stuff"
  task :build do

    # handle paths
    ver_path = File.expand_path File.dirname(__FILE__) + '/../bonethug/version.rb'
    pkg_path = File.expand_path File.dirname(__FILE__) + '/../../pkg/bonethug-' + Bonethug::VERSION + '.gem'    

    # handle version
    if File.exists? pkg_path

      version = Bonethug::VERSION.split('.')
      version[version.length-1] = (version.last.to_i + 1).to_s
      version = version.join('.')

      Bonethug::update_version version

      puts "Building version " + Bonethug::VERSION + '...'

    end

    # generate content for version file
    content = '
      module Bonethug
        VERSION = "' + Bonethug::VERSION + '"
        BUILD_DATE = "' + Time.now.to_s + '"
      end
    '

    # write data
    File.open(ver_path,'w') do |file| 
      file.puts content
    end

    # invoke the build script
    Rake::Task["build"].invoke

  end

  desc "Runs rake release + bonethug:build"
  task :release do

    # handle path
    path = File.expand_path File.dirname(__FILE__) + '/../../pkg/bonethug-' + Bonethug::VERSION + '.gem'

    # check if there's a build with the current version
    Rake::Task["bonethug:build"].invoke

    # push the current version
    # we redefine the path because the version constant may have changed 
    # -> the reason being that the parent build script uses that constant to name the gem package
    exec "rake release"

  end

end