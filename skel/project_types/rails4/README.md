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

-  	Deployment, cron and backups handled with bonethug. see [https://github.com/azt3k/bonethug]

-   Ruby dependency management handled with bundler.



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



### Development - Setup



1.  clone the repo

2.  run:

`bundle install –path vendor –binstubs`

2.  create the db for the development environment

4.  configure config/database.yml

3.  run:

`bundle exec rake db:migrate`
`bundle exec rake db:seed`



### Development - 




### Deployment



This only works on \*nix based OSes



1.  Setup the project

`bundle exec bonethug setup {staging|production}`



1.  Deploy the project

`bundle exec bonethug deploy {staging|production}`




