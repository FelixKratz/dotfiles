#!/usr/bin/env sh

sketchybar --add       event          brew_upgrade                            \
           --add       event          git_push                                \
                                                                              \
           --clone     github.label   label_template                          \
           --set       github.label   associated_space=1,5                    \
                                      label=git                               \
                                      position=left                           \
                                      drawing=on                              \
                                                                              \
           --add       item           github.bell left                        \
           --set       github.bell    associated_space=1,5                    \
                                      update_freq=180                         \
                                      icon.font="$FONT:Bold:15.0"             \
                                      icon=$BELL                              \
                                      label=$LOADING                          \
                                      label.highlight_color=$BLUE             \
                                      script="$PLUGIN_DIR/gitNotifications.sh"\
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
                                      icon.background.shadow.drawing=on       \
                                                                              \
           --add       item           github.commits left                     \
           --set       github.commits associated_space=1,5                    \
                                      update_freq=1000                        \
                                      icon.color=$GIT_NO_COMMITS              \
                                      icon.highlight_color=$GREEN             \
                                      icon.font="$FONT:Bold:16.0"             \
                                      icon=$GIT_INDICATOR                     \
                                      label=$LOADING                          \
                                      click_script="open https://github.com"  \
                                      script="$PLUGIN_DIR/githubIndicator.sh" \
           --subscribe github.commits git_push                                \
                                                                              \
           --add       item           packages left                           \
           --set       packages       update_freq=18000                       \
                                      script="$PLUGIN_DIR/package_monitor.sh" \
                                      label=$LOADING                          \
                                      icon=$PACKAGES                          \
                                      associated_space=1,5                    \
           --subscribe packages       brew_upgrade mouse.clicked              \
                                                                              \
           --add       bracket        github                                  \
                                      github.label                            \
                                      github.bell                             \
                                      github.commits                          \
                                      packages
