# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# pass the path to the script
env :PATH, ENV['PATH']

# base path to this release
base_path = File.expand_path(File.dirname(__FILE__))+"/../../../current"

# log files
set :output, {:error => base_path+'/log/cron_error.log', :standard => base_path+'/log/cron.log'}

# actual jobs
every 1.day, :at => '11 pm' do
  command "cd #{base_path} && export to=#{@environment} && bundle exec astrails-safe config/backup.rb"
end