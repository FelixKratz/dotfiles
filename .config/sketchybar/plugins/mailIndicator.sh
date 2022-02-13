#!/usr/bin/env bash
RUNNING=$(osascript -e 'if application "Mail" is running then return 0')
COUNT=0

if [ "$RUNNING" = "0" ]; then
  COUNT=$(osascript -e 'tell application "Mail" to return the unread count of inbox')
  if [ "$COUNT" -gt "0" ]; then
    sketchybar --set $NAME label="$COUNT" icon="􀍖"
  else
    sketchybar --set $NAME label="$COUNT" icon="􀍚"
  fi
else
  sketchybar --set $NAME label="!" icon="􀍜"
fi

