#!/bin/bash

if [ ! -f /etc/bareos/bareos-config.control ]
  then
  tar xfvz /etc.tgz

  # Update bareos-director configs

  sed -i "s/dbpassword = \"\"/dbpassword = \"${BAREOS_DB_PASSWORD}\"/" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
  sed -i "s/dbuser = \"bareos\"/dbuser = \"bareos\"\n  dbaddress = ${DB_HOST}\n  dbport = 5432/" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf

  # control file
  touch /etc/bareos/bareos-config.control
  chown -R bareos.bareos /etc/bareos
fi

if [ ! -f /etc/bareos/bareos-db.control ]
  then
  sleep 15
  # init posgres db
  export PGUSER=postgres
  export PGHOST=${DB_HOST}
  export PGPASSWORD=${POSTGRES_PASSWORD}
  psql -c 'create user bareos with createdb createrole createuser login;'
  psql -c "alter user bareos password '${BAREOS_DB_PASSWORD}';"
  /usr/lib/bareos/scripts/create_bareos_database
  /usr/lib/bareos/scripts/make_bareos_tables
  /usr/lib/bareos/scripts/grant_bareos_privileges

  # control file
  touch /etc/bareos/bareos-db.control
  chown -R bareos.bareos /etc/bareos/bareos-db.control
fi

# TODO find a better solution to run bareos-fd for catalog backup
#/usr/sbin/bareos-fd -c /etc/bareos/bareos-fd.conf -u bareos
/usr/sbin/bareos-fd -u bareos

exec "$@"
