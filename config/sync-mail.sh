#!/bin/bash
# Sync the non-work accounts in parallel, then index. Locking, the sketchybar
# spinner and the index update all live in getmail.sh.

channels=$(/opt/homebrew/bin/yq -r '.accounts[] | select(.smtp_only != true) | .name' \
    ~/.config/email/accounts.yaml | grep -vE '^work$')

# shellcheck disable=SC2086  # channel names are single words
exec "$HOME/.local/bin/getmail.sh" $channels
