#!/bin/bash

# The script generates an export of a given PostgreSQL database from a docker container.
# If a passphrase is given by BACKUP_ENCRYPTION the dump will be encrypted with GPG.
#
# The script automatically removes old backup files when the number of files exceeds the
# configured maximum of BACKUP_ROLLING, which defaults to 5.

echo "======================================="
echo "Starting Backup..."
echo "======================================="

# make environment variables visible to cron 
source /root/backup.properties

BACKUP_DATE="$(date +%Y-%m-%d_%H-%M)"
BACKUP_FILE="/root/backups/${BACKUP_DATE}_${BACKUP_DB}_dump.backup"
: "${BACKUP_ROLLING:=5}"

echo "*** BACKUP_DB = $BACKUP_DB"
echo "*** BACKUP_FILE = $BACKUP_FILE"
echo "*** BACKUP_ROLLING = $BACKUP_ROLLING"
if [ -n "$BACKUP_ENCRYPTION" ]; then
  echo "*** encryption active"
fi


echo "*** starting database dump..."
if [ -z "$BACKUP_ENCRYPTION" ]; then
  pg_dump -h $BACKUP_DB_HOST -U $BACKUP_DB_USER -d $BACKUP_DB -Fc > $BACKUP_FILE
else
  pg_dump -h $BACKUP_DB_HOST -U $BACKUP_DB_USER -d $BACKUP_DB -Fc | gpg --passphrase-file <(echo $BACKUP_ENCRYPTION) --batch --symmetric -o $BACKUP_FILE
fi
echo "*** database dump finished"


BACKUP_FILESIZE=$(ls -l -h $BACKUP_FILE | cut -d " " -f5) 
echo "*** file size of backup = $BACKUP_FILESIZE"


# remove the oldest backup file(s) and keep only BACKUP_ROLLING files
NUMBER_OF_BACKUP_FILES=$(ls -l /root/backups/*_${BACKUP_DB}_dump.backup | grep -v ^l | wc -l)
if [ "$NUMBER_OF_BACKUP_FILES" -gt "$BACKUP_ROLLING" ]; then 
  echo "*** deleting old backups..."
  ls -F /root/backups/*_dump.backup | head -n -$BACKUP_ROLLING | xargs rm
fi


echo "*** Backup done."
