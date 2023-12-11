#!/bin/bash

if [ "$SENDER" = "front_app_switched" ]; then
  # Set the app name and app icon and then animate a bounce for the icon size
  sketchybar --set $NAME label="$INFO" icon.background.image="app.$INFO" \
             --animate tanh 10 --set $NAME icon.background.image.scale=1.2 \
                                           icon.background.image.scale=1
fi
