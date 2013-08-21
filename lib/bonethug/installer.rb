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

  class Installer

    include FileUtils
    include Digest

    @@skel_dir = File.expand_path(File.dirname(__FILE__)) + '/../../skel'
    @@conf = Conf.new.add(@@skel_dir + '/skel.yml')
    @@project_config_files = ['backup.rb','cnf.yml','deploy.rb','schedule.rb']

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
      FileUtils.cp_r @@skel_dir + '/project_types/' + type + '/.', tmp_dir
      FileUtils.cp_r @@skel_dir + '/base/.', tmp_dir

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
      puts 'Updating configs...'
      self.update_configuration_files(target)

      # try to update the configuration files
      puts 'Updating build informtation...'
      self.save_project_meta_data(target)

      # clean up any exisitng install tmp files
      puts 'Cleaning up temporary files...'
      FileUtils.rm_rf tmp_dir     

      puts "Installation Complete"

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
      manifest = dir_contents - ((@@conf.get('exlcuded_paths') || []).map { |p| File.expand_path(p) })
      File.open(dir + '/.bonethug/manifest','w') { |file| file.puts manifest.join("\n") }
      self
    end

    def self.update_configuration_files(target)

      # load the existing project's datafile if present
      meta_data = self.get_project_meta_data target      
      
      @@project_config_files.each do |config|

        do_copy       = true
        example_file  = target + '/config/example/' + config
        target_file   = target + '/config/' + config

        # analyse the config file + build data file
        file_exists           = File.exist?(target_file)
        contents_not_modified = false
        contents_not_modified = true if file_exists and meta_data and meta_data['config_digests'] and meta_data['config_digests']['example/' + config] == self.contents_md5(target_file) 

        # meta_data_is_hash     = meta_data_exists and meta_data.class.name == 'Hash' and meta_data['config_digests'].class.name == 'Hash'
        # config_digests_found  = meta_data_is_hash and meta_data['config_digests'].methods.include?('has_key?') and meta_data['config_digests'].has_key?('example/' + config)
        # contents_not_modified = config_digests_found and meta_data['config_digests']['example/' + config] == self.contents_md5(target_file)

        # don't copy if the file exists...
        do_copy = false if file_exists

        # unless it hasn't been modified, i.e. probably not conf.yml, but possibly some of the other ones

        do_copy = true if contents_not_modified

        # Copy if that's ok
        FileUtils.cp example_file, target_file if do_copy

      end

      # return self for chaining
      self

    end

    def self.contents_md5(file)
      return false unless File.exist?(file)
      MD5.digest File.read(file)
    end

    def self.save_project_meta_data(base_dir)

      meta_data = {'config_digests' => {}}
      @@project_config_files.each do |file| 
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
  end

end