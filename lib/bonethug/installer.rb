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

    @@bonthug_gem_dir = File.expand_path(File.dirname(__FILE__) + '/../..')
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
      unless @@conf.get('project_types').has_key? type.to_s
        puts "Unsupported type: " + type.to_s
        exit
      end
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

    # Prepares init db scripts
    # --------------------------

    def self.init_mysql_db_script(db, admin_user = 'root', admin_pass = '')

      script_content = "
        CREATE DATABASE IF NOT EXISTS " + db.get('name') + ";
        GRANT ALL ON " + db.get('name') + ".* TO " + db.get('user') + "@" + db.get('host') + (db.get('pass') ? " IDENTIFIED BY '" + db.get('pass') + "'" : "") + ";
        FLUSH PRIVILEGES;
      "
      cmd = 'echo "' + script_content + '" | mysql -h ' + db.get('host') + ' -u ' + admin_user + ' -p' + admin_pass

    end

    def self.execute_init_mysql_db_script(env, admin_user = 'root', admin_pass = '', path = '.')

      exec_path = File.expand_path(path)
      conf = Bonethug::Conf.new.add(exec_path + '/config/cnf.yml')
      conf.add(exec_path + '/config/database.yml' => { root: 'dbs.default' }) if File.exist? exec_path + '/config/database.yml'

      conf.get('dbs').each do |name,envs|

        db = envs.get env
        if !db
          puts "No db for env " + env + " found - check your config file"
          exit
        else
          puts "Mysql user " + admin_user + " is creating db: " + db.get('name') + " and granting access to " + db.get('user') + "@" + db.get('host') + ", you may be prompted for the password for the user: " + admin_user
          puts "NB: You may be affected by this bug if your admin user pass is longer than 8 chars: http://dev.mysql.com/doc/refman/5.0/en/password-too-long.html"
          system Bonethug::Installer.init_mysql_db_script(db, admin_user, admin_pass)
        end

      end

    end


    # Reads system setup scripts
    # --------------------------

    def self.get_setup_script(env)
      exec_path = File.expand_path(path)
      conf = Bonethug::Conf.new.add(exec_path + '/config/cnf.yml')
      deploy = conf.node_merge 'deploy.common','deploy.environments.' + env
      os_type = 'ubuntu'
      os_version = ''
      if os = deploy.get('os')
        os_type = os.get('type') if os.get('type')
        os_version = os.get('version') if os.get('version')
      end
      os_str = os_type + (os and os_version.to_s.length ? '-' + os_version.to_s : '')
      @@bonthug_gem_dir + '/scripts/' + os_str
    end

    def self.get_setup_script_content(env)
      File.read self.get_setup_script(env)
    end

    def self.get_setup_env_cmds
      self.parse_sh self.get_setup_script_content(env)
    end

    def self.parse_sh(content)
      content.split("\n").select { |line| !(line =~ /^[\s\t]+$/ || line =~ /^[\s\t]*#/ || line.strip.length == 0) }
    end

    # ---------
    # Protected
    # ---------

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

    def self.bonethugise(dir='.', mode=:init, stage=0)

      target = File.expand_path(dir)

      case stage
      when 0

        # get bonethug
        if mode == :update
          system 'bundle update bonethug'
        else
          system 'bundle init'
          system 'bundle install'
        end

        # kill this process and run the next step as a new process
        exec 'bundle exec thug ' + mode.to_s + ' ' + dir + ' ' + (stage + 1).to_s

      when 1

        # check for the existence of required dirs and create if required
        [target + '/.bonethug', target + '/config', target + '/config/example'].each do |path|
          FileUtils.mkdir path unless File.directory? path
        end

        # insert version file
        File.open(target + '/.bonethug/version','w') { |file| file.puts VERSION }

        # Handle config files
        @@project_config_files.each do |type, dirs|
          dirs.each do |config|

            # vars
            src_file      = @@bonthug_gem_dir + '/config/' + config
            example_file  = target + '/config/example/' + config if type == :editable
            target_file   = type == :editable ? target + '/config/' + config : target + '/.bonethug/' + config

            # output
            puts 'Handling ' + target_file

            # what mode are we in?
            if mode == :init
              FileUtils.cp src_file, example_file if type == :editable and !File.exist?(example_file)
              FileUtils.cp src_file, target_file unless File.exist?(target_file)
            elsif mode == :update
              FileUtils.cp src_file, example_file if type == :editable
              FileUtils.cp src_file, target_file if type == :generated or !File.exist?(target_file)
            else
              puts "Invalid bonethugise mode"
              exit
            end

          end
        end

        # Handle project type specific files
        if mode == :update
          target_cnf = target + '/config/cnf.yml'
          project_conf = Conf.new.add target_cnf
          project_type = project_conf.get('deploy.common.project_type')
          if project_type
            bonethug_files = @@conf.get 'project_types.' + project_type + '.bonethug_files'
            if bonethug_files
              bonethug_files.each do |index, file|

                # push some output
                puts 'Handling ' + index.to_s + ':' + file.to_s

                # do the copy
                src_file =  @@bonthug_gem_dir + '/skel/project_types/' + project_type + '/' + file
                dst_file = target + '/' + file
                dir = File.dirname dst_file
                FileUtils.mkdir_p dir
                FileUtils.cp_r src_file, dst_file

              end
            end
          else
            puts "Couldn't find project type in " + target_cnf
          end
        end

        # handle gemfile
        gemfile_path = target + '/Gemfile'
        if File.exist? gemfile_path

          # extract the contents
          gemfile_contents = File.read(gemfile_path)

          # identify what we are looking for
          # this should have groups - i.e. dev
          required_gems = {
            'mina'              => 'nadarei/mina',
            'astrails-safe'     => 'astrails/safe',
            'whenever'          => 'javan/whenever',
            'guard-erb'         => 'azt3k/guard-erb',
            'coffee-script'     => 'josh/ruby-coffee-script',
            'guard-uglify'      => 'pferdefleisch/guard-uglify',
            'guard-concat'      => 'makevoid/guard-concat',
            'bonethug'          => nil
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
        exec 'bundle install'

      end

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