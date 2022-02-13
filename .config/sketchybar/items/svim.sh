#!/usr/bin/env sh
  

sketchybar --add item svim.mode right \
           --set svim.mode popup.align=right \
                           script="sketchybar --set svim.mode popup.drawing=off" \
           --subscribe svim.mode front_app_switched window_focus \
           --add item svim.cmdline popup.svim.mode \
           --set svim.cmdline icon="Command: "
