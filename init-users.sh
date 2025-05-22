#!/bin/bash
set -e

add_user() {
  local user="$1"
  local pass="$2"
  local dir="/home/ftpusers/$user"
  local passwd_file="/etc/pure-ftpd/passwd/pureftpd.passwd"

  if pure-pw show "$user" -f "$passwd_file" > /dev/null 2>&1; then
    echo "✅ Utente '$user' esiste già, skip."
  else
    echo "➕ Creo utente '$user'..."
    mkdir -p "$dir"
    chown ftpuser:ftpgroup "$dir"
    chmod 755 "$dir"
    echo -e "$pass\n$pass" | pure-pw useradd "$user" -f "$passwd_file" -m -u ftpuser -d "$dir"
  fi
}

add_user bob 12345
add_user alice alicepwd

# Avvio del servizio FTP
exec /run.sh -l puredb:/etc/pure-ftpd/pureftpd.pdb -E -j -R -P 127.0.0.1 -p 30000:30009 --tls=2 -c 5 -C 3
