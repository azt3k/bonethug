# Todo
# ----------------
# - Have some sort of safe vs forced install - tie in with exlcuded paths
# - Check that excluded paths is working in manifest
# - bonethug init seems doesn't seem to update gemfile if there is one
# - Gemfile, .gitignore, composer.json need to be no go zones
# - for rails it should copy the gem file call bundle install, do a cleanup then call bundle exec rails new application_name
# ----------------

require 'rubygems'
require 'bonethug/conf'
require 'fileutils'
require 'find'
require 'digest/md5'
require 'yaml'

module Bonethug

  class Installer

    include FileUtils
    include Digest

    @@bonthug_gem_dir = File.expand_path(File.dirname(__FILE__)) + '/../..'
    @@skel_dir = @@bonthug_gem_dir + '/skel'
    @@conf = Conf.new.add(@@skel_dir + '/skel.yml')
    @@project_config_files = {editable: ['cnf.yml','schedule.rb'], generated: ['backup.rb','deploy.rb']}

    def self.install(type, target = '.')

      # @@conf = Conf.new.add(@@skel_dir + '/skel.yml')

      # create full path
      target = File.expand_path target

      # let the user know we are installing
      puts 'Installing '+ type + ' to ' + target + '...'

      # load the configuration
      raise "Unsupported type: " + type.to_s unless @@conf.get('project_types').has_key? type.to_s
      conf = @@conf.node_merge 'base', 'project_types.' + type

      # set the tmp dir
      tmp_dir = File.expand_path target + '/.bonethug-tmp'

      # clean up any exisitng install tmp files
      if File.directory? tmp_dir
        puts 'Cleaning up old installer temporary files...'
        FileUtils.rm_rf tmp_dir
      end

      # create tmp dir
      puts 'Creating build directory at ' + tmp_dir
      FileUtils.mkdir tmp_dir
      FileUtils.mkdir tmp_dir + '/.bonethug'

      # build the file set
      puts 'Building ' + type + ' skeleton...'
      FileUtils.cp_r @@skel_dir + '/base/.', tmp_dir      
      FileUtils.cp_r @@skel_dir + '/project_types/' + type + '/.', tmp_dir

      # build the manifest
      puts 'Creating manifest...'
      self.build_manifest tmp_dir

      # modify the manifest root
      manifest_path = tmp_dir + '/.bonethug/manifest'
      File.open(manifest_path,'w') do |file| 
        file.puts File.read(manifest_path).gsub(/\.bonethug-tmp/,'') 
      end

      # clean up the target dir
      puts 'Cleaning up install directory...'
      self.clean target

      # copy the files
      puts 'Installing build to ' + target + '...'
      FileUtils.cp_r tmp_dir + '/.', target

      # try to update the configuration files
      puts 'Updating build informtation...'
      self.save_project_meta_data(target)

      # clean up any exisitng install tmp files
      puts 'Cleaning up temporary files...'
      FileUtils.rm_rf tmp_dir  

      puts "Installation Complete"

      # try to update the configuration files
      puts 'Updating configs...'
      self.bonethugise(target, :init)      

    end

    def self.clean(target)

      manifest_path = target + '/.bonethug/manifest'

      if File.exists? manifest_path
        
        puts 'Reading manifest...'
        manifest = File.read(manifest_path).split("\n")
        
        puts 'Cleaning up ' + manifest.count.to_s + ' files'
        not_removed = []
        manifest.each do |file|
          not_removed.push file unless self.try_delete file
        end

        if not_removed.count > 0

          puts 'Retrying removal of ' + not_removed.count.to_s + ' files'
          failed = []
          not_removed.each do |file|
            failed.push file unless self.try_delete file
          end

          puts 'Removal of the following' + failed.count.to_s + ' files failed'
          puts failed.join("\n")

        end 

      else
        puts 'Nothing to do'
      end
      self
    end

    protected

    def self.try_delete(file)
      if (File.directory?(file) and Find.find(file).empty?) or File.file?(file)
        rm_rf file
        return false if File.exists? file
        return true
      else
        return false
      end
    end

    def self.build_manifest(dir)
      dir_contents = Find.find(dir).map { |p| File.expand_path(p) }
      manifest = dir_contents - ((@@conf.get('exlcuded_paths','Array') || []).map { |p| File.expand_path(p) })
      File.open(dir + '/.bonethug/manifest','w') { |file| file.puts manifest.join("\n") }
      self
    end

    def self.contents_md5(file)
      return false unless File.exist?(file)
      MD5.digest File.read(file)
    end

    def self.save_project_meta_data(base_dir)

      meta_data = {'config_digests' => {}}
      @@project_config_files[:editable].each do |file| 
        meta_data['config_digests']['example/' + file] = self.contents_md5(base_dir + '/config/example/' + file)
      end
      File.open(base_dir + '/.bonethug/data','w') { |file| file.puts meta_data.to_yaml }

      # return self for chaining
      self

    end

    def self.get_project_meta_data(base_dir)

      data_file = base_dir + '/.bonethug/data'
      return YAML.load_file data_file if File.exists? data_file
      return false

    end

    # mode == :init
    # copy cnf.yml + schedule.rb to config if possible
    # copy cnf.yml + schedule.rb to config/example if possible
    # copy backup.rb and deploy.rb to .bonethug if possible
    # add bonethug to gemfile if required
    # run bundle install      

    # mode == :update
    # copy cnf.yml + schedule.rb to config if possible
    # force copy cnf.yml + schedule.rb to config/example 
    # force copy backup.rb and deploy.rb to .bonethug
    # add bonethug to gemfile if required
    # run bundle install 

    def self.bonethugise(dir='.', mode=:init)

      target = File.expand_path(dir)

      # check for the existence of required dirs and create if required
      [target + '/.bonethug', target + '/config', target + '/config/example'].each do |path|
        FileUtils.mkdir path unless File.directory? path
      end

      # Handle config files
      @@project_config_files.each do |type, dirs|
        dirs.each do |config|

          src_file      = @@bonthug_gem_dir + '/config/' + config
          example_file  = target + '/config/example/' + config if type == :editable
          target_file   = type == :editable ? target + '/config/' + config : target + '/.bonethug/' + config

          if mode == :init
            FileUtils.cp src_file, example_file if type == :editable and !File.exist?(example_file)
            FileUtils.cp src_file, target_file unless File.exist?(target_file)
          elsif mode == :update
            FileUtils.cp src_file, example_file if type == :editable
            FileUtils.cp src_file, target_file if type == :generated or !File.exist?(target_file)          
          else
            raise "invalid bonethugise mode"
          end

        end
      end

      # handle gemfile
      gemfile_path = target + '/Gemfile'
      if File.exist? gemfile_path

        # extract the contents
        gemfile_contents = File.read(gemfile_path)

        # identify what we are looking for
        required_gems = {
          'mina'          => 'nadarei/mina',
          'astrails-safe' => 'astrails/safe',
          'whenever'      => 'javan/whenever',
          'bonethug'      => nil
        }

        # look at each requirement and identify if we need things
        required_gems.each do |gem_name, github|

          add_gem = false;
          gem_reg = Regexp.new('gem[^"\']+["\']'+gem_name+'["\']')
          git_reg = Regexp.new('gem[^"\']+["\']'+gem_name+'["\'],[^,]+github: ["\']'+github+'["\']') if github

          if gem_reg =~ gemfile_contents
            puts 'Found '+gem_name+' in gem file.'
            if github 
              puts 'Requires github version, checking...'
              unless git_reg =~ gemfile_contents
                puts 'Couldn\'t find '+gem_name+' (github) in gem file adding...'
                gemfile_contents.gsub(gem_reg,'')
                add_gem = true;
              end
            end
          else
            puts "Couldn't find "+gem_name+" in gem file adding..."
            add_gem = true;
          end

          if add_gem
            gemfile_contents += "\n" + 'gem "'+gem_name+'"'+(github ? ', github: "'+github+'"' : '') 
            File.open(gemfile_path,'w') { |file| file.puts gemfile_contents }
          end

        end

      else
        puts 'No Gemfile found, creating one...'
        FileUtils.cp @@skel_dir + '/base/Gemfile', gemfile_path
      end

      # run bundler
      exec 'bundle install --path vendor --binstubs' + (mode == :update ? ' && bundle update bonethug' : '')

      # self

    end

    def self.update(dir = '.')
      self.bonethugise(dir,:update)
    end

    def self.init(dir = '.')
      self.bonethugise(dir,:init)
    end  

  end

end