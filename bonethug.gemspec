# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bonethug/version'
require 'rbconfig'


Gem::Specification.new do |spec|

  spec.name          = "bonethug"
  spec.version       = Bonethug::VERSION
  spec.authors       = ["azt3k"]
  spec.email         = ["breaks.nz@gmail.com"]
  spec.description   = %q{Project Skeleton Manager}
  spec.summary       = %q{Bonethug}
  spec.homepage      = "https://github.com/azt3k/bonethug"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'mina'
  spec.add_dependency 'astrails-safe'
  spec.add_dependency 'whenever'

  # asset pipeline - guard coffeescript / sass
  spec.add_dependency 'rake'
  spec.add_dependency 'guard'
  spec.add_dependency 'coffee-script'
  spec.add_dependency 'sass'
  spec.add_dependency 'guard-sass'
  spec.add_dependency 'guard-coffeescript'
  spec.add_dependency 'listen'  

  # asset pipeline guard sprockets
  spec.add_dependency 'guard-sprockets'
  spec.add_dependency 'uglifier'
  spec.add_dependency 'sass-rails'
  spec.add_dependency 'coffee-rails'  

  # spec.add_dependency 'rb-fsevent'
  # spec.add_dependency 'compass'
  # spec.add_dependency 'guard-compass'
  # spec.add_dependency 'guard-process'
  # spec.add_dependency 'guard-livereload'
  # spec.add_dependency 'juicer'
  # spec.add_dependency 'guard-uglify'

  if RbConfig::CONFIG['target_os'] =~ /mswin|mingw/i
    spec.add_dependency 'wdm', '>= 0.1.0'
  end

  # if RUBY_PLATFORM.downcase.include?('linux')
  #   spec.add_dependency 'therubyracer'
  #   spec.add_dependency 'rb-inotify'    
  # end

  # if RUBY_PLATFORM.downcase.include?('darwin')
  #   spec.add_dependency 'rb-fsevent'
  #   spec.add_dependency 'terminal-notifier-guard'
  #   spec.add_dependency 'growl'
  # end

end
