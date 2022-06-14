#!/usr/bin/env sh

next () {
  osascript -e 'tell application "Spotify" to play next track'
}

back () {
  osascript -e 'tell application "Spotify" to play previous track'
}

play_pause () {
  osascript -e 'tell application "Spotify" to playpause'
}

repeat () {
  REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
  if [ "$REPEAT" = "false" ]; then
    sketchybar -m --set spotify.repeat icon.highlight=on
    osascript -e 'tell application "Spotify" to set repeating to true'
  else 
    sketchybar -m --set spotify.repeat icon.highlight=off
    osascript -e 'tell application "Spotify" to set repeating to false'
  fi
}

shuffle () {
  SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
  if [ "$SHUFFLE" = "false" ]; then
    sketchybar -m --set spotify.shuffle icon.highlight=on
    osascript -e 'tell application "Spotify" to set shuffling to true'
  else 
    sketchybar -m --set spotify.shuffle icon.highlight=off
    osascript -e 'tell application "Spotify" to set shuffling to false'
  fi
}

update () {
  PLAYING=1
  if [ "$(echo "$INFO" | jq -r '.["Player State"]')" = "Playing" ]; then
    PLAYING=0
    TRACK="$(echo "$INFO" | jq -r .Name 2>/dev/null | cut -c1-20)"
    ARTIST="$(echo "$INFO" | jq -r .Artist 2>/dev/null | cut -c1-20)"
    ALBUM="$(echo "$INFO" | jq -r .Album 2>/dev/null | cut -c1-20)"
    SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
    REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
    COVER=$(osascript -e 'tell application "Spotify" to get artwork url of current track')
  fi

  args=()
  if [ $PLAYING -eq 0 ]; then
    curl -s --max-time 20 "$COVER" -o /tmp/cover.jpg
    args+=(--set spotify.play_pause icon=􀊆 \
           --set spotify.shuffle icon.highlight=$SHUFFLE \
           --set spotify.repeat icon.highlight=$REPEAT \
           --set "Control Center,Sound" popup.background.image="/tmp/cover.jpg")
  else
    args+=(--set "Control Center,Sound" popup.drawing=off \
           --set spotify.play_pause icon=􀊄)
  fi
  sketchybar -m "${args[@]}"
}

mouse_clicked () {
  case "$NAME" in
    "spotify.next") next
    ;;
    "spotify.back") back
    ;;
    "spotify.play_pause") play_pause
    ;;
    "spotify.shuffle") shuffle
    ;;
    "spotify.repeat") repeat
    ;;
    *)
    ;;
  esac
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  "forced") exit
  ;;
  *) update
  ;;
esac
