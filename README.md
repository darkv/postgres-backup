# jhaeger/postgres-backup

This docker image provides a backup service for a PostgreSQL database running in another docker container.
The service needs to be added into a docker stack that includes a PostgreSQL instance which should be backed up periodically.

All backup files are saved into a backup directory where you should mount a docker volume.
The service will make a backup only for one single database.


## Features

* backup single PostgreSQL database
* scheduling via cron
* keeps configurable number of latest backups
* optionally encrypts backup files
* restore database from backup


## Quick reference

* **Maintained by:** https://github.com/darkv/postgres-backup
* **Where to file issues:** https://github.com/darkv/postgres-backup/issues
* **Supported architectures:** `linux/amd64`, `linux/arm64`


# Configuration

The postgres-backup docker image is configured via environment variables which have to be set up during container startup.


## Environment variables

The list of environment variables to be used:

* CRON\_TIMER - the cron timer setting (e.g. "0 1 * * *")
* BACKUP\_DB\_HOST - database server
* BACKUP\_DB - the postgres database name
* BACKUP\_DB\_USER - database user
* BACKUP\_DB\_PASSWORD - database user password
* BACKUP\_ROLLING - maximum number of backup files to keep, defaults to 5
* BACKUP\_ENCRYPTION - optional passphrase, if present backups will be encrypted with GPG


## Docker volume

All backup files will be put to the path /root/backups which is set up as docker volume mount point. You can configure docker to mount either a docker volume or a specific local path to it.


# Included scripts

All included scripts are located in root‘s home directory:

 * backup_init.sh - sets up the backup service via cron
 * backup.sh - the backup script
 * restore.sh - the restore script


## Backup

All backups are saved to the directory:

    /root/backups/

Each backup file has an ISO timestamp prefix indicating the backup time and the database name:

    2022-01-01_01:00_<database-name>_dump.backup


### Rolling Backup Files

The backup script automatically keeps a specific number of backup files. The default number of files to keep is 5. You can change this setting with the environment variable _BACKUP\_ROLLING_. If the current number of backup files exceeds the configured maximum the oldest file(s) will be deleted.


### Encryption of Backup Files

All backup files are not secured by default. If you want to encrypt those files just set the environment variable _BACKUP\_ENCRYPTION_ to the passphrase to be used. When set, the database dump will be encrypted with GPG. During restoring of a database the passphrase will be used too to decrypt the files first. When encryption is used no unencrypted temporary files are created during the process that could be used to breach security.

Please note that enabling encryption will increase the time and workload of the export process.


### Manual backup

A backup can be started manually by the backup script, too. The backup script can be run either from outside the container:

	$ docker exec -it <container-id> /root/backup.sh

or you can first log into the backup container with:

	$ docker exec -it <container-id> /bin/bash

and then start the backup script:

	root@<container-id>:/# /root/backup.sh

To list all locally existing backups run:

	ls -la /root/backups


## Restore

The backup service provides a script to restore a database from a backup file. It can be started either from outside the container:

	docker exec -it <container-id> /root/restore.sh [<iso-timestamp>]

or you can first log into the backup container with:

	docker exec -it <container-id> /bin/bash

and then start the backup script:

	root@<container-id>:/# /root/restore.sh [<iso-timestamp>]
 
 If you don‘t pass a parameter to the restore script it will take the newest backup file for restoration. Alternatively you can pass a timestamp in ISO format to take the corresponding backup file instead:

 	/root/restore.sh 2022-01-01_12:00

This will look for the file _/root/backups/2022-01-01\_12:00\_<database-name>\_dump.backup_.


# Execution schedule

Given the cron settings provided in the environment variable _BACKUP\_CRON_ the backup\_init script installs a cron job to schedule the backup.sh script.

The value of the variable is a standard cron pattern.
Example for running every day at 03:00:

    0 3 * * *


# How to deploy the Service

The postgres-backup service is supposed to be run as part of a docker service stack. This means that the service is included in a docker-compose.yml file which also contains a PostgreSQL database server.

	version: '3'

	services:
	  ...
	  db:
	    image: postgres:9-alpine
	    environment:
	      - POSTGRES_DB=mydb
	      - POSTGRES_USER=myuser
	      - POSTGRES_PASSWORD=mypassword
	  backup:
	    image: jhaeger/postgres-backup:latest
	    environment:
	      - CRON_TIMER=0 2 * * *
	      - BACKUP_DB_HOST=db
	      - BACKUP_DB=mydb
	      - BACKUP_DB_USER=myuser
	      - BACKUP_DB_PASSWORD=mypassword
	    volumes:
	      - backup_volume:/root/backups
	    depends_on:
	      - db
	  ...
