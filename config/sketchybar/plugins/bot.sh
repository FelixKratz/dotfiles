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

# Out of reach (away from its network) there is no count to show: a grey
# question mark, and no nudge repeating a number that may be long out of date.
if ! N=$("$REVIEW" count 2>/dev/null); then
  sketchybar --set "$NAME" drawing=on label="?" icon.color="$GREY"
  [ -x "$HOME/.local/bin/nudge" ] && "$HOME/.local/bin/nudge" clear sbfnk-bot \
    >/dev/null 2>&1
  exit 0
fi
N=${N:-0}

PREV=$(cat "$LAST" 2>/dev/null || echo 0)
echo "$N" > "$LAST"
if [ "$N" -gt "$PREV" ]; then
  osascript -e "display notification \"$N waiting for review\" with title \"sbfnk-bot\"" \
    >/dev/null 2>&1
fi

# The shell greeting's nudge says the same, so it cannot lag an hour behind.
NUDGE="$HOME/.local/bin/nudge"
if [ "$N" -gt 0 ]; then
  sketchybar --set "$NAME" drawing=on label="$N" icon.color="$YELLOW"
  [ -x "$NUDGE" ] && "$NUDGE" raise sbfnk-bot -p 30 -k sbfnk-bot-waiting \
    "sbfnk-bot: $N to review — sbr" >/dev/null 2>&1
else
  sketchybar --set "$NAME" drawing=off
  [ -x "$NUDGE" ] && "$NUDGE" clear sbfnk-bot >/dev/null 2>&1
fi
