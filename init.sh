#!/bin/bash

if [ ! -f /etc/firstrun ]
then
        if [ ! -f /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf ]
        then
           tar xfvz /etc.tgz
           chown -R bareos.bareos /etc/bareos
           
           # * Database and password should already be configured for user 'bareos'
           # * User 'bareos' must have createdb, createrole and login privileges
           # * example create user: create user bareos with createdb createrole login;
           # * example set password: alter user bareos password 'mysecretpassword';
           # * $BAREOS_DB_PASSWORD must match user password

           sed -i "s/dbpassword = \"\"/dbpassword = \"${BAREOS_DB_PASSWORD}\"/" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
           sed -i "s/dbuser = \"bareos\"/dbuser = \"bareos\"\n  dbaddress = ${BAREOS_DB_HOST}\n  dbport = 5432/" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf

           # create database
           /usr/lib/bareos/scripts/create_bareos_database
           /usr/lib/bareos/scripts/make_bareos_tables
           /usr/lib/bareos/scripts/grant_bareos_privileges

           # cleanup
           touch /etc/firstrun

           rm /etc.tgz
        fi

fi

# TODO find a better solution to run bareos-fd for catalog backup
#/usr/sbin/bareos-fd -c /etc/bareos/bareos-fd.conf -u bareos
/usr/sbin/bareos-fd -u bareos

exec "$@"
