require File.expand_path(File.dirname(__FILE__)) + '/../../skel/base/lib/conf'

module Bonethug

  class Installer

    include 'fileutils'

    @@skel_dir = File.expand_path(File.dirname(__FILE__)) + '/../../skel'
    @@conf = Conf.new.add(@@skel_dir + '/skel.yml')

    def self.install(type, target = '.')

      # create fill path
      target = File.expand_path target

      # let the user know we are installing
      puts 'Installing '+ type + ' to ' + target

      # load the configuration
      raise "Unsupported type: " + type.to_s unless @conf.get('project_types').has_key? type.to_s
      conf = @@conf.node_merge 'base', 'project_types.' + type

      # create a tmp dir
      tmp_dir = File.expand_path target + '/.bonethug-tmp'
      mkdir tmp_dir

      # build the file set
      cp @@skel_dir + '/base', tmp_dir
      cp @@skel_dir + '/project_types/' + type, tmp_dir

      # build the manifest
      self.build_manifest tmp_dir

      # clean up the target dir
      self.clean target

      # copy the files
      cp_r tmp_dir, target

      # remove tmp dir
      rm_rf tmp_dir

      puts "Done"

    end

    def self.clean(target)
      manifest = File.read(target + '/.bonethug-manifest').split("\n")
      manifest.each { |file| rm_rf file }
      self
    end

    protected

    def self.build_manifest(dir)
      manifest = Dir.glob(dir + "/*") - (@@conf.get('exlcuded_paths') || []).map { |p| File.expand_path(p) }
      File.open(dir + '/.bonethug-manifest','w') { |file| file.puts manifest.join("\n") }
      self
    end    
      
  end

end