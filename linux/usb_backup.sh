#!/bin/bash

# === USB Incremental Backup Script using rsync ===

# === CONFIGURATION ===
SOURCE="/home/baraa/Documents/important_files/"
USB_MOUNT="/media/baraa/ESD-USB"
TARGET="$USB_MOUNT/backups/lateset"
SNAPSHOT_DIR="$USB_MOUNT/backups/snapshots"
DATE=$(date +%Y-%m-%d_%H-%M)
LOGFILE="$USB_MOUNT/backups/backup.log"

# === Check if USB is mounted ===
if [ ! -d "$USB_MOUNT" ]; then
  echo "USB drive not mounted at $USB_MOUNT" >> "$LOGFILE"
  exit 1
fi

# === Create required directories ===
mkdir -p "$TARGET"
mkdir -p "$SNAPSHOT_DIR"
touch $USB_MOUNT/backups/backup.log

# === Sync source to USB backup ===
/usr/bin/rsync -av --delete "$SOURCE" "$TARGET" >> "$LOGFILE" 2>&1

# === Create hard-linked snapshot ===
#cp -al "$TARGET" "$SNAPSHOT_DIR/backup_$DATE"

#creating hardlinks was not possible due to the format of the flash drive which is fat32 it should be ext4 to support it but the problem is unique to linux

# === Log success ===
echo "✅ Backup completed on $DATE" >> "$LOGFILE"
