#!/usr/bin/env bash

update() {
  # This is called for all other events

}

mouse_entered() {
  sketchybar --set $NAME background.drawing=on 
}

mouse_exited() {
  sketchybar --set $NAME background.drawing=off 
}

case "$SENDER" in
  "mouse.entered") mouse_entered
  ;;
  "mouse.exited") mouse_exited
  ;;
  *) update 
  ;;
esac
