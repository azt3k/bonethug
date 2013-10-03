require 'rubygems'
require 'bonethug/conf'

UnitecGraduationMicrosite::Application.configure do

  # load up the universal config
  cnf = Bonethug::Conf.new
  mail = cnf.get 'mail.postmark.development'

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Add the fonts path
  config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
  config.assets.paths << Rails.root.join('app', 'assets', 'images')
  config.assets.paths << Rails.root.join('app', 'assets', 'images', 'favicon')  
  config.assets.paths << Rails.root.join('vendor', 'assets', 'javascripts')
  config.assets.paths << Rails.root.join('vendor', 'assets', 'stylesheets')

  # Precompile additional assets
  config.assets.precompile += %w( .svg .eot .woff .ttf .otf .jpg .png .gif .ico modernizr.js lte-ie8-shims.js application.css application.js )   

  # mail conf
  config.mail_default_from = mail.get 'default_from.email'

  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  
  # config.action_mailer.delivery_method = :smtp  
  # config.action_mailer.smtp_settings = {
  #   :address              => mail.get('server'),
  #   :port                 => mail.get('port'),
  #   :domain               => mail.get('domain'),
  #   :user_name            => mail.get('user'),
  #   :password             => mail.get('pass'),
  #   :authentication       => 'plain',
  #   :enable_starttls_auto => mail.get('secure').to_s == 'tls' ? true : false
  # }

  config.action_mailer.default_url_options = { host: mail.get('default_url_options.host') }
  config.action_mailer.delivery_method = :postmark
  config.action_mailer.postmark_settings = { api_key: mail.get('postmark_settings.api_key') }
  config.action_mailer.asset_host = mail.get 'asset_host'
  
  # host for url helpers
  routes.default_url_options[:host] = cnf.get('apache.development.server_name')
  
end
