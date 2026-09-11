#!/bin/bash

# How much sbfnk-bot has waiting for review, here or on the machine named in
# ~/.config/dotfiles/bot-host. A banner goes up when the count rises, so new
# work is noticed even with the bar out of sight.

source "$CONFIG_DIR/colors.sh"

REVIEW="$HOME/.local/bin/sbfnk-bot-review"
LAST="$HOME/.cache/sketchybar-bot-count"

[ -x "$REVIEW" ] || exit 0
[ -d /Users/Shared/sbfnk-bot/pending ] ||
  [ -s "$HOME/.config/dotfiles/bot-host" ] || exit 0

# Unreachable is not the same as nothing waiting: leave the item as it was.
N=$("$REVIEW" count 2>/dev/null) || exit 0
N=${N:-0}

PREV=$(cat "$LAST" 2>/dev/null || echo 0)
echo "$N" > "$LAST"
if [ "$N" -gt "$PREV" ]; then
  osascript -e "display notification \"$N waiting for review\" with title \"sbfnk-bot\"" \
    >/dev/null 2>&1
fi

if [ "$N" -gt 0 ]; then
  sketchybar --set "$NAME" drawing=on label="$N" icon.color="$YELLOW"
else
  sketchybar --set "$NAME" drawing=off
fi
