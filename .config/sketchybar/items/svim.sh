#!/usr/bin/env sh
  
sketchybar --add item svim.mode q \
           --set svim.mode popup.align=left \
                           icon= \
                           label="[!]" \
                           icon.font="Hack Nerd Font Mono:Bold:28.0" \
                           label.font="Hack Nerd Font Mono:Bold:13.0" \
                           icon.color=$ICON_COLOR \
                           script="sketchybar --set svim.mode popup.drawing=off" \
           --subscribe svim.mode front_app_switched window_focus \
           --add item svim.cmdline popup.svim.mode \
           --set svim.cmdline icon="Command: "
