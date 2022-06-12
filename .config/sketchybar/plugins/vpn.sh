#!/usr/bin/env sh
source "$HOME/.config/sketchybar/icons.sh"

VPN=$(scutil --nc list | grep Connected | sed -E 's/.*"(.*)".*/\1/')

if [[ $VPN != "" ]]; then
  sketchybar --set $NAME icon=$NETWORK_VPN icon.highlight=on label="$VPN" update_freq=200
else
  sketchybar --set $NAME icon=$NETWORK_NO_VPN icon.highlight=off label="No VPN" update_freq=15
fi
