Bonethug Project Skeleton
=========================

Set Up
------

## Windows

If you are windows you'll need some better unix command support this helps:
`http://git-scm.com/downloads`
`http://www.robvanderwoude.com/unixports.php`

### Apache, MySQL, PHP

`http://www.wampserver.com/en/`

### Ruby

`http://rubyinstaller.org`
`https://github.com/vertiginous/pik`

### NodeJS / NPM

`http://nodejs.org/download/`

### Bundler

````bash
gem install bundler
````

### Bower

````bash
npm install bower -g
````



## OSX (10.9)

### Apache, MySQL, PHP

`http://coolestguidesontheplanet.com/set-amp-osx-10-9-mavericks-homebrew/`

### Ruby

`https://github.com/sstephenson/rbenv`

### Composer

`https://getcomposer.org/doc/00-intro.md#installation-nix`

### NPM

`http://howtonode.org/introduction-to-npm`

### Bundler

````bash
gem install bundler
````

### Bower

````bash
npm install bower -g
````



## Linux

`https://github.com/azt3k/bonethug/blob/master/scripts/ubuntu-14.04-dev`




Getting a working copy up and running
-------------------------------------

````bash
# clone the repo
git clone git@git.domain.com:namespace/project-name.git project-name
cd project-name

# install depenedencies
bundle install
composer install
bower install

# init db
bundle exec thug init-local-db development

# set up a vhost (Ubuntu only currently)
bundle exec thug vhost-local development

# pull assets / db down
bundle exec thug sync-state pull-from-remote production push-to-local development

# watch sass / coffee script
bundle exec thug watch
````

Deployment
----------

````bash
# only do this if its a fresh deploy target
bundle exec thug setup staging

# deploy
bundle exec thug deploy staging
````

More Info
---------

https://github.com/azt3k/bonethug
