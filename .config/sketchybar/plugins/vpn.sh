#!/bin/bash

VPN=$(scutil --nc list | grep Connected | sed -E 's/.*"(.*)".*/\1/')

if [[ $VPN != "" ]]; then
  sketchybar --set $NAME icon=􀞚 icon.color=0xff9dd274 label="$VPN" update_freq=200
else
  sketchybar --set $NAME icon=􀞞 icon.color=0xffff6578 label="No VPN" update_freq=15
fi
