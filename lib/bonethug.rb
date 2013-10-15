require "bonethug/version"
require "bonethug/installer"
require "bonethug/watcher"
require "bonethug/cli"

module Bonethug

  def self.update_version(value)
    remove_const 'VERSION'
    const_set 'VERSION', value
  end

end