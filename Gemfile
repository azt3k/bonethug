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
gem 'guard', '>= 1.8.3', '< 2.0' # '>=2.0.5'
gem 'listen', github: 'guard/listen'

# asset pipeline - guard sprockets
gem 'guard-sprockets',  github: 'dormi/guard-sprockets' 
gem 'uglifier'
gem 'sass-rails'
gem 'coffee-rails'

# asset pipeline - guard not sprockets
gem 'coffee-script'
gem 'sass'
gem 'guard-sass'
gem 'guard-coffeescript'
gem 'guard-erb'
gem 'guard-slim'
gem 'guard-livereload'

gem 'wdm', '>= 0.1.0' if RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwin/i

# if RUBY_PLATFORM.downcase.include?('linux')
#   gem 'therubyracer'
# end

# if RUBY_PLATFORM.downcase.include?('darwin')
#   gem 'rb-fsevent'
#   gem 'terminal-notifier-guard'
#   gem 'growl'
# end