require 'rbconfig'

source 'https://rubygems.org'

# Specify your gem's dependencies in bonethug.gemspec
gemspec

# tell bundler to get stuff from git hub
gem 'mina',             github: 'nadarei/mina'
gem 'astrails-safe',    github: 'astrails/safe'
gem 'whenever',         github: 'javan/whenever'

# asset pipeline - guard sprockets
gem 'guard-sprockets',  github: 'dormi/guard-sprockets' 
gem 'uglifier'
gem 'sass-rails'
gem 'coffee-rails'

# asset pipeline - guard coffeescript / sass
# gem 'rake'
# gem 'guard'
# gem 'coffee-script'
# gem 'sass'
# gem 'guard-sass'
# gem 'guard-coffeescript'
# gem 'listen'

if RbConfig::CONFIG['target_os'] =~ /mswin|mingw/i
  gem 'wdm', '>= 0.1.0'
end

# if RUBY_PLATFORM.downcase.include?('linux')
#   gem 'therubyracer'
# end

# if RUBY_PLATFORM.downcase.include?('darwin')
#   gem 'rb-fsevent'
#   gem 'terminal-notifier-guard'
#   gem 'growl'
# end