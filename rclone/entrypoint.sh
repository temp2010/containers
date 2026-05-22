#!/bin/bash
set -e

rclone mount gdrive_temp2010: /mnt/gdrive/temp2010 --allow-other --vfs-cache-mode full &
rclone mount gdrive_temp2010g: /mnt/gdrive/temp2010g --allow-other --vfs-cache-mode full &
rclone mount onedrive_temp2010: /mnt/onedrive/temp2010 --allow-other --vfs-cache-mode full &

wait -n
