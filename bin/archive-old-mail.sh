#!/bin/bash
# Archive work emails older than 6 years to local/Work/LSHTM/
# Protects messages from Exchange 7-year retention policy deletion
# when mbsync is set to Expunge Both.
#
# Moves files from work/INBOX (and other synced folders) to
# local/Work/LSHTM/.YYYY/ so rclone backs them up to pCloud.
# Run monthly via launchagent.

set -euo pipefail

WORK_MAILDIR="$HOME/Maildir/work"
ARCHIVE_BASE="$HOME/Maildir/local/Work/LSHTM"
YEARS_TO_KEEP=6
LOG="$HOME/.local/log/archive-old-mail.log"

mkdir -p "$(dirname "$LOG")"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG"
}

# Folders to archive from (skip Drafts)
FOLDERS=("INBOX" "Sent Items" "GitHub" "Teaching")

cutoff_date=$(date -v-${YEARS_TO_KEEP}y '+%Y-%m-%d')
log "Archiving messages older than $cutoff_date"

total_moved=0

for folder in "${FOLDERS[@]}"; do
    src="$WORK_MAILDIR/$folder/cur"
    if [ ! -d "$src" ]; then
        continue
    fi

    moved=0
    python3 -u - "$src" "$ARCHIVE_BASE" "$cutoff_date" "$folder" <<'PYTHON'
import os, sys, email.utils, datetime, shutil
from pathlib import Path

src = Path(sys.argv[1])
archive_base = Path(sys.argv[2])
cutoff_str = sys.argv[3]
folder_name = sys.argv[4]

cutoff = datetime.datetime.strptime(cutoff_str, "%Y-%m-%d").replace(tzinfo=datetime.timezone.utc)
moved = 0

for f in src.iterdir():
    if not f.is_file():
        continue
    try:
        with open(f, 'rb') as fh:
            for line in fh:
                if line.startswith(b'Date:'):
                    date_str = line.decode('utf-8', errors='replace').strip()[5:].strip()
                    parsed = email.utils.parsedate_to_datetime(date_str)
                    if parsed.tzinfo is None:
                        parsed = parsed.replace(tzinfo=datetime.timezone.utc)
                    if parsed < cutoff:
                        year = str(parsed.year)
                        # Map folder to archive subfolder
                        if folder_name == "INBOX":
                            dest_folder = f".{year}"
                        else:
                            safe_name = folder_name.lower().replace(" ", "_").replace("sent_items", "sent")
                            dest_folder = f".{safe_name}_{year}"
                        dest_dir = archive_base / dest_folder / "cur"
                        dest_dir.mkdir(parents=True, exist_ok=True)
                        # Ensure maildirfolder marker exists
                        marker = archive_base / dest_folder / "maildirfolder"
                        if not marker.exists():
                            marker.touch()
                        for subdir in ["new", "tmp"]:
                            (archive_base / dest_folder / subdir).mkdir(exist_ok=True)
                        # Move file (strip UID from filename to avoid conflicts)
                        dest = dest_dir / f.name
                        if dest.exists():
                            break  # skip duplicates
                        shutil.move(str(f), str(dest))
                        moved += 1
                    break
                if line == b'\r\n' or line == b'\n':
                    break
    except Exception as e:
        print(f"Warning: {f.name}: {e}", file=sys.stderr)

print(f"{folder_name}: moved {moved} messages", flush=True)
PYTHON

done 2>&1 | tee -a "$LOG"

log "Archive complete"

# Update notmuch index to reflect moved files
/opt/homebrew/bin/notmuch new 2>> "$LOG"
log "Notmuch index updated"
