#!/usr/bin/env sh

sketchybar --add       event              window_focus                                  \
           --add       event              monocle                                       \
           --add       event              battery                                       \
           --add       event              wifi                                          \
                                                                                        \
           --clone     system.label       label_template                                \
           --set       system.label       label=sys                                     \
                                          position=left                                 \
                                          drawing=on                                    \
                                          script="$PLUGIN_DIR/window_title.sh"          \
           --subscribe system.label       front_app_switched                            \
                                                                                        \
           --add       alias              "Control Center,Battery" left                 \
           --set "Control Center,Battery" update_freq=2                                 \
                                          drawing=$HAS_BATTERY                          \
                                          icon.padding_left=-5                          \
                                          label.drawing=off                             \
                                          background.padding_left=0                     \
                                          background.padding_right=-3                   \
                                          click_script="sketchybar -m --set \"\$NAME\" popup.drawing=toggle; sketchybar --trigger battery" \
                                                                                        \
           --add       item               battery.details popup."Control Center,Battery"\
           --set       battery.details    updates=$HAS_BATTERY                          \
                                          script="$PLUGIN_DIR/battery.sh"               \
                                          label.padding_right=8                         \
           --subscribe battery.details    battery                                       \
                                                                                        \
           --add       alias              "Control Center,WiFi" left                    \
           --set    "Control Center,WiFi" update_freq=3                                 \
                                          icon.drawing=off                              \
                                          label.drawing=off                             \
                                          background.padding_left=-4                    \
                                          background.padding_right=-4                   \
                                          click_script="sketchybar -m --set \"\$NAME\" popup.drawing=toggle; sketchybar --trigger wifi" \
                                                                                        \
           --add       item               wifi.details popup."Control Center,WiFi"      \
           --set       wifi.details       updates=on                                    \
                                          script="$PLUGIN_DIR/wifi.sh"                  \
                                          label.padding_right=5                         \
           --subscribe wifi.details       wifi                                          \
                                                                                        \
           --add       alias              "Control Center,Sound" left                   \
           --set   "Control Center,Sound" update_freq=2                                 \
                                          icon.drawing=off                              \
                                          label.drawing=off                             \
                                          background.padding_left=-4                    \
                                          background.padding_right=-4                   \
                                                                                        \
           --add       item               system.mic left                               \
           --set       system.mic         update_freq=100                               \
                                          label.drawing=off                             \
                                          script="$PLUGIN_DIR/mic.sh"                   \
                                          click_script="$PLUGIN_DIR/mic_click.sh"       \
                                                                                        \
           --add       item               system.caffeinate left                        \
           --set       system.caffeinate  update_freq=100                               \
                                          icon=$LOADING                                 \
                                          label.drawing=off                             \
                                          script="$PLUGIN_DIR/caffeinate.sh"            \
           --subscribe system.caffeinate  mouse.clicked                                 \
                                                                                        \
           --add       item               system.yabai left                             \
           --set       system.yabai       script="$PLUGIN_DIR/yabai.sh"                 \
                                          icon.font="$FONT:Bold:16.0"                   \
                                          label.drawing=off                             \
                                          updates=on                                    \
           --subscribe system.yabai       window_focus monocle mouse.clicked            \
                                                                                        \
           --add       bracket            system                                        \
                                          system.label                                  \
                                          "Control Center,Battery"                      \
                                          "Control Center,WiFi"                         \
                                          "Control Center,Sound"                        \
                                          system.mic                                    \
                                          system.caffeinate                             \
                                          system.yabai                                  \
                                                                                        \
           --set       system             background.drawing=on
