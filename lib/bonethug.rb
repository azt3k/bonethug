require "bonethug/version"
require "bonethug/installer"
require "bonethug/watcher"
require "bonethug/syncer"
require "bonethug/cli"

module Bonethug

  def self.increment_version

    version = VERSION.split('.')
    version[version.length-1] = (version.last.to_i + 1).to_s
    version = version.join('.') 

    remove_const 'VERSION'
    const_set 'VERSION', version

  end

end