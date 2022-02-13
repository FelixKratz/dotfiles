#!/usr/bin/env bash

update() {
  DEVICE_LIST="$(system_profiler SPBluetoothDataType -json -detailLevel basic 2>/dev/null | jq '.SPBluetoothDataType' | jq '.[0]' | jq '.device_title')"
  if [ "$DEVICE_LIST" = "null" ]; then exit; fi

  DEVICES="$(echo "$DEVICE_LIST" | jq -r '.[] | keys[] as $k | "\($k) \(.[$k] | .device_isconnected) \(.[$k] | .device_minorClassOfDevice_string)"' | grep 'attrib_Yes' | grep 'Headphones')"
  
  if [ "$DEVICES" = "" ]; then
    sketchybar --set $NAME icon.drawing=off background.padding_right=0 background.padding_left=0 
  else
    DEVICES="$(echo $DEVICES | rev | cut -d" " -f3- | rev)" 
    sketchybar --set $NAME icon.drawing=on background.padding_right=1 background.padding_left=4 label="$DEVICES"
  fi
}

case "$SENDER" in
  "mouse.entered") sketchybar --set $NAME icon.background.drawing=on icon.highlight=on label.drawing=on
  ;;
  "mouse.exited") sketchybar --set $NAME icon.background.drawing=off icon.highlight=off label.drawing=off
  ;;
  *) update
  ;;
esac
