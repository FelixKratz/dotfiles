#!/usr/bin/env bash

update() {
  args=()
  if [ "$NAME" != "space_template" ]; then
    args+=(--set $NAME label=$NAME icon.highlight=$SELECTED icon.background.drawing=$SELECTED)
  fi
  if [ "$SELECTED" = "true" ]; then
    args+=(--set spaces_$DID.label label=$NAME)
  fi

  sketchybar -m "${args[@]}" 
}

case "$SENDER" in
  "mouse.entered") sketchybar --set $NAME background.drawing=on #Inactive
  ;;
  "mouse.exited") sketchybar --set $NAME background.drawing=off #Inactive
  ;;
  *) update
  ;;
esac
