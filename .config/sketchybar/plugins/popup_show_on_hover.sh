#!/usr/bin/env sh

popup() {
  sketchybar --set $NAME popup.drawing=$1
}

case "$SENDER" in
  "mouse.entered") popup on
  ;;
  "mouse.exited"|"mouse.exited.global") popup off
  ;;
  "mouse.clicked") popup toggle
  ;;
esac

