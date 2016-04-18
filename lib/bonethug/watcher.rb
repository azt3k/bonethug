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
require 'rbconfig'

module Bonethug

class Watcher

  include FileUtils
  include Digest

  def self.watch(type = nil, target = '.', watch_only = nil)

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
        sass.push(src: watch.get('src','Array'), dest: watch.get('dest'), filter: watch.get('filter'), all_on_start: watch.get('onstart').to_bool, type: :sass)
      end
    end

    coffee = []
    if coffees = conf.get('watch.coffee')
      coffees.each do |index, watch|
        coffee.push(src: watch.get('src','Array'), dest: watch.get('dest'), filter: watch.get('filter'), all_on_start: watch.get('onstart').to_bool, type: :coffee)
      end
    end

    # concat doesn't support array based input just yet
    concat_js = []
    if js_concats = conf.get('watch.concat_js')
      js_concats.each do |index, watch|
        concat_js.push(src: watch.get('src'), dest: watch.get('dest'), filter: watch.get('filter','Array'), all_on_start: watch.get('onstart').to_bool, type: :concat_js)
      end
    end

    # concat doesn't support array based input just yet
    concat_css = []
    if css_concats = conf.get('watch.concat_css')
      css_concats.each do |index, watch|
        concat_css.push(src: watch.get('src'), dest: watch.get('dest'), filter: watch.get('filter','Array'), all_on_start: watch.get('onstart').to_bool, type: :concat_css)
      end
    end

    # uglify doesn't support array based input just yet
    uglify = []
    if uglifies = conf.get('watch.uglify')
      uglifies.each do |index, watch|
        uglify.push(src: watch.get('src'), dest: watch.get('dest'), filter: watch.get('filter'), all_on_start: watch.get('onstart').to_bool, type: :uglify)
      end
    end

    # erb doesn't support array based input just yet
    erb = []
    if erbs = conf.get('watch.erb')
      erbs.each do |index, watch|
        erb.push(src: watch.get('src','Array'), dest: watch.get('dest'), filter: watch.get('filter'), all_on_start: watch.get('onstart').to_bool, type: :erb)
      end
    end

    # slim doesn't support aray based inputs just yet
    slim = []
    if slims = conf.get('watch.slim')
      slims.each do |index, watch|
        slim.push(src: watch.get('src','Array'), dest: watch.get('dest'), filter: watch.get('filter'), all_on_start: watch.get('onstart').to_bool, type: :slim)
      end
    end

    # combine the watches
    watches = coffee + sass + concat_js + concat_css + uglify + erb + slim

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
      when 'Array'
        watch_val = "%w(#{watch[:filter].join(' ')})"
      else
        raise "invalid filter type: " + watch[:filter].class.name
      end

      if watch[:filter].class.name == 'Array'
        filter = watch_val
      else
        filter = watch[:filter] ? "watch #{watch_val}" : ""
      end

      case type
      when 'sprockets'
        guardfile_content += "
          guard 'sprockets', :minify => true, :destination => '#{watch[:dest]}', :asset_paths => #{watch[:src].to_s}, :all_on_start => #{watch[:all_on_start].to_s} do
            #{filter}
          end
        "
      else
        if watch[:type] == :coffee
          guardfile_content += "
            coffeescript_options = {
              input: '#{watch[:src].to_s}',
              output: '#{watch[:dest]}',
              all_on_start: #{watch[:all_on_start].to_s},
              patterns: [#{watch_val.to_s}]
            }

            guard 'coffeescript', coffeescript_options do
              coffeescript_options[:patterns].each { |pattern| watch(pattern) }
            end
          "
        elsif watch[:type] == :sass
          guardfile_content += "
            guard :sass, :style => :compressed, :debug_info => true, :output => '#{watch[:dest]}', :input => #{watch[:src].to_s}, :all_on_start => #{watch[:all_on_start].to_s} do
              #{filter}
            end
          "
        elsif watch[:type] == :concat_css
          guardfile_content += "
            guard :concat, :output => '#{watch[:dest]}', :input_dir => '#{watch[:src]}', :type => 'css', :files => #{filter}, :all_on_start => #{watch[:all_on_start].to_s}
          "
        elsif watch[:type] == :concat_js
          guardfile_content += "
            guard :concat, :output => '#{watch[:dest]}', :input_dir => '#{watch[:src]}', :type => 'js', :files => #{filter}, :all_on_start => #{watch[:all_on_start].to_s}
          "
        elsif watch[:type] == :uglify
          guardfile_content += "
            guard 'uglify', :output => '#{watch[:dest]}', :input => '#{watch[:src].to_s}', :all_on_start => #{watch[:all_on_start].to_s} do
              #{filter}
            end
          "
        elsif watch[:type] == :erb
          guardfile_content += "
            guard :erb, :debug_info => true, :output => '#{watch[:dest]}', :input => #{watch[:src].to_s}, :all_on_start => #{watch[:all_on_start].to_s} do
              #{filter}
            end
          "
        elsif watch[:type] == :slim
          guardfile_content += "
            guard :slim, :debug_info => true, :output => '#{watch[:dest]}', :input => #{watch[:src].to_s}, :all_on_start => #{watch[:all_on_start].to_s} do
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
    # guard 2.0.x polling fix
    # poll = RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwin/i ? '--force-polling' : ''
    poll = ''
    cmd = 'bundle exec guard --debug ' + poll + ' --guardfile "' + target + '/.bonethug/Guardfile"'
    puts cmd
    exec cmd

  end

end

end
