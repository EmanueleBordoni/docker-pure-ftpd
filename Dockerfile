# 🔨 Stage 1: builder con Debian Bookworm
FROM debian:bookworm AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libpam0g-dev \
    libcap-dev \
    wget \
    ca-certificates \
    rsyslog

# 📦 Scarica pure-ftpd all'ultima versione
ARG PUREFTPD_VERSION=1.0.51

RUN mkdir -p /build && \
    cd /build && \
    wget https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-${PUREFTPD_VERSION}.tar.gz && \
    tar xzf pure-ftpd-${PUREFTPD_VERSION}.tar.gz && \
    cd pure-ftpd-${PUREFTPD_VERSION} && \
    ./configure --with-tls --with-puredb --with-uploadscript && \
    # 🔧 Rimuove capabilities che causano problemi in ambienti limitati
    sed -i '/CAP_SYS_NICE/d; /CAP_DAC_READ_SEARCH/d; s/CAP_SYS_CHROOT,/CAP_SYS_CHROOT/' src/caps_p.h && \
    make && make install

# 🚀 Stage 2: immagine finale
FROM debian:bookworm-slim

LABEL maintainer="tuo_nome@esempio.com"
ENV DEBIAN_FRONTEND=noninteractive

# Dipendenze runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 \
    libpam0g \
    libcap2 \
    rsyslog \
    perl \
    openssl \
    openbsd-inetd \
    lsb-base && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 👤 Crea utente e gruppo
RUN groupadd ftpgroup && useradd -g ftpgroup -d /home/ftpusers -s /usr/sbin/nologin ftpuser

# 🔁 Logging config
RUN echo "ftp.* /var/log/pure-ftpd/pureftpd.log" >> /etc/rsyslog.conf && \
    mkdir -p /var/log/pure-ftpd

# 📥 Copia i binari custom
COPY --from=builder /usr/local/sbin/pure-ftpd /usr/sbin/pure-ftpd
COPY --from=builder /usr/local/bin/pure-pw /usr/bin/pure-pw
COPY --from=builder /usr/local/bin/pure-pwconvert /usr/bin/pure-pwconvert
COPY --from=builder /usr/local/sbin/pure-uploadscript /usr/sbin/pure-uploadscript


# 📜 Script di avvio
COPY run.sh /run.sh
RUN chmod +x /run.sh

# 📜 Script di copy
COPY upload-handler.sh /etc/pure-ftpd/upload-handler.sh
RUN chmod +x /etc/pure-ftpd/upload-handler.sh

# Volumi
VOLUME ["/home/ftpusers", "/etc/pure-ftpd/passwd"]

EXPOSE 21 30000-30009

# 🌍 Variabile per passive mode
ENV PUBLICHOST=localhost

CMD ["/run.sh", "-l", "puredb:/etc/pure-ftpd/pureftpd.pdb", "-E", "-j", "-R", "-P", "localhost"]
