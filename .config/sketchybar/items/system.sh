#!/usr/bin/env sh

sketchybar --add       event              window_focus                                  \
           --add       event              monocle                                       \
           --add       event              battery                                       \
           --add       event              wifi                                          \
                                                                                        \
           --add       item               system.yabai q                                \
           --set       system.yabai       script="$PLUGIN_DIR/yabai.sh"                 \
                                          icon.font="$FONT:Bold:16.0"                   \
                                          label.drawing=off                             \
                                          width=30                                      \
                                          align=center                                  \
                                          updates=on                                    \
           --subscribe system.yabai       window_focus monocle mouse.clicked            \
                                                                                        \
           --clone     system.label       label_template                                \
           --set       system.label       label=sys                                     \
                                          position=q                                    \
                                          drawing=on                                    \
                                          background.padding_right=3                    \
                                          script="$PLUGIN_DIR/window_title.sh"          \
           --subscribe system.label       front_app_switched                            \
                                                                                        \
           --add       alias              "Control Center,Battery" e                    \
           --set "Control Center,Battery" update_freq=2                                 \
                                          drawing=$HAS_BATTERY                          \
                                          label.drawing=off                             \
                                          background.padding_right=-3                   \
                                          background.padding_left=-9                    \
                                          click_script="sketchybar -m --set \"\$NAME\" popup.drawing=toggle; sketchybar --trigger battery" \
                                          popup.align=right                             \
                                                                                        \
           --add       item               battery.details popup."Control Center,Battery"\
           --set       battery.details    updates=$HAS_BATTERY                          \
                                          script="$PLUGIN_DIR/battery.sh"               \
                                          label.padding_right=8                         \
           --subscribe battery.details    battery                                       \
                                                                                        \
           --add       alias              "Control Center,WiFi" e                       \
           --set    "Control Center,WiFi" update_freq=2                                 \
                                          icon.drawing=off                              \
                                          label.drawing=off                             \
                                          background.padding_left=-4                    \
                                          background.padding_right=-4                   \
                                          click_script="sketchybar -m --set \"\$NAME\" popup.drawing=toggle; sketchybar --trigger wifi" \
                                          popup.align=right                             \
                                                                                        \
           --add       item               wifi.details popup."Control Center,WiFi"      \
           --set       wifi.details       updates=on                                    \
                                          script="$PLUGIN_DIR/wifi.sh"                  \
                                          label.padding_right=5                         \
           --subscribe wifi.details       wifi                                          \
                                                                                        \
           --add       alias              "Control Center,Sound" e                      \
           --set   "Control Center,Sound" update_freq=2                                 \
                                          icon.drawing=off                              \
                                          label.drawing=off                             \
                                          background.padding_left=-4                    \
                                          background.padding_right=-4                   \
                                          click_script="sketchybar --set \"\$NAME\" popup.drawing=toggle" \
                                          popup.horizontal=on                           \
                                          popup.align=right                             \
                                                                                        \
           --add       item               system.mic e                                  \
           --set       system.mic         update_freq=100                               \
                                          label.drawing=off                             \
                                          script="$PLUGIN_DIR/mic.sh"                   \
                                          click_script="$PLUGIN_DIR/mic_click.sh"
