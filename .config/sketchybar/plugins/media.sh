#!/bin/bash

update_media() {
  STATE="$(echo "$INFO" | jq -r '.state')"

  if [ "$STATE" = "playing" ]; then
    APP=$(echo "$INFO" | jq -r '.app')
    BUNDLE_ID="$(osascript -e "id of app \"$APP\"")"
    MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"
    sketchybar --set $NAME icon.background.image="app.$BUNDLE_ID" label="$MEDIA" drawing=on
  else
    sketchybar --set $NAME drawing=off
  fi
}

case "$SENDER" in
  "media_change") update_media
  ;;
esac
