#!/bin/bash
# Sync mail for a specific account using mbsync, then update both indexes

ACCOUNT="$1"

if [[ -z "$ACCOUNT" ]]; then
  echo "Usage: getmail.sh <account>"
  exit 1
fi

# Run mbsync for the account
/opt/homebrew/bin/mbsync "$ACCOUNT" 2>&1

# Update notmuch index (always works, no server dependency)
/opt/homebrew/bin/notmuch new 2>/dev/null

# Tell mu4e to reindex if loaded (mu server holds the database lock)
/opt/homebrew/bin/emacsclient -e '(when (fboundp (quote mu4e-update-index)) (mu4e-update-index))' 2>/dev/null || /opt/homebrew/bin/mu index 2>/dev/null
