#!/bin/bash

# -----------------------------------------------------
# install native stuff
# -----------------------------------------------------

# install the repo adding scripts
sudo apt-get install software-properties-common python-software-properties

# add repos
sudo add-apt-repository ppa:richarvey/nodejs
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe restricted multiverse"
sudo add-apt-repository "deb-src http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe restricted multiverse"
sudo add-apt-repository ppa:ondrej/apache2
sudo add-apt-repository ppa:ondrej/php5

# update
sudo apt-get update && sudo apt-get upgrade

# install

# dev headers
sudo apt-get install libcurl4-openssl-dev libssl-dev apache2-threaded-dev libapr1-dev libaprutil1-dev libapr1-dev libaprutil1-dev
sudo apt-get install libmysqlclient-dev libmagickwand-dev libsqlite3-dev libxml2-dev libxslt1-dev

# regular packages
sudo apt-get install apache2-mpm-worker
sudo apt-get install curl libapache2-mod-fastcgi php5-fpm php5 php5-cli php5-curl php5-gd php5-imagick php-apc php5-mysql
sudo apt-get install mysql-server mysql-client sqlite3
sudo apt-get install imagemagick
sudo apt-get install phpmyadmin
sudo apt-get install sshpass
sudo apt-get install libxml2 g++
sudo apt-get install git ruby1.9.3 nodejs npm at


# -----------------------------------------------------
# Configure stuff
# -----------------------------------------------------

# unix socket 
# echo "
# <IfModule mod_fastcgi.c>
#   AddHandler php5-fcgi .php
#   Action php5-fcgi /php5-fcgi
#   Alias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi
#   FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -socket /var/run/php5-fpm.sock -pass-header Authorization
# </IfModule>
# " > /etc/apache2/conf.d/php-fpm.conf
# sed -i -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php5-fpm.sock/g" /etc/php5/fpm/pool.d/www.conf

## TCP
# echo "
# <IfModule mod_fastcgi.c>
#   AddHandler php5-fcgi .php
#   Action php5-fcgi /php5-fcgi
#   Alias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi
#   FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -host 127.0.0.1:9000 -idle-timeout 250 -pass-header Authorization
# </IfModule>
# " > /etc/apache2/conf.d/php-fpm.conf
# sed -i -e "s/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g" /etc/php5/fpm/pool.d/www.conf

sudo sed -i -e "s/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g" /etc/php5/fpm/pool.d/www.conf
sudo echo -e "<IfModule mod_fastcgi.c>\n AddHandler php5-fcgi .php\n Action php5-fcgi /php5-fcgi\n Alias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi\n FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -host 127.0.0.1:9000 -appConnTimeout 900 -idle-timeout 900 -pass-header Authorization\n </IfModule>" > /etc/apache2/conf.d/php-fpm.conf

# Apache
# ------

# modules
sudo a2enmod actions fastcgi alias expires rewrite headers

# phpmyadmin
sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf.d/phpmyadmin.conf

# -----------------------------------------------------
# Install Gems
# -----------------------------------------------------

# install some gems - yes gem1.9.3 - wtf
sudo gem1.9.3 install mina bundler whenever astrails-safe

# install passenger
sudo gem1.9.3 install passenger
sudo passenger-install-apache2-module
sudo touch /etc/apache2/mods-available/passenger.load
sudo touch /etc/apache2/mods-available/passenger.conf

# -----------------------------------------------------
# Node.js related
# -----------------------------------------------------

sudo npm install bower -g

# -----------------------------------------------------
# Restart stuff
# -----------------------------------------------------

sudo service apache2 restart
sudo service php5-fpm restart