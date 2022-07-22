#!/usr/bin/env sh

sketchybar --add   item          mailIndicator right                   \
           --set   mailIndicator update_freq=30                        \
                                 script="$PLUGIN_DIR/mailIndicator.sh" \
                                 background.padding_left=10             \
                                 icon.font="$FONT:Bold:16.0"           \
                                 icon=$MAIL                            \
                                 icon.color=$BLUE                      \
                                 label=!                               \
                                                                       \
           --add   item          calendar.time right                   \
           --set   calendar.time update_freq=15                        \
                                 icon.drawing=off                      \
                                 label.color=$BLACK                    \
                                 width=60                              \
                                 align=center                          \
                                 script="$PLUGIN_DIR/time.sh"          \
                                                                       \
           --add item calendar.date right                              \
           --set   calendar.date update_freq=60                        \
                                 position=right                        \
                                 label=cal                             \
                                 label.color=$BLACK                    \
                                 label.font="$FONT:Black:12.0"         \
                                 drawing=on                            \
                                 background.padding_right=0            \
                                 script="$PLUGIN_DIR/date.sh"          \
                                                                       \
           --add   bracket       calendar                              \
                                 calendar.time                         \
                                 calendar.date                         \
           --set   calendar      background.color=0xffb8c0e0           \
                                 background.height=26                  \
                                 background.corner_radius=11

