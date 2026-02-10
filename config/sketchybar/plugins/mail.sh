#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

WORK=$(notmuch count 'tag:unread AND folder:work/INBOX' 2>/dev/null || echo 0)
PERSONAL=$(notmuch count 'tag:unread AND (folder:personal/INBOX OR folder:public/INBOX OR folder:joint/INBOX OR folder:sbstnfnk/INBOX OR folder:sebfnk/INBOX)' 2>/dev/null || echo 0)
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
