#!/bin/bash

# FRONT_APP_SCRIPT='[ "$SENDER" = "front_app_switched" ] && sketchybar --set $NAME label="$INFO"'

front_app=(
  label.font="$FONT:Black:12.0"
  icon.background.drawing=on
  # icon.drawing=off
  associated_display=active
  # script="$FRONT_APP_SCRIPT"
  script="$PLUGIN_DIR/front_app.sh"
)

sketchybar --add item front_app left         \
           --set front_app "${front_app[@]}" \
           --subscribe front_app front_app_switched
