#!/bin/bash -xe

if [ ! -z "$EFSENDPOINT" ]
then
  mkdir /data
  mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $EFSENDPOINT:/ /data
fi

mkdir -p /data/files
chown -R www-data:www-data /data/files
mkdir -p /data/sessions
chown -R www-data:www-data /data/sessions
ln -sf /data/files /app/concerto/src/Concerto/PanelBundle/Resources/public
ln -sf /data/sessions /app/concerto/src/Concerto/TestBundle/Resources
/wait-for-it.sh $DB_HOST:$DB_PORT -t 300
php bin/console concerto:setup
php bin/console concerto:content:import --convert
rm -rf var/cache/*
php bin/console cache:warmup --env=prod
chown -R www-data:www-data var/cache
chown -R www-data:www-data var/logs
chown -R www-data:www-data var/sessions
chown -R www-data:www-data src/Concerto/PanelBundle/Resources/import
chown -R www-data:www-data src/Concerto/TestBundle/Resources/R/fifo
cron
service nginx start
php bin/console concerto:forker:start
/etc/init.d/php7.2-fpm start
tail -F var/logs/prod.log -n 0
