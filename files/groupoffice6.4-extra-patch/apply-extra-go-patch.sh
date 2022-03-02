#!/bin/sh
BASEDIR=$(dirname $0)
cd $BASEDIR

# Instead of "Forgot login credentials" on Login Screen have "Change Password" button
## Take backup as safety
cp /usr/share/groupoffice/go/core/views/extjs3/login/UsernamePanel.js /usr/local/src/UsernamePanel.js-backup
### how patch was done 
### diff -Naur UsernamePanel.js UsernamePanel-new-password.js  > UsernamePanel-patch-for-ChangePassword-Link.patch 


## Add Archive search Box
cp  /usr/share/groupoffice/modules/email/EmailClient.js /usr/local/src/EmailClient.js-backup
### how patch was done 
### diff -Naur EmailClient.js EmailClient-new-archive.js  > EmailClient-patch-for-ArchiveSearch.patch


patch -N -p1 /usr/share/groupoffice/modules/email/EmailClient.js  < EmailClient-patch-for-ArchiveSearch.patch 
patch -N -p1 /usr/share/groupoffice/go/core/views/extjs3/login/UsernamePanel.js < UsernamePanel-patch-for-ChangePassword-Link.patch 

cd -

## apply upgrade --so cache is clear
cd /usr/share/groupoffice/
runuser -u www-data -- php cli.php core/System/upgrade

cd -

