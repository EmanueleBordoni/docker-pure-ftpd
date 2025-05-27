#!/bin/bash

set -e

echo "🔧 Creazione directory certs..."
mkdir -p certs

echo "🔐 Generazione Diffie-Hellman params..."
openssl dhparam -out certs/pure-ftpd-dhparams.pem 2048

echo "🔐 Generazione certificato autofirmato..."
source .env

SUBJ="/C=${CERT_C}/ST=${CERT_ST}/L=${CERT_L}/O=${CERT_O}/OU=${CERT_OU}/CN=${CERT_CN}"

echo "🔐 Generazione certificato autofirmato..."
openssl req -x509 -nodes -newkey rsa:2048 -sha256 \
  -keyout certs/pure-ftpd.pem \
  -out certs/pure-ftpd.pem \
  -days 365 \
  -subj "$SUBJ"

chown root:root certs/pure-ftpd.pem
chmod 600 certs/pure-ftpd.pem

echo "📁 Creazione directory passwd..."
mkdir -p passwd

#echo "📝 Creazione file .env..."
#cat <<EOF > .env
## Questo file viene generato automaticamente
#FTP_USERS=

echo "✅ Inizializzazione completata."