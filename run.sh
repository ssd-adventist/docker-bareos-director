#!/bin/bash

if [ ! -f /etc/firstrun ]
then
        if [ ! -f /etc/bareos/bareos-dir.conf ]
        then
                tar xfvz /etc.tgz
        fi

        # configure database
        export PGUSER=postgres
        export PGHOST=db
        export PGPASSWORD=$DB_ENV_POSTGRES_PASSWORD

        psql -c 'create user bareos with createdb createrole createuser login;'
        psql -c "alter user bareos password '${BAREOS_DB_PASSWORD}'";

        sed -i "s/dbpassword = \"\"/dbpassword = \"${BAREOS_DB_PASSWORD}\"/" /etc/bareos/bareos-dir.conf
        sed -i "s/dbuser = bareos/dbuser = bareos\n  dbaddress = db\n  dbport = 5432/" /etc/bareos/bareos-dir.conf

        # configure bareos-dir.d
        cat /include.conf >> /etc/bareos/bareos-dir.conf
        rm /include.conf
        touch /etc/bareos/bareos-dir.d/empty.conf

        # optimize configuration
        export BUILD_NAME=$(grep -iR -m 1 "Name = " /etc/bareos/bareos-dir.conf | awk '{ split($3, x, "-"); print x[1] }')

        sed -i 's/address = .*/address = localhost/' /etc/bareos/bconsole.conf
        sed -i "s/$BUILD_NAME-\(dir\|sd\|fd\|mon\)/bareos-\1/" /etc/bareos/bconsole.conf
        sed -i "s/$BUILD_NAME-\(dir\|sd\|fd\|mon\)/bareos-\1/" /etc/bareos/bareos-dir.conf
        sed -i "s/Address = $BUILD_NAME/Address = localhost/" /etc/bareos/bareos-dir.conf
        sed -i "s/$BUILD_NAME-\(dir\|sd\|fd\|mon\)/bareos-\1/" /etc/bareos/bareos-fd.conf

        # create database
        /usr/lib/bareos/scripts/create_bareos_database
        /usr/lib/bareos/scripts/make_bareos_tables
        /usr/lib/bareos/scripts/grant_bareos_privileges

        # cleanup
        touch /etc/firstrun

        rm /etc.tgz
fi

# TODO find a better solution to run bareos-fd for catalog backup
/usr/sbin/bareos-fd -c /etc/bareos/bareos-fd.conf -u bareos

exec "$@"
