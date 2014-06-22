#!/usr/bin/env bash

# Copy /etc configuration
cp -r /estaty/vagrant-provision/etc/* /etc/

# Configure en_US.UTF-8 locale
locale-gen

# Update apt get repositories
apt-get install python-software-properties
add-apt-repository ppa:ondrej/php5
apt-get update

# Set answers for mysql-server
debconf-set-selections <<< 'mysql-server-5.1 mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server-5.1 mysql-server/root_password_again password root'

# Install Git, Apache, MySQL, PHP, htop and Vim
apt-get -q -y install \
 git-core htop vim apache2 mysql-server mysql-client \
 php5 php5-imagick php5-gd php5-memcache php5-curl php5-intl \
 php5-mysqlnd php5-xdebug php5-mcrypt

# Enable Estaty virtual host
a2ensite estaty.conf
service apache2 reload

# Remove password for MySQL root user
mysqladmin --user=root --password=root password ''

# estaty MySQL databases and users
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS estaty"
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS estaty_test"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO estaty_test@localhost IDENTIFIED BY '';"

# Set environment variables
source /etc/environment

# set up sudo-less binary path
mkdir $HOME/bin
export PATH=$PATH:$HOME/bin

# install composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=$HOME/bin --filename=composer
composer --working-dir=/estaty install

# Make sure /tmp is writable
chown -R vagrant:www-data /tmp
chmod -R 777 /tmp