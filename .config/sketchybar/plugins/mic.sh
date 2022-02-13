#!/usr/bin/env bash
MIC_VOLUME=$(osascript -e 'input volume of (get volume settings)')

if [[ $MIC_VOLUME -eq 0 ]]; then
  sketchybar --set $NAME icon=􀊳
elif [[ $MIC_VOLUME -gt 0 ]]; then
  sketchybar --set $NAME icon=􀊱
fi 
  
