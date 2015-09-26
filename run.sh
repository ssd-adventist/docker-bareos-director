#!/bin/bash

if [ ! -f /etc/firstrun ]
then
        if [ ! -f /etc/bareos/bareos-dir.conf ]
        then
                tar xfvz /etc.tgz
        fi

        export PGUSER=postgres
        export PGHOST=db
        export PGPASSWORD=$DB_ENV_POSTGRES_PASSWORD

        psql -c 'create user bareos with createdb createrole createuser login;'
        psql -c "alter user bareos password '${BAREOS_DB_PASSWORD}'";

        sed -i "s/dbpassword = \"\"/dbpassword = \"${BAREOS_DB_PASSWORD}\"/" /etc/bareos/bareos-dir.conf
        sed -i "s/dbuser = bareos/dbuser = bareos\n  dbaddress = db\n  dbport = 5432/" /etc/bareos/bareos-dir.conf

        echo @\|"sh -c 'for f in /etc/bareos/bareos-dir.d/*.conf ; do echo @${f} ; done'" >> /etc/bareos/bareos-dir.conf

        /usr/lib/bareos/scripts/create_bareos_database
        /usr/lib/bareos/scripts/make_bareos_tables
        /usr/lib/bareos/scripts/grant_bareos_privileges

        touch /etc/firstrun

        rm /etc.tgz
fi

exec "$@"