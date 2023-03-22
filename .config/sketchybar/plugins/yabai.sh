#!/bin/bash

window_state() {
  source "$HOME/.config/sketchybar/colors.sh"
  source "$HOME/.config/sketchybar/icons.sh"

  WINDOW=$(yabai -m query --windows --window)
  CURRENT=$(echo "$WINDOW" | jq '.["stack-index"]')

  args=()
  if [[ $CURRENT -gt 0 ]]; then
    LAST=$(yabai -m query --windows --window stack.last | jq '.["stack-index"]')
    args+=(--set $NAME icon=$YABAI_STACK icon.color=$RED label.drawing=on drawing=on label=$(printf "[%s/%s]" "$CURRENT" "$LAST")
          --bar border_color=$RED)
  else 
    args+=(--set $NAME label.drawing=off drawing=off)
    COLOR=$BAR_BORDER_COLOR
    ICON=$YABAI_GRID
    case "$(echo "$WINDOW" | jq '.["is-floating"]')" in
      "false")
        if [ "$(echo "$WINDOW" | jq '.["has-fullscreen-zoom"]')" = "true" ]; then
          ICON=$YABAI_FULLSCREEN_ZOOM
          COLOR=$GREEN
        elif [ "$(echo "$WINDOW" | jq '.["has-parent-zoom"]')" = "true" ]; then
          ICON=$YABAI_PARENT_ZOOM
          COLOR=$BLUE
        fi
        ;;
      "true")
        ICON=$YABAI_FLOAT
        COLOR=$MAGENTA
        ;;
    esac
    args+=(--animate sin 10 --bar border_color=$COLOR)
  fi

  sketchybar -m "${args[@]}"
}

windows_on_spaces () {
  CURRENT_SPACES="$(yabai -m query --displays | jq -r '.[].spaces | @sh')"

  args=(--set spaces_bracket drawing=off --set '/space\..*/' background.drawing=on)
  while read -r line
  do
    for space in $line
    do
      icon_strip=" "
      apps=$(yabai -m query --windows --space $space | jq -r ".[].app")
      if [ "$apps" != "" ]; then
        while IFS= read -r app; do
          icon_strip+=" $($HOME/.config/sketchybar/plugins/icon_map.sh "$app")"
        done <<< "$apps"
      fi
      args+=(--set space.$space label="$icon_strip" label.drawing=on)
    done
  done <<< "$CURRENT_SPACES"

  sketchybar -m "${args[@]}"
}

mouse_clicked() {
  yabai -m window --toggle float
  window_state
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  "forced") exit 0
  ;;
  "window_focus") window_state 
  ;;
  "windows_on_spaces") windows_on_spaces
  ;;
esac
