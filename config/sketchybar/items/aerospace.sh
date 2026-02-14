#!/bin/bash

# AeroSpace workspace items for sketchybar

WORKSPACE_IDS=("1" "2" "3" "4" "5" "6" "7")
WORKSPACE_NAMES=("emacs" "terminal" "mail" "web" "calendar" "social" "media")

# Register the custom event from AeroSpace
sketchybar --add event aerospace_workspace_change

for i in "${!WORKSPACE_IDS[@]}"; do
  sid="${WORKSPACE_IDS[$i]}"
  name="${WORKSPACE_NAMES[$i]}"

  sketchybar --add item space.$sid left \
             --subscribe space.$sid aerospace_workspace_change \
             --set space.$sid \
                   icon="$sid" \
                   icon.padding_left=10 \
                   icon.padding_right=4 \
                   padding_left=2 \
                   padding_right=2 \
                   label.padding_right=20 \
                   icon.highlight_color=$RED \
                   label.color=$GREY \
                   label.highlight_color=$WHITE \
                   label.font="sketchybar-app-font:Regular:16.0" \
                   label.y_offset=-1 \
                   background.color=$BACKGROUND_1 \
                   background.border_color=$BACKGROUND_2 \
                   click_script="aerospace workspace $sid" \
                   script="$PLUGIN_DIR/aerospace.sh"
done
