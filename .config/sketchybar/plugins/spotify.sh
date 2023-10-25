#!/bin/bash

next ()
{
  osascript -e 'tell application "Spotify" to play next track'
}

back () 
{
  osascript -e 'tell application "Spotify" to play previous track'
}

play () 
{
  osascript -e 'tell application "Spotify" to playpause'
}

repeat () 
{
  REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
  if [ "$REPEAT" = "false" ]; then
    sketchybar -m --set spotify.repeat icon.highlight=on
    osascript -e 'tell application "Spotify" to set repeating to true'
  else 
    sketchybar -m --set spotify.repeat icon.highlight=off
    osascript -e 'tell application "Spotify" to set repeating to false'
  fi
}

shuffle () 
{
  SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
  if [ "$SHUFFLE" = "false" ]; then
    sketchybar -m --set spotify.shuffle icon.highlight=on
    osascript -e 'tell application "Spotify" to set shuffling to true'
  else 
    sketchybar -m --set spotify.shuffle icon.highlight=off
    osascript -e 'tell application "Spotify" to set shuffling to false'
  fi
}

update ()
{
  PLAYING=1
  if [ "$(echo "$INFO" | jq -r '.["Player State"]')" = "Playing" ]; then
    PLAYING=0
    TRACK="$(echo "$INFO" | jq -r .Name)"
    ARTIST="$(echo "$INFO" | jq -r .Artist)"
    ALBUM="$(echo "$INFO" | jq -r .Album)"
    SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
    REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
    COVER=$(osascript -e 'tell application "Spotify" to get artwork url of current track')
  fi

  args=()
  if [ $PLAYING -eq 0 ]; then
    curl -s --max-time 20 "$COVER" -o /tmp/cover.jpg
    if [ "$ARTIST" == "" ]; then
      args+=(--set spotify.title label="$TRACK"
             --set spotify.album label="Podcast"
             --set spotify.artist label="$ALBUM"  )
    else
      args+=(--set spotify.title label="$TRACK"
             --set spotify.album label="$ALBUM"
             --set spotify.artist label="$ARTIST")
    fi
    args+=(--set spotify.play icon=􀊆
           --set spotify.shuffle icon.highlight=$SHUFFLE
           --set spotify.repeat icon.highlight=$REPEAT
           --set spotify.cover background.image="/tmp/cover.jpg"
                               background.color=0x00000000
           --set spotify.anchor drawing=on                      )
  else
    args+=(--set spotify.anchor drawing=off popup.drawing=off
           --set spotify.play icon=􀊄                         )
  fi
  sketchybar -m "${args[@]}"
}

scrubbing() {
  DURATION_MS=$(osascript -e 'tell application "Spotify" to get duration of current track')
  DURATION=$((DURATION_MS/1000))

  TARGET=$((DURATION*PERCENTAGE/100))
  osascript -e "tell application \"Spotify\" to set player position to $TARGET"
  sketchybar --set spotify.state slider.percentage=$PERCENTAGE
}

scroll() {
  DURATION_MS=$(osascript -e 'tell application "Spotify" to get duration of current track')
  DURATION=$((DURATION_MS/1000))

  FLOAT="$(osascript -e 'tell application "Spotify" to get player position')"
  TIME=${FLOAT%.*}
  
  sketchybar --animate linear 10 \
             --set spotify.state slider.percentage="$((TIME*100/DURATION))" \
                                 icon="$(date -r $TIME +'%M:%S')" \
                                 label="$(date -r $DURATION +'%M:%S')"
}

mouse_clicked () {
  case "$NAME" in
    "spotify.next") next
    ;;
    "spotify.back") back
    ;;
    "spotify.play") play
    ;;
    "spotify.shuffle") shuffle
    ;;
    "spotify.repeat") repeat
    ;;
    "spotify.state") scrubbing
    ;;
    *) exit
    ;;
  esac
}

popup () {
  sketchybar --set spotify.anchor popup.drawing=$1
}

routine() {
  case "$NAME" in
    "spotify.state") scroll
    ;;
    *) update
    ;;
  esac
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  "mouse.entered") popup on
  ;;
  "mouse.exited"|"mouse.exited.global") popup off
  ;;
  "routine") routine
  ;;
  "forced") exit 0
  ;;
  *) update
  ;;
esac
