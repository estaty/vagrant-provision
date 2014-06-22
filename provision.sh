#!/usr/bin/env bash

# Use Google dns
cp /estaty/vagrant-provision/etc/resolv.conf /etc/resolv.conf

# Configure en_US.UTF-8 locale
cp /estaty/vagrant-provision/etc/locale.gen /etc/locale.gen
locale-gen

# Update apt get repositories
apt-get update

# Set answers for mysql-server
debconf-set-selections <<< 'mysql-server-5.1 mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server-5.1 mysql-server/root_password_again password root'

# Install Git, Apache, MySQL, PHP, htop and Vim
apt-get -q -y install \
 git-core \
 apache2 \
 mysql-server mysql-client \
 php5 php5-imagick php5-gd php5-memcache php5-curl php5-intl \
 php5-mysql php5-mysqlnd php5-xdebug php5-mcrypt \
 htop vim

# Enable estaty virtual host
a2enmod rewrite
cp /estaty/vagrant-provision/vhosts/estaty /etc/apache2/sites-available/
a2ensite estaty
service apache2 reload

# Remove password for MySQL root user
mysqladmin -u root -proot password ''

# estaty MySQL databases and users
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS estaty"
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS estaty_test"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO estaty_test@localhost IDENTIFIED BY '';"

# etc
cp /estaty/vagrant-provision/etc/hosts /etc/hosts
cp /estaty/vagrant-provision/etc/environment /etc/environment
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