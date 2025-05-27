#!/bin/bash

set -e

FULLPATH="$1"
FILENAME="$(basename "$FULLPATH")"
USERNAME="$(echo "$FULLPATH" | cut -d'/' -f4)"
DEST="/s3/$USERNAME"

echo "[UPLOAD] Utente: $USERNAME, File: $FILENAME" >> /tmp/upload-handler-debug.log

mkdir -p "$DEST"

# Sposta il file e solo se riesce, registra il nome
if mv "$FULLPATH" "$DEST/$FILENAME"; then
    grep -qxF "$FILENAME" "$DEST/upload" || echo "$FILENAME" >> "$DEST/upload"
    chmod 666 "$DEST/upload"
else
    echo "[ERROR] Fallito lo spostamento di $FULLPATH" >> /tmp/upload-handler-debug.log
fi
