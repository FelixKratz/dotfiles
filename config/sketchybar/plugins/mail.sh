#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

MU=/opt/homebrew/bin/mu
WORK=$($MU find 'flag:unread AND maildir:/work/INBOX' 2>/dev/null | wc -l | tr -d ' ')
PERSONAL=$($MU find 'flag:unread AND (maildir:/personal/INBOX OR maildir:/public/INBOX OR maildir:/joint/INBOX OR maildir:/sbstnfnk/INBOX OR maildir:/sebfnk/INBOX)' 2>/dev/null | wc -l | tr -d ' ')
TOTAL=$((WORK + PERSONAL))

if [ "$TOTAL" -gt 0 ]; then
  ICON=$MAIL_UNREAD
  # Show "work/personal" format, omit zeros
  if [ "$WORK" -gt 0 ] && [ "$PERSONAL" -gt 0 ]; then
    LABEL="$WORK/$PERSONAL"
  elif [ "$WORK" -gt 0 ]; then
    LABEL="w:$WORK"
  else
    LABEL="$PERSONAL"
  fi
  COLOR=$BLUE
else
  ICON=$MAIL
  LABEL=""
  COLOR=$WHITE
fi

sketchybar --set $NAME icon="$ICON" icon.color=$COLOR label="$LABEL"
