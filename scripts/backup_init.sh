#!/bin/bash

echo "======================================="
echo "Initialize PostgreSQL Backup Service..."
echo "======================================="

: "${CRON_TIMER:=0 0 * * *}"
echo "*** CRON_TIMER = $CRON_TIMER"

# export all environment variables starting with 'BACKUP_' to be used by cron
env | sed 's/^\(.*\)$/export \1/g' | grep -E "^export BACKUP_" > /root/backup.properties
chmod 0700 /root/backup.properties

# create psql password file so pg_dump runs without password prompt
echo "$BACKUP_DB_HOST:*:*:$BACKUP_DB_USER:$BACKUP_DB_PASSWORD" >> ~/.pgpass 
chmod 0600 ~/.pgpass

# create backup-cron file
echo "$CRON_TIMER root /root/backup.sh > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/backup-cron
chmod 0644 /etc/cron.d/backup-cron

echo "*** Initialization of Backup Service done."
echo "*** Starting cron..."

cron -f
