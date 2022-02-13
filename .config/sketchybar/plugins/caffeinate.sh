#!/usr/bin/env bash

update() {
  if [ "$(pgrep -x "caffeinate")" = "" ]; then
    sketchybar --set $NAME icon=􀸘
  else
    sketchybar --set $NAME icon=􀸙
  fi
}

mouse_clicked() {
  if [ "$(pgrep -x "caffeinate")" = "" ]; then
    screen -d -m caffeinate
    sketchybar --set $NAME icon=􀸙
  else
    killall caffeinate
    sketchybar --set $NAME icon=􀸘
  fi
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  *) update
  ;;
esac

