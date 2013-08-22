# Todo
# ----------------
# - Have some sort of safe vs forced install - tie in with exlcuded paths
# - Check that excluded paths is working in manifest
# ----------------

require File.expand_path(File.dirname(__FILE__)) + '/../../skel/base/lib/conf'
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
      conf.get('watch.sass').each do |watch|
        sass.push {src: watch.get('src'), dest: watch.get('dest')}
      end

      coffee = []
      conf.get('watch.coffee').each do |watch|
        coffee.push {src: watch.get('src'), dest: watch.get('dest')}
      end

      puts 'Starting Watch Daemons...'

      # sass compiler
      sass_watch_str = ''
      sass.each do |watch|
        sass_watch_str += ' '+watch[:src]+':'+watch[:dest]
      end
      sass_cmd = "sass --watch #{sass_watch_str} --style compressed"
      
      # Coffescript compiler
      coffee_watch_str = ''
      coffee.each do |watch|
        coffee_watch_str += ' && coffee -o '+watch[:dest]+'/ -cw '+watch[:src]+'/'
      end
      coffee_cmd = coffee_watch_str

      # call it
      log = `#{sass_cmd} #{coffee_cmd}` 

    end

end