#!/usr/bin/env sh

# This script is executed when either the mode changes,
# or the commandline changes

COLOR=0xff9dd274
if [ "$MODE" = "" ]; then
  COLOR=0xffe1e3e4
  MODE="-"
fi

DRAW_CMD="off"
if [ "$CMDLINE" != "" ]; then
  DRAW_CMD="on"
fi

sketchybar --set system.svim label="[$MODE]" \
                             label.drawing=$(if [ "$MODE" = "" ]; then echo "off"; else echo "on"; fi) \
                             icon.color=$COLOR \
                             popup.drawing=$DRAW_CMD \
           --set svim.cmdline label="$CMDLINE"
