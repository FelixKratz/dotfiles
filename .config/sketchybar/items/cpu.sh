#!/usr/bin/env sh

sketchybar --add   item          cpu.separator right                \
           --set   cpu.separator icon.drawing=off                   \
                                 label.drawing=off                  \
                                 background.padding_left=0          \
                                 background.padding_right=0         \
                                 associated_space=1                 \
                                                                    \
           --add   item          cpu.topproc right                  \
           --set   cpu.topproc   label.font="$FONT:Semibold:7"      \
                                 label=CPU                          \
                                 icon.drawing=off                   \
                                 width=0                            \
                                 y_offset=6                         \
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
                                 associated_space=1                 \
                                                                    \
           --add   graph         cpu.sys right 100                  \
           --set   cpu.sys       associated_space=1                 \
                                 width=0                            \
                                 graph.color=$RED                   \
                                 label.drawing=off                  \
                                 icon.drawing=off                   \
                                                                    \
           --add   graph         cpu.user right 100                 \
           --set   cpu.user      graph.color=$BLUE                  \
                                 update_freq=2                      \
                                 associated_space=1                 \
                                 label.drawing=off                  \
                                 icon.drawing=off                   \
                                 script="$PLUGIN_DIR/cpu.sh"        \
                                                                    \
           --clone cpu.label     label_template                     \
           --set   cpu.label     associated_space=1                 \
                                 label=cpu                          \
                                 position=right                     \
                                 drawing=on                         \
                                                                    \
           --add   bracket       cpu                                \
                                 cpu.separator                      \
                                 cpu.topproc                        \
                                 cpu.percent                        \
                                 cpu.user                           \
                                 cpu.sys                            \
                                 cpu.label
