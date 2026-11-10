#!/bin/bash
# Sync the non-work accounts in parallel, then index. Locking, the sketchybar
# spinner and the index update all live in getmail.sh.

BREW_PREFIX="${HOMEBREW_PREFIX:-$([ -d /opt/homebrew ] && echo /opt/homebrew || echo /usr/local)}"
channels=$("$BREW_PREFIX/bin/yq" -r '.accounts[] | select(.smtp_only != true) | .name' \
    ~/.config/email/accounts.yaml | grep -vE '^work$')

# shellcheck disable=SC2086  # channel names are single words
exec "$HOME/.local/bin/getmail.sh" $channels
