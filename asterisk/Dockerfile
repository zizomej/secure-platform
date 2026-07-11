# ===================== ÉTAPE 1 : COMPILATION =====================
FROM debian:bookworm-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    libxml2-dev \
    libsqlite3-dev \
    uuid-dev \
    libjansson-dev \
    libssl-dev \
    libedit-dev \
    libncurses5-dev \
    pkg-config \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

RUN wget https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz \
    && tar xvfz asterisk-20-current.tar.gz \
    && rm asterisk-20-current.tar.gz \
    && mv asterisk-20* asterisk-source

WORKDIR /usr/src/asterisk-source

RUN ./configure --with-jansson-bundled
RUN make menuselect.makeopts
RUN make -j1
RUN make install && make samples && make config

# ===================== ÉTAPE 2 : IMAGE FINALE =====================
FROM debian:bookworm-slim

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    libxml2 \
    libsqlite3-0 \
    uuid-runtime \
    libjansson4 \
    libssl3 \
    libedit2 \
    libncurses6 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/sbin/asterisk /usr/sbin/asterisk
COPY --from=builder /etc/asterisk /etc/asterisk
COPY --from=builder /var/lib/asterisk /var/lib/asterisk
COPY --from=builder /var/spool/asterisk /var/spool/asterisk
COPY --from=builder /var/log/asterisk /var/log/asterisk
COPY --from=builder /var/run/asterisk /var/run/asterisk
COPY --from=builder /usr/lib/asterisk /usr/lib/asterisk
COPY --from=builder /usr/lib/libasterisk* /usr/lib/

RUN ldconfig

EXPOSE 5060/udp
EXPOSE 5061/tcp
EXPOSE 10000-20000/udp

CMD ["asterisk", "-f", "-vvv"]
