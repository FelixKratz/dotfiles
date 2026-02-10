#!/bin/bash
# Sync mail for a specific account using mbsync

ACCOUNT="$1"

if [[ -z "$ACCOUNT" ]]; then
  echo "Usage: getmail.sh <account>"
  exit 1
fi

# Run mbsync for the account
/opt/homebrew/bin/mbsync "$ACCOUNT" 2>&1

# Tell mu4e to reindex (mu server holds the database lock)
/opt/homebrew/bin/emacsclient -e '(mu4e-update-index)' 2>/dev/null || /opt/homebrew/bin/mu index 2>&1
