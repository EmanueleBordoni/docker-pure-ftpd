#!/bin/bash

set -e

echo "🔧 Creazione directory certs..."
mkdir -p certs

echo "🔐 Generazione Diffie-Hellman params..."
openssl dhparam -out certs/pure-ftpd-dhparams.pem 2048

echo "🔐 Generazione certificato autofirmato..."
openssl req -x509 -nodes -newkey rsa:2048 -sha256 \
  -keyout certs/pure-ftpd.pem \
  -out certs/pure-ftpd.pem \
  -days 365 \
  -subj "/C=IT/ST=Italy/L=City/O=MyOrg/OU=IT/CN=ftp.local"

chown root:root certs/pure-ftpd.pem
chmod 600 certs/pure-ftpd.pem

echo "📁 Creazione directory passwd..."
mkdir -p passwd

echo "📝 Creazione file .env di esempio..."
cat <<EOF > .env
# FTP users in formato: nomeutente:password
FTP_USERS=bob:\${BOB_PASS}

# Password definite qui sotto
BOB_PASS=12345
EOF

echo "📁 Creazione directory utenti da FTP_USERS..."
mkdir -p data/bob

chmod 600 .env

echo "✅ Inizializzazione completata con l'utente bob."
