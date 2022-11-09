#!/usr/bin/env sh

WIDTH=100

volume_change() {
  INITIAL_WIDTH=$(sketchybar --query $NAME | jq ".icon.width")
  if [ "$INITIAL_WIDTH" -eq "0" ]; then
    sketchybar --animate tanh 30 --set $NAME width=$WIDTH icon.width=$INFO 
  else
    sketchybar --set $NAME icon.width=$INFO width=$WIDTH
  fi

  sleep 2
  FINAL_WIDTH=$(sketchybar --query $NAME | jq ".icon.width")
  if [ "$FINAL_WIDTH" -eq "$INFO" ]; then
    sketchybar --animate tanh 30 --set $NAME width=0 icon.width=0
  fi
}

case "$SENDER" in
  "volume_change") volume_change
  ;;
esac
