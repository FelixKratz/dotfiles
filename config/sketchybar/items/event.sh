#!/bin/bash

next_event=(
  icon=􀧞
  icon.font="$FONT:Bold:16.0"
  label.width=dynamic
  padding_right=10
  update_freq=60
  updates=on
  script="$PLUGIN_DIR/event.sh"
  click_script="$PLUGIN_DIR/event_click.sh"
)

sketchybar --add item next_event right \
           --set next_event "${next_event[@]}" \
           --subscribe next_event system_woke mouse.entered mouse.exited
