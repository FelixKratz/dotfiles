sketchybar --add item volume right                             \
           --set volume script="$PLUGIN_DIR/volume.sh"         \
                        updates=on                             \
                        icon.background.drawing=on             \
                        icon.background.color=$BLUE            \
                        icon.background.height=8               \
                        icon.background.corner_radius=3        \
                        icon.width=0                           \
                        icon.align=right                       \
                        label.drawing=off                      \
                        background.drawing=on                  \
                        background.color=$OPEN_APPS_BACKGROUND \
                        background.height=8                    \
                        background.corner_radius=3             \
                        align=left                             \
           --subscribe volume volume_change

sketchybar --add alias "Control Center,Sound" right                 \
           --set "Control Center,Sound" icon.drawing=off            \
                                        label.drawing=off           \
                                        alias.color=$BLACK          \
                                        background.color=$WHITE     \
                                        background.corner_radius=13 \
                                        background.height=26        \
                                        background.padding_right=8
