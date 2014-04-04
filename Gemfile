require 'rbconfig'

source 'https://rubygems.org'

# Specify your gem's dependencies in bonethug.gemspec
# ---------------------------------------------------

gemspec

# Lets respecify just in case
# ---------------------------

gem 'rake'
gem 'rubygems-bundler'

# tell bundler to get stuff from git hub
gem 'mina',             github: 'nadarei/mina'
gem 'astrails-safe',    github: 'astrails/safe'
gem 'whenever',         github: 'javan/whenever'

# guard
if RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwin/i
  gem 'wdm', '>= 0.1.0'
  gem 'guard', '>= 1.8.3', '< 2.0'
  gem 'listen', '~> 1.3'
else
  gem 'guard', '>=2.5.1'
  gem 'listen', '>=2.6.2'
end

# asset pipeline - guard sprockets
gem 'guard-sprockets', github: 'dormi/guard-sprockets'
gem 'sass-rails'
gem 'coffee-rails'

# asset pipeline - guard not sprockets
gem 'coffee-script', github: 'josh/ruby-coffee-script'
gem 'uglifier'
gem 'sass'
gem 'guard-sass'
gem 'guard-coffeescript', '1.3.4'
gem 'guard-erb'
gem 'guard-slim'
gem 'guard-uglify', github: 'customink/guard-uglify'
gem 'guard-concat', github: 'mikz/guard-concat'
gem 'guard-livereload'

# if RUBY_PLATFORM.downcase.include?('linux')
#   gem 'therubyracer'
# end

# if RUBY_PLATFORM.downcase.include?('darwin')
#   gem 'rb-fsevent'
#   gem 'terminal-notifier-guard'
#   gem 'growl'
# end