#!/bin/sh

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
    TRACK="$(echo "$INFO" | jq -r .Name | sed 's/\(.\{20\}\).*/\1.../')"
    ARTIST="$(echo "$INFO" | jq -r .Artist | sed 's/\(.\{20\}\).*/\1.../')"
    ALBUM="$(echo "$INFO" | jq -r .Album | sed 's/\(.\{25\}\).*/\1.../')"
    SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
    REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
    COVER=$(osascript -e 'tell application "Spotify" to get artwork url of current track')
  fi

  args=()
  if [ $PLAYING -eq 0 ]; then
    curl -s --max-time 20 "$COVER" -o /tmp/cover.jpg
    if [ "$ARTIST" == "" ]; then
      args+=(--set spotify.title label="$TRACK" drawing=on \
             --set spotify.album label="Podcast" drawing=on \
             --set spotify.artist label="$ALBUM" drawing=on  )
    else
      args+=(--set spotify.title label="$TRACK" drawing=on \
             --set spotify.album label="$ALBUM" drawing=on \
             --set spotify.artist label="$ARTIST" drawing=on)
    fi
    args+=(--set spotify.play icon=􀊆 \
           --set spotify.shuffle icon.highlight=$SHUFFLE \
           --set spotify.repeat icon.highlight=$REPEAT \
           --set spotify.cover background.image="/tmp/cover.jpg" \
                               background.color=0x00000000 \
           --set spotify.anchor label.drawing=on \
                                icon.drawing=off \
                                y_offset=0 \
                                background.drawing=off \
                                align=center \
                                drawing=on \
           --set spotify drawing=on                               )
  else
    args+=(--set spotify.title drawing=off \
           --set spotify.artist drawing=off \
           --set spotify.anchor drawing=off popup.drawing=off \
           --set spotify.play icon=􀊄                           )
  fi
  sketchybar -m "${args[@]}"
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
    *) exit
    ;;
  esac
}

popup () {
  sketchybar --set spotify.anchor popup.drawing=$1
}

volume_change() {
  ALREADY_DRAWING=$(sketchybar --query spotify.anchor | jq -r ".icon.drawing")

  if [ "$ALREADY_DRAWING" = "on" ]; then
    sketchybar --set spotify.anchor icon.width=$(($INFO*17/10))
  else
    source "$HOME/.config/sketchybar/colors.sh"

    sketchybar --set spotify.anchor icon.width=0 \
                                    width=0 \
                                    align=left \
                                    label.drawing=off \
                                    icon.drawing=on \
                                    background.drawing=on \
               --animate tanh 30 --set spotify.anchor icon.width=$(($INFO*17/10)) \
                                                      width=170 \
                                                      background.color=0xff494d64 \
                                                      background.corner_radius=10 \
                                                      background.height=3 \
                                                      background.corner_radius=2 \
                                                      y_offset=-16
    sleep 2
    
    sketchybar --set spotify.anchor icon.width=0 \
               --animate tanh 30 --set spotify.anchor width=20 \
                                                      background.height=20 \
                                                      background.corner_radius=10 \
                                                      background.color=$WHITE \
                                                      y_offset=0
    sleep "0.5"
    sketchybar --set spotify.anchor icon.drawing=off \
                                    background.drawing=off \
                                    label.drawing=on \
                                    width=170 \
                                    align=center
  fi
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  "mouse.entered") popup on
  ;;
  "mouse.exited"|"mouse.exited.global") popup off
  ;;
  "volume_change") volume_change
  ;;
  *) update
  ;;
esac
