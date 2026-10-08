#!/bin/bash

# AeroSpace workspace items for sketchybar

WORKSPACE_IDS=("1" "2" "3" "4" "5" "6" "7" "8" "9")
WORKSPACE_NAMES=("emacs" "terminal" "mail" "web" "calendar" "social" "media" "misc" "misc")

# Register the custom event from AeroSpace
sketchybar --add event aerospace_workspace_change

# Each display gets its own items, so its bar can highlight the workspace that
# display shows rather than the one focused on another screen.
DISPLAY_IDS=$(sketchybar --query displays | sed -n 's/.*"arrangement-id":\([0-9]*\).*/\1/p')

for did in $DISPLAY_IDS; do
for i in "${!WORKSPACE_IDS[@]}"; do
  sid="${WORKSPACE_IDS[$i]}"
  name="${WORKSPACE_NAMES[$i]}"
  item="space.$did.$sid"

  sketchybar --add item $item left \
             --subscribe $item aerospace_workspace_change \
             --set $item \
                   display=$did \
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
                   click_script="aerospace focus-monitor $did && aerospace summon-workspace $sid" \
                   script="$PLUGIN_DIR/aerospace.sh"
done
done

# Items are made per display at startup, so rebuild when screens change.
sketchybar --add item displays_watcher left \
           --set displays_watcher drawing=off \
                 script='[ "$SENDER" = display_change ] && sketchybar --reload' \
           --subscribe displays_watcher display_change
