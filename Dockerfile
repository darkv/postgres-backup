FROM debian:bullseye-slim

LABEL maintainer="johann.haeger@posteo.de"
LABEL version="1.0"
LABEL description="Backup Service for PostgreSQL"

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
  cron \
  gnupg \
  postgresql-client \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/*

# disable default crontab
COPY crontab /etc/crontab

ADD scripts/*.sh /root/
RUN chmod 0500 /root/*.sh

RUN mkdir /root/backups
VOLUME /root/backups

CMD ["/root/backup_init.sh"]
