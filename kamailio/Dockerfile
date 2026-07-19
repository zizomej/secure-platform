FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Dépôt officiel Kamailio (version 5.8) + installation
RUN apt-get update && apt-get install -y --no-install-recommends \
        gnupg2 wget ca-certificates \
    && wget -O- https://deb.kamailio.org/kamailiodebkey.gpg | gpg --dearmor > /usr/share/keyrings/kamailio.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kamailio.gpg] http://deb.kamailio.org/kamailio58 bookworm main" \
        > /etc/apt/sources.list.d/kamailio.list \
    && apt-get update && apt-get install -y --no-install-recommends \
        kamailio \
        kamailio-tls-modules \
        kamailio-extra-modules \
    && apt-get purge -y wget gnupg2 \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 5060/udp
EXPOSE 5060/tcp
EXPOSE 5061/tcp

# Lancement : -DD (pas de démonisation, pour Kubernetes) -E (logs sur stderr)
CMD ["kamailio", "-DD", "-E"]
