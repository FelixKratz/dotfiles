#!/usr/bin/env sh

sketchybar --add       event              brew_upgrade                             \
           --add       event              git_push                                 \
                                                                                   \
           --clone     github.label       label_template                           \
           --set       github.label       associated_space=1                       \
                                          label=git                                \
                                          position=left                            \
                                          drawing=on                               \
                                                                                   \
           --add       item               github.bell left                         \
           --set       github.bell        associated_space=1                       \
                                          update_freq=180                          \
                                          icon.font="$FONT:Bold:15.0"              \
                                          icon=􀋙                                   \
                                          label=$LOADING                           \
                                          script="$PLUGIN_DIR/gitNotifications.sh" \
                                          click_script="sketchybar --set \$NAME popup.drawing=toggle" \
                                                                                   \
           --add       item               github.commits left                      \
           --set       github.commits     associated_space=1                       \
                                          update_freq=1000                         \
                                          icon.color=0xaaffffff                    \
                                          icon.highlight_color=0xff9dd274          \
                                          icon.font="$FONT:Bold:16.0"              \
                                          icon=􀂓                                   \
                                          label=$LOADING                           \
                                          click_script="open https://github.com"   \
                                          script="$PLUGIN_DIR/githubIndicator.sh"  \
           --subscribe github.commits     git_push                                 \
                                                                                   \
           --add       item               packages left                            \
           --set       packages           update_freq=18000                        \
                                          script="$PLUGIN_DIR/package_monitor.sh"  \
                                          label=$LOADING                           \
                                          icon=􀐛                                   \
                                          associated_space=1                       \
           --subscribe packages           brew_upgrade mouse.clicked               \
                                                                                   \
           --add       bracket            github                                   \
                                          github.label                             \
                                          github.bell                              \
                                          github.commits                           \
                                          packages                                 \
                                                                                   \
           --set       github             background.drawing=on
