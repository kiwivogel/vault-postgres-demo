#!/bin/bash
set -e

POSTGRESQL_DB=${POSTGRESQL_DB:-"docker"}
POSTGRESQL_TEMPLATE=${POSTGRESQL_TEMPLATE:-"DEFAULT"}

POSTGRESQL_BIN=/usr/lib/postgresql/9.5/bin/postgres
POSTGRESQL_CONFIG_FILE=/etc/postgresql/9.5/main/postgresql.conf
POSTGRESQL_DATA=/var/lib/postgresql/9.5/main

POSTGRESQL_SINGLE="sudo -u postgres $POSTGRESQL_BIN --single --config-file=$POSTGRESQL_CONFIG_FILE"
POSTGRESQL_SINGLE_DB="sudo -u postgres $POSTGRESQL_BIN --single --config-file=$POSTGRESQL_CONFIG_FILE $COMPONENT_NAME"

#Bootstrapping folders etc.!

mkdir -p $POSTGRESQL_DATA
chmod 700 $POSTGRESQL_DATA
chown -R postgres:postgres $POSTGRESQL_DATA

#Run initdb
sudo -u postgres /usr/lib/postgresql/9.5/bin/initdb -D $POSTGRESQL_DATA -E 'UTF-8'
#Set self signed SSL certificates
ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem $POSTGRESQL_DATA/server.crt
ln -s /etc/ssl/private/ssl-cert-snakeoil.key $POSTGRESQL_DATA/server.key

#Add Vault Admin account
$POSTGRESQL_SINGLE <<< "CREATE USER vault WITH INHERIT SUPERUSER PASSWORD 'notaverysafepassword'IF NOT EXISTS;" > /dev/null

#Pickup component names from list and check for existance of DB's and users.

for COMPONENT_NAME in `cat components.list`; do
    COMPONENT_NAME_GROUP=""$COMPONENT_NAME"_group"
    $POSTGRESQL_SINGLE <<< "CREATE ROLE \"$COMPONENT_NAME_GROUP\" IF NOT EXISTS;" > /dev/null
    $POSTGRESQL_SINGLE <<< "CREATE USER \"$COMPONENT_NAME\" WITH PASSWORD '$COMPONENT_NAME'IF NOT EXISTS;" > /dev/null
    $POSTGRESQL_SINGLE <<< "GRANT \"$COMPONENT_NAME_GROUP\" to \"$COMPONENT_NAME\";"> /dev/null
    $POSTGRESQL_SINGLE <<< "CREATE DATABASE \"$COMPONENT_NAME\" TEMPLATE $POSTGRESQL_TEMPLATE IF NOT EXISTS;" > /dev/null
    $POSTGRESQL_SINGLE <<< "ALTER DATABASE \"$COMPONENT_NAME\" OWNER TO \"$COMPONENT_NAME\";" > /dev/null
    $POSTGRESQL_SINGLE_DB <<< "REVOKE ALL ON SCHEMA \"public\" FROM public;"  > /dev/null
    $POSTGRESQL_SINGLE_DB <<< "GRANT ALL ON SCHEMA \"public\" TO \"$COMPONENT_NAME\";" > /dev/null
    $POSTGRESQL_SINGLE_DB <<< "ALTER SCHEMA \"public\" OWNER TO \"$COMPONENT_NAME\";" > /dev/null
    $POSTGRESQL_SINGLE_DB <<< "ALTER DEFAULT PRIVILEGES FOR ROLE \"$COMPONENT_NAME_GROUP\" IN SCHEMA \"public\" GRANT SELECT ON TABLES TO \"$COMPONENT_NAME_GROUP\";" > /dev/null

done


exec sudo -u postgres $POSTGRESQL_BIN -D $POSTGRESQL_DATA --config-file=$POSTGRESQL_CONFIG_FILE