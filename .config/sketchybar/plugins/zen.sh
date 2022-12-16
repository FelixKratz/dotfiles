#!/bin/sh

zen_on() {
  sketchybar --set github.bell drawing=off \
             --set apple.logo drawing=off \
             --set '/cpu.*/' drawing=off \
             --set calendar icon.drawing=off \
             --set system.yabai drawing=off \
             --set separator drawing=off \
             --set front_app drawing=off \
             --set volume_alias drawing=off \
             --set spotify.anchor drawing=off \
             --set spotify.play updates=off \
             --set brew drawing=off \
             --set divider drawing=off
}

zen_off() {
  sketchybar --set github.bell drawing=on \
             --set apple.logo drawing=on \
             --set '/cpu.*/' drawing=on \
             --set calendar icon.drawing=on \
             --set separator drawing=on \
             --set front_app drawing=on \
             --set system.yabai drawing=on \
             --set volume_alias drawing=on \
             --set spotify.play updates=on \
             --set brew drawing=on \
             --set divider drawing=on
}

if [ "$1" = "on" ]; then
  zen_on
elif [ "$1" = "off" ]; then
  zen_off
else
  if [ "$(sketchybar --query apple.logo | jq -r ".geometry.drawing")" = "on" ]; then
    zen_on
  else
    zen_off
  fi
fi

