#!/bin/bash

mail=(
  script="$PLUGIN_DIR/mail.sh"
  icon.font="$MAIL_ICON_FONT"
  click_script="$HOME/.local/bin/getmail.sh all >> $HOME/.log/getmail.log 2>&1 &"
  update_freq=30
  updates=on
)

sketchybar --add event mail_sync         \
           --add item mail right         \
           --set mail "${mail[@]}"       \
           --subscribe mail mail_sync system_woke
