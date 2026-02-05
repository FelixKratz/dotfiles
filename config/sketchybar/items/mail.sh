#!/bin/bash

mail=(
  script="$PLUGIN_DIR/mail.sh"
  icon.font="$FONT:Regular:16.0"
  update_freq=30
  updates=on
)

sketchybar --add item mail right \
           --set mail "${mail[@]}"
