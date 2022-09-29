#!/usr/bin/env bash

DISPLAY_INFO="$(yabai -m query --displays)"
CURRENT_SPACES="$(yabai -m query --displays | jq -r '.[].spaces | @sh')"

args=()
while read -r line
do
  for space in $line
  do
    icon_strip=" "
    apps=$(yabai -m query --windows --space $space | jq -r ".[].app")
    for app in $apps
    do
      icon_strip+=" $($HOME/.config/yabai/icon_map.sh "$app")"
    done
    args+=(--set space.$space label="$icon_strip" label.drawing=on)
  done
done <<< "$CURRENT_SPACES"

sketchybar -m "${args[@]}"
