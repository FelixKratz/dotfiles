#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"

lock() {
  sketchybar --bar y_offset=-32 \
                   margin=-200 \
                   notch_width=0 \
                   blur_radius=0 \
                   color=0x000000
}

unlock() {
  sketchybar --animate sin 25 \
             --bar y_offset=0 \
                   notch_width=200 \
                   margin=0 \
                   shadow=on \
                   corner_radius=20 \
                   corner_radius=20 \
                   corner_radius=20 \
                   corner_radius=0 \
                   color=0x000000 \
                   color=0x000000 \
                   color=$BAR_COLOR \
                   blur_radius=0 \
                   blur_radius=0 \
                   blur_radius=0 \
                   blur_radius=50
}

case "$SENDER" in
  "lock") lock
  ;;
  *) unlock
  ;;
esac
