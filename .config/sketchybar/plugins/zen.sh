#!/bin/sh

if [ $1 = "on" ]; then
  sketchybar --set github.bell drawing=off \
             --set apple.logo drawing=off \
             --set '/cpu.*/' drawing=off \
             --set calendar icon.drawing=off \
             --set system.yabai drawing=off \
             --set separator drawing=off \
             --set front_app drawing=off \
             --set volume_alias drawing=off \
             --set spotify.anchor updates=off drawing=off \
             --bar padding_left=18
else
  sketchybar --set github.bell drawing=on \
             --set apple.logo drawing=on \
             --set '/cpu.*/' drawing=on \
             --set calendar icon.drawing=on \
             --set separator drawing=on \
             --set front_app drawing=on \
             --set system.yabai drawing=on \
             --set volume_alias drawing=on \
             --set spotify.anchor updates=on \
             --bar padding_left=7
fi

