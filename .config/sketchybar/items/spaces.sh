#!/usr/bin/env sh

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10")

sid=0
for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))
  sketchybar --add space      space.$sid left                               \
             --set space.$sid associated_space=$sid                         \
                              icon=${SPACE_ICONS[i]}                        \
                              icon.padding_left=22                          \
                              icon.padding_right=22                         \
                              label.padding_right=33                        \
                              icon.highlight_color=$RED                     \
                              background.padding_left=-8                    \
                              background.padding_right=-8                   \
                              background.height=26                          \
                              background.corner_radius=9                    \
                              background.color=$SPACE_BACKGROUND            \
                              background.drawing=on                         \
                              label.font="sketchybar-app-font:Regular:16.0" \
                              label.background.height=26                    \
                              label.background.drawing=on                   \
                              label.background.color=$OPEN_APPS_BACKGROUND  \
                              label.background.corner_radius=9              \
                              label.drawing=off                             \
                              script=""                                     \
                              mach_helper="$HELPER"                         \
                              click_script="$SPACE_CLICK_SCRIPT"
done

sketchybar   --add item       separator left                          \
             --set separator  icon=                                  \
                              icon.font="Hack Nerd Font:Regular:16.0" \
                              background.padding_left=26              \
                              background.padding_right=15             \
                              label.drawing=off                       \
                              associated_display=active               \
                              icon.color=$WHITE
