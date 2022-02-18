#!/bin/bash

mkdir /home/groupoffice/ 2>/dev/null
chmod 777 /home/groupoffice/
chown -R www-data:www-data /home/groupoffice/

echo "Downloading Latest GroupOffice 6.6.x"
echo "deb http://repo.group-office.com/ sixfive main" > /etc/apt/sources.list.d/groupoffice.list
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0758838B
apt-get update
systemctl stop cron

echo "groupoffice groupoffice/dbconfig-install boolean true" | debconf-set-selections

apt-get install -y groupoffice

## cron with MAILTO blank
#/bin/cp -p files/groupoffice-cron /etc/cron.d/

## replace data folder location
sed -i "s|/var/lib/groupoffice|/home/groupoffice|"  /etc/groupoffice/config.php


## force backup incae script run on production by mistake , you have backup
/usr/sbin/automysqlbackup

echo "Remove exisitng default groupoffice database "
echo "And install one with all Module enabled and IMAP Auth activated"
echo "with groupofficeadmin user and random password in : /usr/local/src/groupofficeadmin-pass"
echo "Y" | mysqladmin drop groupoffice -uroot 1>/dev/null 2>/dev/null
mysqladmin create groupoffice -uroot
/bin/cp -p files/groupoffice6.5-db.sql /tmp/groupoffice-db-tmp.sql
sed -i "s/powermail\.mydomainname\.com/`hostname -f`/" /tmp/groupoffice-db-tmp.sql
sed -i "s/mydomainname\.com/`hostname -d`/" /tmp/groupoffice-db-tmp.sql
mysql groupoffice < /tmp/groupoffice-db-tmp.sql
/bin/rm -rf /tmp/groupoffice-db-tmp.sql 1>/dev/null 2>/dev/null

##groupofficeadmin password set
GOPASSVPOP=`pwgen -c -1 8`
echo $GOPASSVPOP > /usr/local/src/groupofficeadmin-pass

php /usr/local/src/groupoffice65-groupofficeadmin-password-reset.php


systemctl start cron


systemctl restart apache2

echo "Done"
