#!/usr/bin/env sh

update() {
  WINDOW=$(yabai -m query --windows --window)
  CURRENT=$(echo "$WINDOW" | jq '.["stack-index"]')

  args=()
  if [[ $CURRENT -gt 0 ]]; then
    LAST=$(yabai -m query --windows --window stack.last | jq '.["stack-index"]')
    args+=(--set $NAME icon=􀏭 label.drawing=on label=$(printf "[%s/%s]" "$CURRENT" "$LAST"))
    yabai -m config active_window_border_color 0xff72cce8

  else 
    args+=(--set $NAME label.drawing=off)
    case "$(echo "$WINDOW" | jq '.["is-floating"]')" in
      "false")
        if [ "$(echo "$WINDOW" | jq '.["has-fullscreen-zoom"]')" = "true" ]; then
          args+=(--set $NAME icon="􀏜" icon.color=0xffeacb64)
          yabai -m config active_window_border_color 0xffeacb64
        elif [ "$(echo "$WINDOW" | jq '.["has-parent-zoom"]')" = "true" ]; then
          args+=(--set $NAME icon="􀥃" icon.color=0xffff6578)
          yabai -m config active_window_border_color 0xffff6578
        else
          args+=(--set $NAME icon="􀧍" icon.color=0xff9dd274)
          yabai -m config active_window_border_color 0xff9dd274
        fi
        ;;
      "true")
        args+=(--set $NAME icon="􀢌" icon.color=0xffba9cf3)
        yabai -m config active_window_border_color 0xffba9cf3
        ;;
    esac
  fi

  sketchybar -m "${args[@]}"
}

mouse_clicked() {
  yabai -m window --toggle float
  update
}

mouse_entered() {
  sketchybar --set $NAME background.drawing=on 
}

mouse_exited() {
  sketchybar --set $NAME background.drawing=off 
}

case "$SENDER" in
  "mouse.entered") mouse_entered
  ;;
  "mouse.exited") mouse_exited
  ;;
  "mouse.clicked") mouse_clicked
  ;;
  "forced") exit 0
  ;;
  *) update 
  ;;
esac
