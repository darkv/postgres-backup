#!/bin/bash

# The script restores a PostgreSQL database in another docker container from backup
# data on a docker volume.
#
# The last backup will be used to restore the database. In case a timestamp is
# provided as argument, a specific backup can be selected for restoration instead.
#
# Example: ./restore.sh 2022-01-01_12-00

echo "======================================="
echo "Starting Restore..."
echo "======================================="

BACKUP_FILE=""
if [ $# -eq 0 ]; then
  BACKUP_FILE=$(ls -F /root/backups/*_${BACKUP_DB}_dump.backup | tail -n 1)
else
  BACKUP_FILE="/root/backups/$1_${BACKUP_DB}_dump.backup"
fi
echo "*** BACKUP_DB = $BACKUP_DB"
echo "*** BACKUP_FILE = $BACKUP_FILE"
if [ -n "$BACKUP_ENCRYPTION" ]; then
  echo "*** decryption active"
fi
  

echo "*** starting database restore..."
if [ -z "$BACKUP_ENCRYPTION" ]; then
  pg_restore -c -h $BACKUP_DB_HOST -U $BACKUP_DB_USER -d $BACKUP_DB -Fc $BACKUP_FILE
else
  gpg --decrypt --passphrase-file <(echo $BACKUP_ENCRYPTION) --batch $BACKUP_FILE | pg_restore -c -h $BACKUP_DB_HOST -U $BACKUP_DB_USER -d $BACKUP_DB -Fc
fi
echo "*** database restore finished"


echo "*** Restore done."
