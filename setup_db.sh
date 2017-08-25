#!/bin/bash

# Run this script to set up db manually

# * Database and password should already be configured for user 'bareos'
# * User bareos must have createdb, createrole and login privileges
# * example create user: create user bareos with createdb createrole login;
# * example set password: alter user bareos password 'mysecretpassword';
# * $BAREOS_DB_PASSWORD must match user password

sed -i "s/dbpassword = \"\"/dbpassword = \"${BAREOS_DB_PASSWORD}\"/" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
sed -i "s/dbuser = \"bareos\"/dbuser = \"bareos\"\n  dbaddress = db\n  dbport = 5432/" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf

# create database
/usr/lib/bareos/scripts/create_bareos_database
/usr/lib/bareos/scripts/make_bareos_tables
/usr/lib/bareos/scripts/grant_bareos_privileges

