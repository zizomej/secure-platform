#!/bin/bash
set -e

if [ "$POSTGRES_ROLE" = "replica" ]; then
    if [ -z "$(ls -A "$PGDATA" 2>/dev/null)" ]; then
        echo "Rôle Replica détecté : clonage des données depuis $PRIMARY_HOST..."
        export PGPASSWORD="$POSTGRES_REPLICATION_PASSWORD"
        until gosu postgres pg_basebackup -h "$PRIMARY_HOST" -D "$PGDATA" -U replicator -Fp -Xs -P -R; do
            echo "Primary pas encore disponible, nouvelle tentative dans 5s..."
            sleep 5
        done
        chown -R postgres:postgres "$PGDATA"
        chmod 700 "$PGDATA"
    fi
    exec gosu postgres postgres
else
    exec docker-entrypoint.sh postgres
fi
