#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Read from cache file - update via: brew outdated | wc -l > /tmp/brew_outdated_count
# Or add to .zshrc: brew() { command brew "$@"; command brew outdated 2>/dev/null | wc -l | tr -d ' ' > /tmp/brew_outdated_count; }
CACHE_FILE="/tmp/brew_outdated_count"
COUNT=$(cat "$CACHE_FILE" 2>/dev/null)
[[ -z "$COUNT" ]] && COUNT="?"

COLOR=$RED

case "$COUNT" in
  [3-5][0-9]) COLOR=$ORANGE
  ;;
  [1-2][0-9]) COLOR=$YELLOW
  ;;
  [1-9]) COLOR=$WHITE
  ;;
  0) COLOR=$GREEN
     COUNT=􀆅
  ;;
esac

sketchybar --set $NAME label=$COUNT icon.color=$COLOR
