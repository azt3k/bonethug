Bonethug
========



(Project) Bones in the basement and a thug to do the things you don't want to
dirty your hands with.



Bonethug could loosely be considered a "web project meta framework".  It uses a
single configuration file (although it merges in the database.yml file for rails
projects) for all project types and includes adapters to interface with project
specific configs.  This keeps you configuration in one place and has the benefit
of being able to drive the automation of a number of other repeatitious taks
like deployment, task scheduling, backups and asset / db synchronisation.



The goal of the project is to be able to handle the complete project life cycle
using only bonethug, git and package managers - no ssh, ftp, mysqldump etc.



Installation
------------

Add this line to your application's Gemfile:

    `gem 'bonethug'`

And then execute:

    `bundle`

Or install it yourself as:

    `gem install bonethug`



Update
------

execute:

    `bundle update bonethug`

update the bonethug files in your project:

    `bundle exec thug update`



Usage
-----



### Local Commands



**Set up a project Skeleton**

`thug install {rails3|rails4|silverstripe3|drupal|php|sinatra}`



**Add bonethug to an existing project**

*If you just want to use the deploy / cron / backup framework*

`thug init`



**Update the bonethug files in an existing project**

*This updates the .bonethug/deploy.rb, .bonethug/backup.rb,
config/example/cnf.yml, config/example/schedule.rb config files*

`thug update`



**Watch for changes to SCSS / CoffeeScript**

*Configure the watch in the config/cnf.yml.  Uses vanilla coffeescript and sass
compilers by default, but can use sprockets if passed the sprockets argument*

`thug watch [sprockets]`



**Trigger Backup on Local Copy**

*Uses astrails-safe to make a backup using the .bonethug/backup.rb file.  Uses
the info contained in cnf.yml*

`thug local-backup {development|staging|production}`



**Setup local server**

*You sets up the local machine (if you are on ubuntu)*

`thug setup-env local`



**Initialise local DB**

*Uses the local mysql client to create a user and a database according to the
settings in your config/cnf.yml file*

`thug init-local-db [admin_user=root] {development|staging|production}`



### Remote Commands


**Setup a remote server**

*This installs all the required software on a remote server using mina to call
all the commands*

`thug setup-env {development|staging|production}`



**Initialise remote DB**

*Uses the mysql client in the remote environment to create a user and a database
according to the settings in your config/cnf.yml file*

`thug init-db [admin_user=root] {development|staging|production}`



**Setup and Deploy to Remote Server**

*This wraps mina and deploys using the information contained in cnf.yml*

`thug setup {development|staging|production}`

`thug deploy {develoment|staging|production}`



**Unlock a Remote Server**

*This unlocks a failed deployment*

`thug force-unlock {develoment|staging|production}`



**Trigger a Snapshot Backup from the Remote Server**

*This wraps mina and runs the backup task in the local .bonethug/deploy.rb file.
It calls astrails-safe on the remote server and using the remote
.bonethug/backup.rb file which pulls the info out of the remote config/cnf.yml.
If you are using FTP, make sure the directory exists before triggering a
backup.*

`thug remote-backup {develoment|staging|production}`



**Trigger a Sync to or from the Remote Sync Backup Location**

*This wraps mina and runs rsync on the remote server.  It uses the info defined
in the local copy of config/cnf.yml under backup.rsync.  If you have already set
up an ssh key with no pass on the remote server so it can talk to the sync
location then you wont need to provide a pass in the cnf.yml.  this is prefereed
as it keeps the password out of the log files.*

BE CAREFUL USING SYNC-TO - if there are no files in the source location it will
wipe the files from your deploy copy.

`thug sync-backup-from {develoment|staging|production}`

`thug sync-backup-to {develoment|staging|production}`



**Trigger an application state sync from one environment to another**


*Sync local application state from another application environment*

`thug sync-state push-to-local {local-environment} pull-from-remote {environment-to-pull-data-from}`

*Sync another application's state in another environment to the local application state*

`thug sync-state pull-from-local {local-environment} push-to-remote {environment-to-push-data-to}`


*Sync remote application state with the application state environment - this wraps mina to trigger the sync actions above on a remote server*

`thug sync-state pull-from-remote {environment-to-pull-data-from} push-to-remote {environment-to-push-data-to}`



Example Workflow
----------------



### New SilverStripe3 project


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# install bonethug in the global scope (or use: bundle exec thug)
gem install bonethug

# set up project bones in the current folder
thug install silverstripe3
bundle install --path vendor
php composer.phar install
bower install

# --> edit the config/cnf.yml file!!

# setup local db
thug init-db local

# watch for changes to sass and coffeescript
thug watch

# --> actually write some code!!

# commit work
git remote add origin git@git.domain.com:namespace/project-name.git
git add -A && git commit -am "initial commit"
git push -u origin master

# setup the deployment env and do a deploy
thug auth staging
thug setup-env staging
thug init-db staging
thug setup staging
thug deploy staging

# push the db and assets up to staging
thug sync-state pull-from-local development push-to-remote staging

# pull the db and assets up down to local
thug sync-state pull-from-remote staging push-to-local development
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



### Deploying an existing project



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# clone the repo and install the gems
git clone git@git.domain.com:namespace/project-name.git .
bundle install --path vendor

# only do this if its a fresh deploy target
thug auth staging
thug setup-env staging
thug init-db staging
thug setup staging

# deploy
thug deploy staging
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



What isn't implemented yet?
---------------------------


- sync of just db between envs
- sync of just files between envs
- remove a deployment from a target
- support for more project types
- support for other OSes
- support for nginx



Contributing
------------

1.  Fork it

2.  Create your feature branch (`git checkout -b my-new-feature`)

3.  Commit your changes (`git commit -am 'Add some feature'`)

4.  Push to the branch (`git push origin my-new-feature`)

5.  Create new Pull Request
