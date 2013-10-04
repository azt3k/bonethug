Bonethug
========



Project Skeleton Manager



Installation
------------

Add this line to your application's Gemfile:

    `gem 'bonethug'`

And then execute:

    `bundle`

Or install it yourself as:

    `gem install bonethug`



Usage
-----



### Local Commands



**Set up a project Skeleton**

`bonethug install {rails3|silverstripe3|drupal|php|sinatra}`



**Add bonethug to an existing project**

*If you just want to use the deploy / cron / backup framework*

`bonethug init`



**Update the bonethug files in an existing project**

*This updates the .bonethug/deploy.rb, .bonethug/backup.rb,
config/example/cnf.yml, config/example/schedule.rb config files*

`bonethug update`



**Watch for changes to SCSS / CoffeeScript**

*Configure the watch in the config/cnf.yml.  Uses vanilla coffeescript and sass
compilers by default, but can use sprockets if passed the sprockets argument*

`bonethug watch [sprockets]`



**Trigger Backup on Local Copy**

*Uses astrails-safe to make a backup using the .bonethug/backup.rb file.  Uses
the info contained in cnf.yml*

`bonethug local-backup {development|staging|production}`



### Remote Commands

Most of these are piped through mina.  Mina uses SSH to send a bash script to
the remote server where it is executed.  For these commands to work you need to
have the desired host already added to your known hosts file: ~/.ssh/known_hosts
which means you can either connect to the host first, manually add it or switch
off the checking by adding the following to ~/.ssh/config.



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



**Setup and Deploy to Remote Server**

*This wraps mina and deploys using the information contained in cnf.yml*

`bonethug setup {development|staging|production}`  
`bonethug deploy {develoment|staging|production}`



**Trigger a Snapshot Backup from the Remote Server**

*This wraps mina and runs the backup task in the local .bonethug/deploy.rb file.
It calls astrails-safe on the remote server and using the remote
.bonethug/backup.rb file which pulls the info out of the remote config/cnf.yml.
If you are using FTP, make sure the directory exists before triggering a
backup.*

`bonethug remote-backup {develoment|staging|production}`



**Trigger a Sync to or from the Remote Sync Location**

*This wraps mina and runs rsync on the remote server.  It uses the info defined
in the local copy of config/cnf.yml under backup.rsync.  If you have already set
up an ssh key with no pass on the remote server so it can talk to the sync
location then you wont need to provide a pass in the cnf.yml.  this is prefereed
as it keeps the password out of the log files.*

BE CAREFUL USING SYNC-TO - if there are no files in the source location it will
wipe the files from your deploy copy.

`bonethug sync-from {develoment|staging|production}`

`bonethug sync-to {develoment|staging|production}`

  


Contributing
------------

1.  Fork it 2. Create your feature branch (`git checkout -b my-new-feature`) 3.
    Commit your changes (`git commit -am 'Add some feature'`) 4. Push to the
    branch (`git push origin my-new-feature`) 5. Create new Pull Request
