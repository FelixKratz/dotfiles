#!/bin/bash

if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set $NAME label="$INFO" icon.background.image="app.$INFO"
fi
