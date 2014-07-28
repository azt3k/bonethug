# Class for generating configurations

require 'bonethug/conf'
require 'fileutils'
require 'find'
require 'digest/md5'
require 'yaml'
require 'rbconfig'

module Bonethug

  class Configurator

    include FileUtils
    include Digest

    @@bonthug_gem_dir = File.expand_path File.dirname(__FILE__) + '/../..'
    @@skel_dir = @@bonthug_gem_dir + '/skel'
    @@conf = Conf.new.add @@skel_dir + '/skel.yml'

    def self.hosts(vh_cnf)
      hosts = "127.0.0.1 #{vh_cnf.get('server_name')}\n"
      aliases = vh_cnf.get('server_aliases')
      if aliases
        aliases.each do |index, server_alias|
          hosts += "127.0.0.1 #{server_alias}\n"
        end
      end
      hosts
    end

    def self.vhost(vh_cnf, base_path, project_type, env = 'development', is_remote = false)

      conf = @@conf.get project_type

      # server aliases
      server_aliases = ''
      aliases = vh_cnf.get('server_aliases')
      if aliases
        aliases.each do |index, server_alias|
          server_aliases += 'ServerAlias ' + server_alias + "\n"
        end
      end

      # environment variables
      env_vars = 'SetEnv ' + conf.get('env_var') + ' ' + env + "\n"
      vars = vh_cnf.get('env_vars')
      if vars
        vars.each do |k, v|
          env_vars += 'SetEnv ' + k + ' ' + v + "\n"
        end
      end

      # server admin
      admin = vh_cnf.get('server_admin')
      server_admin = admin ? 'ServerAdmin ' + admin : ''

      # paths
      shared_path = is_remote ? '/shared' : ''
      current_path = is_remote ? '/current' : ''

      case vh_cnf.get('type')

      when "nginx"

        vh = ""

      else # apache

        access = vh_cnf.get('version').to_f >= 2.4 ? "Require all granted" : "Order allow,deny\nAllow from all"

        vh = "
          <VirtualHost *:80>

            ServerName  #{vh_cnf.get('server_name')}
            #{server_aliases}

            #{server_admin}

            DocumentRoot #{base_path + current_path}/public

            #{env_vars}
            PassEnv PATH

            CustomLog #{base_path + shared_path}/log/bytes.log bytes
            CustomLog #{base_path + shared_path}/log/combined.log combined
            ErrorLog  #{base_path + shared_path}/log/error.log

            <Directory #{base_path + current_path}/public>

              Options Indexes MultiViews FollowSymLinks
              AllowOverride All
              #{access}

            </Directory>

          </VirtualHost>
        "
      end

      vh

    end

  end

end