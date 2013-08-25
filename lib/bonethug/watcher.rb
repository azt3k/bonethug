# Todo
# ----------------
# - Have some sort of safe vs forced install - tie in with exlcuded paths
# - Check that excluded paths is working in manifest
# ----------------

require 'bonethug/conf'
require 'fileutils'
require 'find'
require 'digest/md5'
require 'yaml'

module Bonethug

  class Watcher

    include FileUtils
    include Digest

    def self.watch(type = 'all', target = '.')

      # create full path
      target = File.expand_path target

      # load config
      puts "Parsing Config..."
      unless conf = Conf.new.add(target + '/config/cnf.yml')
        puts "Couldn't find project configuration"
        return
      end

      # project type
      project_type = conf.get('deploy.project_type')

      # end now if its a rails project
      if ['rails','rails3'].include? project_type
        puts "Rails doesn't require watching"
        return
      end

      sass = []
      if sasses = conf.get('watch.sass')
        sasses.each do |index, watch|
          sass.push(src: watch.get('src','Array'), dest: watch.get('dest'), filter: watch.get('filter'))
        end
      end

      coffee = []
      if coffees = conf.get('watch.coffee')
        coffees.each do |index, watch|
          coffee.push(src: watch.get('src','Array'), dest: watch.get('dest'), filter: watch.get('filter'))
        end
      end

      # combine the watches
      watches = coffee + sass

      # Generate Guardfile
      puts 'Generating Guardfile...'

      guardfile_content = ''
      watches.each do |watch|

        case watch[:filter].class.name
        when 'NilClass'
          watch_val = ''
        when 'String'
          watch_val = "'#{watch[:filter]}'"
        when 'Regexp'
          watch_val = watch[:filter].inspect
        else
          raise "invalid filter type: " + watch[:filter].class.name
        end

        filter = watch[:filter] ? "watch #{watch_val}" : ""
        guardfile_content += "
          guard 'sprockets', :minify => true, :destination => '#{watch[:dest]}', :asset_paths => #{watch[:src].to_s} do
            #{filter}
          end
        "
      end

      # save the guardfile
      guardfile = target + '/.bonethug/Guardfile'
      FileUtils.rm_rf guardfile
      File.open(guardfile,'w') do |file| 
        file.puts guardfile_content 
      end

      puts 'Starting Watch Daemon...'
      # puts "Guardfile content "
      # puts guardfile_content
      cmd = 'bundle exec guard --guardfile ' + target + '/.bonethug/Guardfile'
      # puts "calling: " + cmd
      exec cmd

      # puts 'Starting Watch Daemons...'
      # puts 'This may start more than one watch process and you may have to ctrl + c more than once to quit.'

      # # sass compiler
      # sass_watch_str = ''
      # sass.each do |watch|
      #   sass_watch_str += ' '+watch[:src]+':'+watch[:dest]
      # end
      # sass_cmd = "sass --watch #{sass_watch_str} --style compressed"
      
      # # Coffescript compiler
      # coffee_watch_str = ''
      # coffee.each do |watch|
      #   coffee_watch_str += ' && coffee -o '+watch[:dest]+'/ -cw '+watch[:src]+'/'
      # end
      # coffee_cmd = coffee_watch_str

      # # call it
      # cmd = "#{sass_cmd} #{coffee_cmd}"
      # puts "Running: " + cmd
      
      # log = `#{cmd}` 

    end

  end

end