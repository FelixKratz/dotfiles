#!/bin/bash

# Work sbfnk-bot has parked for review; hidden while there is none.
bot=(
  script="$PLUGIN_DIR/bot.sh"
  click_script="$PLUGIN_DIR/bot_click.sh"
  icon=󰚩
  icon.font="Hack Nerd Font:Bold:16.0"
  drawing=off
  update_freq=600
  updates=on
)

sketchybar --add item bot right       \
           --set bot "${bot[@]}"      \
           --subscribe bot system_woke
