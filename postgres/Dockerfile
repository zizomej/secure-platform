FROM postgres:16-bookworm

COPY 00-setup-replication.sh /docker-entrypoint-initdb.d/00-setup-replication.sh
COPY replica-entrypoint.sh /usr/local/bin/replica-entrypoint.sh

RUN chmod +x /docker-entrypoint-initdb.d/00-setup-replication.sh \
    && chmod +x /usr/local/bin/replica-entrypoint.sh

ENV POSTGRES_ROLE=primary

ENTRYPOINT ["replica-entrypoint.sh"]
