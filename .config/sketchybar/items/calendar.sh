#!/usr/bin/env sh

sketchybar --add       item               mailIndicator right                           \
           --set       mailIndicator      update_freq=30                                \
                                          script="$PLUGIN_DIR/mailIndicator.sh"         \
                                          icon.font="$FONT:Bold:16.0"                   \
                                          icon=􀍜                                        \
                                          label.padding_right=8                         \
                                          background.padding_right=0                    \
                                          label=!                                       \
                                                                                        \
           --add       alias              MeetingBar right                              \
           --set       MeetingBar         background.padding_right=-8                   \
                                          background.padding_left=-6                    \
                                          update_freq=60                                \
                                                                                        \
           --add       item               calendar.time right                           \
           --set       calendar.time      update_freq=2                                 \
                                          icon.drawing=off                              \
                                          script="$PLUGIN_DIR/time.sh"                  \
                                                                                        \
           --clone     calendar.date      label_template                                \
           --set       calendar.date      update_freq=60                                \
                                          position=right                                \
                                          label=cal                                     \
                                          drawing=on                                    \
                                          background.padding_right=0                    \
                                          script="$PLUGIN_DIR/date.sh"                  \
                                                                                        \
           --add       bracket            calendar                                      \
                                          mailIndicator                                 \
                                          MeetingBar                                    \
                                          calendar.time                                 \
                                          calendar.date                                 \
                                                                                        \
           --set       calendar           background.drawing=on
