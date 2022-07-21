#!/usr/bin/env sh

sketchybar --add   item          cpu.topproc right                  \
           --set   cpu.topproc   label.font="$FONT:Semibold:7"      \
                                 label=CPU                          \
                                 icon.drawing=off                   \
                                 width=0                            \
                                 y_offset=6                         \
                                 background.padding_right=15        \
                                 associated_space=1                 \
                                 update_freq=5                      \
                                 script="$PLUGIN_DIR/topproc.sh"    \
                                                                    \
           --add   item          cpu.percent right                  \
           --set   cpu.percent   label.font="$FONT:Heavy:12"        \
                                 label=CPU                          \
                                 y_offset=-4                        \
                                 width=40                           \
                                 icon.drawing=off                   \
                                 update_freq=2                      \
                                 background.padding_right=15        \
                                 associated_space=1                 \
                                                                    \
           --add   graph         cpu.sys right 100                  \
           --set   cpu.sys       associated_space=1                 \
                                 width=0                            \
                                 graph.color=$RED                   \
                                 graph.fill_color=$RED              \
                                 label.drawing=off                  \
                                 icon.drawing=off                   \
                                                                    \
           --add   graph         cpu.user right 100                 \
           --set   cpu.user      graph.color=$BLUE                  \
                                 update_freq=2                      \
                                 associated_space=1                 \
                                 label.drawing=off                  \
                                 icon.drawing=off                   \
                                 script="$PLUGIN_DIR/cpu.sh"
