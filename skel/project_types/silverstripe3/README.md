SilverStripe Bonethug Project Skeleton
======================================



Requirements
------------

-   Ruby 1.9.3 +

-   PHP 5.3 +

-   Linux / OSX

-   Apache

-   MySQL 5.5 +

-   Bundler

-   Composer

-   NPM

-   Bower



Overview
--------

-   Deployment handled with mina. see [https://github.com/nadarei/mina]

-   Cron handled wtih whenever. [https://github.com/javan/whenever]

-   Backups handled with astrails-safe. see [https://github.com/astrails/safe]

-   Ruby dependency management handled with bundler. see [http://bundler.io]

-   Built on the Silverstripe framework, CMS and Installer - 3.1.x dev branch.

-   PHP dpendency management handled with composer. see [https://packagist.org/]

-   Javascript assets are managed via [https://github.com/bower/bower]

-   Bower depends on node.js [http://nodejs.org] and NPM [https://npmjs.org]



Set Up
------



### Pre-requisites



1.  If you are windows you'll need some better unix command support.  Make usre
    you install git for windows and this also helps:
    http://www.robvanderwoude.com/unixports.php

2.  Firstly you need an MAMP / LAMP / WAMP etc stack, ruby 1.9.3 and curl for
    composer, and node.js / npm for bower.  If you're on windows there's an 
    installer for composer, node.js and npm

3.  You need to have bundler, composer and bower installed



**bundler**

`gem install bundler`



**composer**

`cd /path/to/project/root && curl -s http://getcomposer.org/installer | php`



**bower**

`npm install bower -g`


### Development



1.  clone the repo, create the db, update config/cnf.yml if needed

2.  Setup a vhost - look at the one defined in deploy.rb

3.  run:

`bundle install -–path vendor`

`php composer.phar install`

`bower install`



### Deployment



This only works on \*nix based OSes



1.  Setup the project

`bundle exec bonethug setup {staging|production}`



1.  Deploy the project

`bundle exec bonethug deploy {staging|production}`



### Other Commands and more info

  
<https://github.com/azt3k/bonethug>






