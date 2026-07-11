# ===================== ÉTAPE 1 : Compilation de gosu (Go récent) =====================
FROM golang:1.25-bookworm AS gosu-builder

RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch 1.17 https://github.com/tianon/gosu.git /gosu-src
WORKDIR /gosu-src
RUN CGO_ENABLED=0 go build -o /gosu

# ===================== ÉTAPE 2 : Image finale PostgreSQL =====================
FROM postgres:16-bookworm

COPY --from=gosu-builder /gosu /usr/local/bin/gosu
RUN chmod +x /usr/local/bin/gosu && gosu --version

COPY 00-setup-replication.sh /docker-entrypoint-initdb.d/00-setup-replication.sh
COPY replica-entrypoint.sh /usr/local/bin/replica-entrypoint.sh

RUN chmod +x /docker-entrypoint-initdb.d/00-setup-replication.sh \
    && chmod +x /usr/local/bin/replica-entrypoint.sh

ENV POSTGRES_ROLE=primary

ENTRYPOINT ["replica-entrypoint.sh"]
