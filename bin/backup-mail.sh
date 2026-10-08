#!/bin/bash
# Incremental encrypted Maildir backup to pCloud via rclone
# Runs daily via launchagent
#
# Uses rclone sync with --backup-dir for versioned backup:
#   pcloud-crypt:              — current mirror of ~/Maildir/
#   pcloud-crypt:versions/YYYY-MM-DD/ — files deleted/changed on that date
#
# To restore after disaster:
#   rclone copy pcloud-crypt:versions/2026-03-11/ ~/Maildir/
# To see what was lost:
#   rclone ls pcloud-crypt:versions/2026-03-11/
# Versions are kept indefinitely; config/email/BACKUP.md shows how to prune.

LOG="$HOME/.log/backup-mail.log"
mkdir -p "$(dirname "$LOG")"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"; }

TODAY=$(date '+%Y-%m-%d')

EXCLUDES=(
  --exclude='.mbsyncstate*'
  --exclude='.notmuch/**'
  --exclude='.DS_Store'
)

log "Starting Maildir backup"

# Sync mirror with versioned backup of deleted/changed files
/opt/homebrew/bin/rclone sync \
  "${EXCLUDES[@]}" \
  --backup-dir="pcloud-crypt:versions/$TODAY" \
  --exclude='versions/**' \
  "$HOME/Maildir/" pcloud-crypt: \
  2>> "$LOG"

STATUS=$?
if [ $STATUS -eq 0 ]; then
  log "Backup complete"
else
  log "Backup failed with exit code $STATUS"
fi

log "Done"
