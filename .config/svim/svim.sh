#!/usr/bin/env sh

# This script is executed when either the mode changes,
# or the commandline changes

sketchybar --set svim.mode icon="[$MODE]" \
           --set svim.cmdline label="$CMDLINE"

if [ "$CMDLINE" != "" ]; then
  sketchybar --set svim.mode popup.drawing=on
else
  sketchybar --set svim.mode popup.drawing=off
fi

