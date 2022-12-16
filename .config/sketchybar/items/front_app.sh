#!/usr/bin/env sh

FRONT_APP_SCRIPT='sketchybar --set $NAME label="$INFO"'

sketchybar --add       event        window_focus                  \
           --add       event        windows_on_spaces             \
           --add       item         system.yabai left             \
           --set       system.yabai script="$PLUGIN_DIR/yabai.sh" \
                                    icon.font="$FONT:Bold:16.0"   \
                                    label.drawing=off             \
                                    icon.width=30                 \
                                    icon=$YABAI_GRID              \
                                    icon.color=$ORANGE            \
                                    associated_display=active     \
           --subscribe system.yabai window_focus                  \
                                    windows_on_spaces             \
                                    mouse.clicked                 \
                                                                  \
           --add       item         front_app left                \
           --set       front_app    script="$FRONT_APP_SCRIPT"    \
                                    icon.drawing=off              \
                                    background.padding_left=0     \
                                    label.color=$WHITE            \
                                    label.font="$FONT:Black:12.0" \
                                    associated_display=active     \
           --subscribe front_app    front_app_switched

