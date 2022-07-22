#!/usr/bin/env sh

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10")

for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))
  sketchybar --add space space.$sid left                         \
             --set space.$sid associated_space=$sid              \
                              icon=${SPACE_ICONS[i]}             \
                              icon.padding_left=22               \
                              icon.padding_right=22              \
                              icon.highlight_color=$RED          \
                              background.padding_left=-8         \
                              background.padding_right=-8        \
                              background.height=26               \
                              background.corner_radius=9         \
                              background.color=0xff3C3E4F        \
                              background.drawing=on              \
                              label.drawing=off                  \
                              click_script="$SPACE_CLICK_SCRIPT"
done

sketchybar --add item space_separator left                               \
           --set space_separator icon=                                  \
                                 icon.font="Hack Nerd Font:Regular:16.0" \
                                 background.padding_left=26              \
                                 background.padding_right=15             \
                                 label.drawing=off                       \
                                 icon.color=$WHITE                       \
                                                                         \
           --add       event        window_focus                         \
           --add       item         system.yabai left                    \
           --set       system.yabai script="$PLUGIN_DIR/yabai.sh"        \
                                    icon.font="$FONT:Bold:16.0"          \
                                    label.drawing=off                    \
                                    icon.width=30                        \
                                    icon=$YABAI_GRID                     \
                                    icon.color=$GREEN                    \
                                    updates=on                           \
           --subscribe system.yabai window_focus mouse.clicked           \
                                                                         \
           --add item window_title left                                  \
           --set window_title script="$PLUGIN_DIR/window_title.sh"       \
                              icon.drawing=off                           \
                              background.padding_left=0                  \
                              label.color=$WHITE                         \
                              label.font="$FONT:Black:12.0"              \
           --subscribe window_title front_app_switched
