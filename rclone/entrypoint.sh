#!/bin/sh
# Monta cada nube en solo lectura y reintenta si el montaje falla o se cae.

montar() {
  remoto="$1"
  destino="$2"
  while true; do
    fusermount3 -uz "$destino" 2>/dev/null
    rclone mount "$remoto:" "$destino" \
      --read-only \
      --allow-other \
      --uid "${PUID:-1000}" --gid "${PGID:-1000}" \
      --vfs-cache-mode minimal \
      --dir-cache-time 5m \
      --log-level NOTICE
    echo "$(date '+%F %T') $remoto no está montado; reintento en 60s"
    sleep 60
  done
}

desmontar() {
  fusermount3 -uz /mnt/gdrive/temp2010 2>/dev/null
  fusermount3 -uz /mnt/gdrive/temp2010g 2>/dev/null
  fusermount3 -uz /mnt/onedrive 2>/dev/null
  exit 0
}

trap desmontar TERM INT

montar gdrive_temp2010 /mnt/gdrive/temp2010 &
montar gdrive_temp2010g /mnt/gdrive/temp2010g &
montar onedrive_temp2010 /mnt/onedrive &

wait
