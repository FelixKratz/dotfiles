#!/usr/bin/env sh

# This script is executed when either the mode changes,
# or the commandline changes

# if [ "$MODE" = "" ]; then
#   MODE="-"
# fi
#
# DRAW_CMD="off"
# if [ "$CMDLINE" != "" ]; then
#   DRAW_CMD="on"
# fi
#
# sketchybar --set system.svim label="[$MODE]" \
#                              label.drawing=$(if [ "$MODE" = "" ]; then echo "off"; else echo "on"; fi) \
#                              icon.highlight=$(if [ "$MODE" = "-" ]; then echo "off"; else echo "on"; fi) \
#                              popup.drawing=$DRAW_CMD \
#            --set svim.cmdline label="$CMDLINE"
