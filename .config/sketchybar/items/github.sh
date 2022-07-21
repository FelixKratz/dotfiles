#!/usr/bin/env sh

sketchybar --add       event          brew_upgrade                            \
                                                                              \
           --add       item           github.bell right                       \
           --set       github.bell    associated_space=1,5                    \
                                      update_freq=180                         \
                                      icon.font="$FONT:Bold:15.0"             \
                                      icon=$BELL                              \
                                      icon.color=$GREEN                       \
                                      label=$LOADING                          \
                                      label.highlight_color=$BLUE             \
                                      script="$PLUGIN_DIR/gitNotifications.sh"\
                                      popup.align=right                       \
                                      click_script="$POPUP_CLICK_SCRIPT"      \
           --subscribe github.bell    mouse.entered                           \
                                      mouse.exited                            \
                                      mouse.exited.global                     \
                                                                              \
           --add       item           github.template popup.github.bell       \
           --set      github.template drawing=off                             \
                                      background.corner_radius=12             \
                                      background.padding_left=7               \
                                      background.padding_right=7              \
                                      background.color=$BLACK                 \
                                      background.drawing=off                  \
                                      icon.background.height=2                \
                                      icon.background.y_offset=-12            \
                                      icon.background.shadow.color=$GREY      \
                                      icon.background.shadow.angle=25         \
                                      icon.background.shadow.distance=2       \
                                      icon.background.shadow.drawing=on
