Bonethug
========

Project Skeleton Manager

Installation
------------

Add this line to your application's Gemfile:

    gem 'bonethug'

And then execute:

    \$ bundle

Or install it yourself as:

    \$ gem install bonethug

Usage
-----



### Local Commands



**Set up a project Skeleton**

`bonethug install {rails3|silverstripe3|drupal|php|sinatra}`



**Add bonethug to an existing project **

*If you just want to use the deploy / cron / backup framework*

`bonethug init`



**Update the bonethug files in an existing project**

*This updates the .bonethug/deploy.rb, .bonethug/backup.rb,
config/example/cnf.yml, config/example/schedule.rb config files*

`bonethug update`



**Watch for changes to SCSS / CoffeeScript**

*Configure the watch in the config/cnf.yml.  Uses sprockets by default, but can
use vanilla coffeescript and sass compilers if you pass it the coffee_sass
argument*

`bonethug watch [coffee_sass]`



**Trigger Backup on Local Copy**

*Uses astrails-safe to make a backup using the .bonethug/backup.rb file.  Uses
the info contained in cnf.yml*

`bonethug backup {development|staging|production}`



### Remote Commands

For these commands to work you need to have the desired host already added to
your known hosts file:  ~/.ssh/known_hosts which means you can either connect to
the host first, manually add it or switch off the checking by adding the
following to ~/.ssh/config.



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



**Setup and Deploy to Remote Server**

*This wraps mina and deploys using the information contained in cnf.yml*

`bonethug setup {development|staging|production}`  
`bonethug deploy {develoment|staging|production}`



**Trigger a Backup from the Remote Server**

*This wraps mina and runs the backup task in the bonethug deploy.rb file. Uses
the info contained in cnf.yml*

`bonethug remote-backup {develoment|staging|production}`

  


Contributing
------------

1.  Fork it 2. Create your feature branch (`git checkout -b my-new-feature`) 3.
    Commit your changes (`git commit -am 'Add some feature'`) 4. Push to the
    branch (`git push origin my-new-feature`) 5. Create new Pull Request
