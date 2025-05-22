# Docker Pure-FTPd Server

## Descrizione

Questo progetto fornisce un'immagine Docker aggiornata e moderna di [Pure-FTPd](https://www.pureftpd.org/project/pure-ftpd/), basata su Debian Bookworm e configurata per supportare utenti virtuali, TLS e modalità passive. Include anche uno script `init-users.sh` per la creazione automatica di utenti FTP multipli al primo avvio.

---

## Funzionalità principali

* Compatibile con Docker Desktop / WSL2 / Linux
* Supporto utenti virtuali (`puredb`)
* Supporto TLS (certificati self-signed o Let's Encrypt)
* Configurazione automatica tramite variabili d'ambiente
* Modalità passive configurabili
* Volume persistente per utenti e dati

---

## Avvio rapido

### 1. Build dell'immagine

```bash
docker build -t pure-ftpd .
```

### 2. Avvio del container

```bash
docker run -d \
  --name ftpd_server \
  -p 21:21 \
  -p 30000-30009:30000-30009 \
  -e "PUBLICHOST=localhost" \
  -v $(pwd)/data:/home/ftpusers \
  -v $(pwd)/passwd:/etc/pure-ftpd/passwd \
  -v $(pwd)/certs:/etc/ssl/private \
  pure-ftpd
```

> ✅ Il container userà lo script `init-users.sh` (se configurato) per creare utenti iniziali.

---

## Aggiunta automatica utenti: `init-users.sh`

Puoi definire gli utenti da creare automaticamente inserendoli in `init-users.sh`. Lo script supporta più utenti e imposta le rispettive home.

Struttura esempio:

```bash
#!/bin/bash
set -e

add_ftp_user() {
  local user="$1"
  local pass="$2"
  local dir="/home/ftpusers/$user"

  mkdir -p "$dir"
  chown ftpuser:ftpgroup "$dir"
  echo -e "$pass\n$pass" | pure-pw useradd "$user" -f /etc/pure-ftpd/passwd/pureftpd.passwd -m -u ftpuser -d "$dir"
}

add_ftp_user bob test123
add_ftp_user alice alicepwd
```

Puoi modificarlo per leggere da un file `.env` o da variabili d'ambiente.

---

## Certificati TLS

### Generazione self-signed (manuale)

```bash
mkdir -p certs
openssl dhparam -out certs/pure-ftpd-dhparams.pem 2048
openssl req -x509 -nodes -newkey rsa:2048 -sha256 \
  -keyout certs/pure-ftpd.pem \
  -out certs/pure-ftpd.pem
chmod 600 certs/pure-ftpd.pem
```

### Generazione automatica al boot

Passa queste variabili al container:

```bash
-e TLS_CN=localhost \
-e TLS_ORG="MyOrg" \
-e TLS_C=IT \
-e "ADDED_FLAGS=--tls=2"
```

### Con Let's Encrypt

```bash
cat cert.pem privkey.pem > certs/pure-ftpd.pem
```

---

## Docker Compose

### `docker-compose.yml`

```yaml
version: '3.8'
services:
  ftp:
    build: .
    container_name: pure-ftpd
    ports:
      - "21:21"
      - "30000-30009:30000-30009"
    environment:
      PUBLICHOST: localhost
      ADDED_FLAGS: "--tls=2"
      TLS_CN: localhost
      TLS_ORG: MyOrg
      TLS_C: IT
    volumes:
      - ./data:/home/ftpusers
      - ./passwd:/etc/pure-ftpd/passwd
      - ./certs:/etc/ssl/private
    restart: unless-stopped
```

---

## Logs

Per vedere i log FTP:

```bash
docker logs -f ftpd_server
```

Per log dettagliati:

```bash
-e "ADDED_FLAGS=-d -d"
```

---

## Comandi utili

### Aggiungere un utente manualmente

```bash
pure-pw useradd nomeutente -f /etc/pure-ftpd/passwd/pureftpd.passwd -m -u ftpuser -d /home/ftpusers/nomeutente
```

### Cambiare password

```bash
pure-pw passwd nomeutente -f /etc/pure-ftpd/passwd/pureftpd.passwd -m
```

### Entrare nel container

```bash
docker exec -it ftpd_server bash
```

---

## Licenza

Questo progetto è distribuito sotto licenza MIT.

---

## Crediti

Basato sul lavoro originale di [stilliard/docker-pure-ftpd](https://github.com/stilliard/docker-pure-ftpd), aggiornato per supportare le ultime versioni di Debian e Pure-FTPd, compatibile con ambienti moderni come WSL2 e Docker Desktop.
