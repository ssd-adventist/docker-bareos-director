#!/bin/bash

# Run this script to set up db manually


# configure database
export PGUSER=postgres
export PGHOST=db
export PGPASSWORD=$DB_ENV_POSTGRES_PASSWORD

psql -c 'create user bareos with createdb createrole login;'
psql -c "alter user bareos password '${BAREOS_DB_PASSWORD}'";

sed -i "s/dbpassword = \"\"/dbpassword = \"${BAREOS_DB_PASSWORD}\"/" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
sed -i "s/dbuser = \"bareos\"/dbuser = \"bareos\"\n  dbaddress = db\n  dbport = 5432/" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf

# create database
/usr/lib/bareos/scripts/create_bareos_database
/usr/lib/bareos/scripts/make_bareos_tables
/usr/lib/bareos/scripts/grant_bareos_privileges

