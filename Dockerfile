FROM debian:bullseye-slim

ARG BUILD_DATE
ARG BUILD_VERSION

LABEL org.opencontainers.image.authors="Johann Häger <johann.haeger@posteo.de>"
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.description="Backup service for a PostgreSQL database running in another docker container."
LABEL org.opencontainers.image.documentation="https://github.com/darkv/postgres-backup/blob/main/README.md"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/darkv/postgres-backup"
LABEL org.opencontainers.image.title="Backup Service for PostgreSQL"
LABEL org.opencontainers.image.url="https://github.com/darkv/postgres-backup"
LABEL org.opencontainers.image.vendor="Johann Häger <johann.haeger@posteo.de>"
LABEL org.opencontainers.image.version=$BUILD_VERSION

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
