#!/usr/bin/env sh

update() {
  sketchybar --set $NAME label="$INFO"
}

case "$SENDER" in
  "front_app_switched") update
  ;;
esac

