#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

# While mbsync runs the spinner owns the item, so only make sure it is running
if [ -n "$(ls "$HOME/.cache/mail-sync" 2>/dev/null)" ]; then
  ("$CONFIG_DIR/plugins/mail_spinner.sh" >/dev/null 2>&1 &)
  exit 0
fi

WORK=$(notmuch count 'tag:unread AND folder:work/INBOX' 2>/dev/null || echo 0)
GITHUB=$(notmuch count 'tag:unread AND folder:work/GitHub' 2>/dev/null || echo 0)
NONWORK=$(notmuch count 'tag:unread AND (folder:/INBOX/ OR folder:/inbox/) AND NOT folder:work/INBOX AND NOT tag:spam AND NOT tag:junk' 2>/dev/null || echo 0)
QUEUE=$(ls ~/.msmtpq/*.mail 2>/dev/null | wc -l | tr -d ' ')
TOTAL=$((WORK + GITHUB + NONWORK + QUEUE))

if [ "$TOTAL" -gt 0 ]; then
  ICON=$MAIL_UNREAD
  PARTS=""
  [ "$WORK" -gt 0 ] && PARTS="w:$WORK"
  [ "$GITHUB" -gt 0 ] && PARTS="${PARTS:+$PARTS }g:$GITHUB"
  [ "$NONWORK" -gt 0 ] && PARTS="${PARTS:+$PARTS }n:$NONWORK"
  [ "$QUEUE" -gt 0 ] && PARTS="${PARTS:+$PARTS }q:$QUEUE"
  LABEL="$PARTS"
  COLOR=$BLUE
else
  ICON=$MAIL
  LABEL=""
  COLOR=$WHITE
fi

sketchybar --set $NAME icon="$ICON" icon.font="$MAIL_ICON_FONT" \
                       icon.y_offset=0 icon.width=dynamic \
                       icon.color=$COLOR label="$LABEL"
