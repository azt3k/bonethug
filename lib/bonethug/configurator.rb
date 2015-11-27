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

      conf = @@conf.get 'project_types.' + project_type

      # server aliases
      server_aliases = ''
      aliases = vh_cnf.get 'server_aliases'
      if aliases
        aliases.each do |index, server_alias|
          server_aliases += 'ServerAlias ' + server_alias + "\n"
        end
      end

      # environment variables
      env_vars = 'SetEnv ' + conf.get('env_var') + ' ' + env + "\n"
      vars = vh_cnf.get 'env_vars'
      if vars
        vars.each do |k, v|
          env_vars += 'SetEnv ' + k + ' ' + v + "\n"
        end
      end

      # server admin
      admin = vh_cnf.get 'server_admin'
      server_admin = admin ? 'ServerAdmin ' + admin : ''

      # paths
      shared_path = is_remote ? '/shared' : ''
      current_path = is_remote ? '/current' : ''

      # ssl key
      ssl_key = vh_cnf.get 'ssl_key'
      ssl_key = base_path + current_path + '/' + ssl_key if ssl_key and ssl_key[0...0] != '/'

      # ssl crt
      ssl_crt = vh_cnf.get 'ssl_crt'
      ssl_crt = base_path + current_path + '/' + ssl_crt if ssl_crt and ssl_crt[0...0] != '/'

      custom = vh_cnf.get 'custom'
      custom_str = ''
      if custom
        custom.each do |k, v|
          custom_str += v + "\n"
        end
      end

      # ssl crt
      ssl_ca_bundle = vh_cnf.get 'ssl_ca_bundle'
      ssl_ca_bundle = base_path + current_path + '/' + ssl_ca_bundle if ssl_ca_bundle and ssl_ca_bundle[0...0] != '/'
      ca_str = ssl_ca_bundle ? 'SSLCertificateChainFile ' + ssl_ca_bundle : ''

      case vh_cnf.get('type')

      when "nginx"

        vh = ""

      else # apache

        access = vh_cnf.get('version').to_f >= 2.4 ? "Require all granted" : "Order allow,deny\nAllow from all"
        port = vh_cnf.get('port') || 80
        ssl_port = vh_cnf.get('ssl_port') || 443

        vh = "
          <VirtualHost *:#{port.to_s}>

            ServerName  #{vh_cnf.get('server_name')}
            #{server_aliases}

            #{server_admin}

            DocumentRoot #{base_path + current_path}/public

            #{env_vars}
            PassEnv PATH

            #{custom_str}

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

        if ssl_key and ssl_crt

          vh += "
            <VirtualHost *:#{ssl_port.to_s}>

              ServerName  #{vh_cnf.get('server_name')}
              #{server_aliases}

              #{server_admin}

              DocumentRoot #{base_path + current_path}/public

              #{env_vars}
              PassEnv PATH

              SSLEngine on
              SSLCertificateFile #{ssl_crt}
              SSLCertificateKeyFile #{ssl_key}
              #{ca_str}

              #{custom_str}

              CustomLog #{base_path + shared_path}/log/bytes.log bytes
              CustomLog #{base_path + shared_path}/log/combined.log combined
              ErrorLog  #{base_path + shared_path}/log/error.log

              <Directory #{base_path + current_path}/public>

                SSLOptions +StdEnvVars
                Options Indexes MultiViews FollowSymLinks
                AllowOverride All
                #{access}

              </Directory>

              BrowserMatch \"MSIE [2-6]\" \
                              nokeepalive ssl-unclean-shutdown \
                              downgrade-1.0 force-response-1.0
              BrowserMatch \"MSIE [17-9]\" ssl-unclean-shutdown

            </VirtualHost>
          "

        end
      end

      vh

    end

  end

end
