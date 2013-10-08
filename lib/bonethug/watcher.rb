# Todo
# ----------------
# - sass minification isn't working
# - actually add the filter to filter by type
# - make type filtering more flexible so other types can be used without code modifications
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

    def self.watch(type = 'coffee_sass', target = '.', watch_only = nil)

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
          sass.push(src: watch.get('src','Array'), dest: watch.get('dest'), filter: watch.get('filter'), type: :sass)
        end
      end

      coffee = []
      if coffees = conf.get('watch.coffee')
        coffees.each do |index, watch|
          coffee.push(src: watch.get('src','Array'), dest: watch.get('dest'), filter: watch.get('filter'), type: :coffee)
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
        
        case type
        when 'sprockets'
          guardfile_content += "
            guard 'sprockets', :minify => true, :destination => '#{watch[:dest]}', :asset_paths => #{watch[:src].to_s} do
              #{filter}
            end
          "
        when 'sass_coffee', 'coffee_sass'
          if watch[:type] == :coffee
            guardfile_content += "
              guard :coffeescript, :minify => true, :output => '#{watch[:dest]}', :input => #{watch[:src].to_s} do
                #{filter}
              end
            "
          elsif watch[:type] == :sass
            guardfile_content += "
              guard :sass, :style => :compressed, :debug_info => true, :output => '#{watch[:dest]}', :input => #{watch[:src].to_s} do
                #{filter}
              end
            "
          end
        end

      end

      # save the guardfile
      guardfile = target + '/.bonethug/Guardfile'
      FileUtils.rm_rf guardfile
      File.open(guardfile,'w') do |file| 
        file.puts guardfile_content 
      end

      puts 'Starting Watch Daemon...'
      exec 'bundle exec guard --guardfile "' + target + '/.bonethug/Guardfile"'

    end

  end

end