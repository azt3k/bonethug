require 'rake'

namespace :setup

  desc "setup ss3.1-dev project"
  task :silverstripe31dev => :environment do
    puts "just pretending"
  end

  desc "setup silverstripe 3 project"
  task :silverstripe => :environment do
    invoke :'setup:silverstripe31dev'
  end

end