#!/usr/bin/env sh
#
sketchybar --add bracket status brew github.bell volume volume_alias \
           --set status background.color=$BACKGROUND_1 \
                        background.border_color=$BACKGROUND_2 \
                        background.border_width=2

sketchybar --add item divider right \
           --set divider label.drawing=off \
                         icon=􀫰 \
                         icon.font="$FONT:BLACK:22.0" \
                         background.padding_left=5 \
                         background.padding_right=10
