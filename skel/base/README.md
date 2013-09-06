Bonethug Project Skeleton
=========================



Requirements
------------

-   Ruby 1.9.3 +

-   PHP 5.3 +

-   Linux / OSX

-   Apache

-   MySQL 5.5 +



Overview
--------

-   Deployment handled with mina. see [https://github.com/nadarei/mina]

-   Cron handled wtih whenever. [https://github.com/javan/whenever]

-   Backups handled with astrails-safe. [see https://github.com/astrails/safe]

-   Ruby dependency management handled with bundler. see

-   Built on the Silverstripe framework, CMS and Installer - 3.1.x dev branch.

-   PHP dpendency management handled with composer. see [https://packagist.org/]



Set Up
------



### Pre-requisites



1.  If you are windows you'll need some better unix command support this helps:
    http://www.robvanderwoude.com/unixports.php

2.  Firstly you need an MAMP / LAMP / WAMP etc stack, ruby 1.9.3 and curl for
    composer, if you're on windows there's an installer for composer

3.  You need to have bundler and composer installed



**bundler**

`gem install bundler`



**composer**

`cd /path/to/project/root && curl -s http://getcomposer.org/installer | php`



### Development



1.  clone the repo, create the db, update config/cnf.yml if needed

2.  Setup a vhost - look at the one defined in deploy.rb

3.  run:

`bundle install –path vendor –binstubs `

`php composer.phar install`



### Deployment



This only works on \*nix based OSes



1.  Setup the project

`bundle exec bonethug setup {staging|production}`



1.  Deploy the project

`bundle exec bonethug deploy {staging|production}`




