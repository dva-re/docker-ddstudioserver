#!/bin/bash

source /root/start-utils

if [ ! -d /var/lib/mysql/mysql ]; then
    mysqld --initialize-insecure
fi

chown -R mysql:mysql /var/lib/mysql
chown -R www-data:www-data /var/www/html

if [ ! -d /data/.ssh ]; then
    mkdir /data/.ssh
    touch /data/.ssh/authorized_keys
    chmod 600 /data/.ssh/authorized_keys*
fi

if [ ! -d /data/git ]; then
    mkdir /data/git
fi

if [ ! -d /data/apache_logs ]; then
    mkdir /data/apache_logs
fi

if [ ! -e /etc/sphinxsearch/sphinx.conf ]; then
    cp /etc/sphinxsearch.orig/* /etc/sphinxsearch/
fi

chown -R sphinxsearch:root /etc/sphinxsearch

if [ ! -d /data/sphinxdata ]; then
    mkdir /data/sphinxdata
fi
chown -R sphinxsearch:root /data/sphinxdata

service ssh start
service apache2 start
service mysql start
service cron start
service sphinxsearch start

wait_signal

echo "Try to exit properly"
service cron stop
service sphinxsearch stop
service mysql stop
service apache2 stop
service ssh stop


wait_exit "apache2 mysqld sshd cron searchd"
