#!/usr/bin/env sh

sketchybar --add item     calendar right                         \
           --set calendar icon=cal                               \
                          icon.font="$FONT:Black:12.0"           \
                          icon.padding_right=0                   \
                          label.padding_left=10                  \
                          background.padding_left=15             \
                          align=center                           \
                          click_script="$PLUGIN_DIR/zen.sh"
