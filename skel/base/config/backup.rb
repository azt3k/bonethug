# astrails-safe config file - you can generate a template with
# bundle exec astrails-safe CONFIG_FILE
# more info: https://github.com/astrails/safe

# Load some data
# --------------------------------

# get some info about the environemnt
exec_path   = File.expand_path(File.dirname(__FILE__))
env         = ENV['to']

# load config
require exec_path + '/lib/conf'
conf = Conf.new.add(exec_path + '/config/cnf.yml').add(exec_path + '/config/database.yml' => { root: 'dbs.default' })

# do a check
raise 'could not find deployment environment' unless conf.get('deploy.environments').has_key? env

# process config
deploy      = conf.node_merge('deploy.common','deploy.environments.'+env)
resources   = conf.get('resources','Array')
log_dirs    = conf.get('log_dirs','Array')
backup      = conf.get('backup')
backup_slug = deploy.get('project_slug') + "_" + env + "_backup"

# add in any standard folders
log_dirs.push('log') unless log_dirs.include? 'log'

# back up script
# --------------------------------  

# safe
safe do

  verbose true

  local :path => "#{exec_path}/backups/:kind/:id"  

  # use ftp to back stuff up
  if backup.get('ftp')  
    ftp do
      host      backup.get('ftp.host')
      user      backup.get('ftp.user')
      password  backup.get('ftp.pass')
      path      backup_slug
    end
  end

  # use sftp to back stuff up
  if backup.get('sftp')
    sftp do
      host      backup.get('sftp.host')
      user      backup.get('sftp.user')
      password  backup.get('sftp.pass')
      path      backup_slug
    end 
  end

  # use s3 to back stuff up
  if backup.get('s3')
    s3 do
      key     backup.get('s3.key')
      secret  backup.get('s3.secret')
      bucket  backup.get('s3.bucket')
      path    backup_slug
    end 
  end

  # how many days are we holding on to backups?
  keep do
    local backup.get('local.keep')
    ftp   backup.get('ftp.keep')
    sftp  backup.get('sftp.keep')
    s3    backup.get('s3.keep')    
  end  

  # backup mysql databases with mysqldump
  mysqldump do

    # dbs
    conf.get('dbs').each do |name,envs|

      # select the db config
      db = envs.get(env)

      database  db.get('name').to_sym do
        user      db.get('user')
        password  db.get('pass')
        host      db.get('host')
        port      db.get('port')
      end

    end

  end

  # acrchive shared files
  tar do
    options "-h" 
    archive "shared_files" do
      files (resources + log_dirs)
    end 
  end  

end