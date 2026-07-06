#!/bin/bash
# Sync all mail accounts in parallel, then index

LOCKDIR="$HOME/.cache/sync-mail.lock"
# Remove stale lock (older than 15 min; syncs may run up to the 10 min timelimit)
find "$LOCKDIR" -maxdepth 0 -mmin +15 -exec rmdir {} \; 2>/dev/null
mkdir "$LOCKDIR" 2>/dev/null || { echo "Already running"; exit 0; }
trap "rmdir '$LOCKDIR'" EXIT

# Get non-work, non-smtp-only accounts from accounts.yaml
channels=$(/opt/homebrew/bin/yq -r '.accounts[].name' ~/.config/email/accounts.yaml | grep -vE '^(work|princeton)$')

for channel in $channels; do
    /opt/homebrew/bin/timelimit -t 600 /opt/homebrew/bin/mbsync "$channel" &
done
wait

# Update notmuch index (always works, no server dependency)
/opt/homebrew/bin/notmuch new 2>/dev/null

# Tell mu4e to reindex if loaded (mu server holds the database lock)
/opt/homebrew/bin/emacsclient -e '(when (fboundp (quote mu4e-update-index)) (mu4e-update-index))' 2>/dev/null || /opt/homebrew/bin/mu index 2>/dev/null
