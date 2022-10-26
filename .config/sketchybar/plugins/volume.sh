#!/usr/bin/env sh

WIDTH=100

volume_change() {
  case "$INFO" in
    [1-9][0-9]|100) ICON=􀥒
    ;;
    [1-9]) ICON=􀻂
    ;;
    0) ICON=􀫡
    ;;
  esac
  sketchybar --set volume_icon icon=$ICON
  INITIAL_WIDTH=$(sketchybar --query volume | jq ".icon.width")
  if [ "$INITIAL_WIDTH" -eq "0" ]; then
    sketchybar --animate tanh 30 --set volume width=$WIDTH icon.width=$INFO 
  else
    sketchybar --set volume icon.width=$INFO width=$WIDTH
  fi

  sleep 2
  FINAL_WIDTH=$(sketchybar --query volume | jq ".icon.width")
  if [ "$FINAL_WIDTH" -eq "$INFO" ]; then
    sketchybar --animate tanh 30 --set volume width=0 icon.width=0
  fi
}

case "$SENDER" in
  "volume_change") volume_change
  ;;
esac
