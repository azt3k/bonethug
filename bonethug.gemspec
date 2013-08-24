# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bonethug/version'

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
  # spec.add_dependency 'sass'
  # spec.add_dependency 'coffee-script'
  spec.add_dependency 'guard-sprockets'   

end
