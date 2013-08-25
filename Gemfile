require 'rbconfig'

source 'https://rubygems.org'

# Specify your gem's dependencies in bonethug.gemspec
gemspec

# tell bundler to get stuff from git hub
gem 'mina',             github: 'nadarei/mina'
gem 'astrails-safe',    github: 'astrails/safe'
gem 'whenever',         github: 'javan/whenever'

# gem 'sass',             github: 'nex3/sass'
# gem 'coffee-script',    github: 'jashkenas/coffee-script'

gem 'guard-sprockets',  github: 'dormi/guard-sprockets' 
gem 'uglifier'

# gem 'less'
# gem 'sass-rails'
# gem 'execjs'

if RbConfig::CONFIG['target_os'] =~ /mswin|mingw/i
  gem 'wdm', '>= 0.1.0'
end

# if RUBY_PLATFORM.downcase.include?('linux')
#   gem 'therubyracer' 
#   gem 'rb-inotify'
# end

# if RUBY_PLATFORM.downcase.include?('darwin')
#   gem 'rb-fsevent'
#   gem 'terminal-notifier-guard'
#   gem 'growl'
# end