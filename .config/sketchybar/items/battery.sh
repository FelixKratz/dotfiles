#!/bin/sh

sketchybar --add item battery right                             \
           --set battery script="$PLUGIN_DIR/battery.sh"        \
                         icon.font="$FONT:Regular:19.0"         \
                         padding_right=5                        \
                         padding_left=0                         \
                         label.drawing=off                      \
                         update_freq=120                        \
                         updates=on                             \
            --subscribe battery power_source_change system_woke
