#!/usr/bin/env sh

HAS_BATTERY=$(if [ "$(pmset -g batt | grep "Battery")" = "" ]; then echo "false"; else echo "true"; fi)
SVIM_POPUP_SCRIPT="sketchybar --set system.svim popup.drawing=off"

sketchybar --add       event              window_focus                                  \
                                                                                        \
           --add       item               system.svim right                             \
           --set       system.svim        popup.align=left                              \
                                          icon=$VIM                                     \
                                          label="[!]"                                   \
                                          icon.font="Hack Nerd Font Mono:Bold:28.0"     \
                                          label.font="Hack Nerd Font Mono:Bold:13.0"    \
                                          icon.color=$ICON_COLOR                        \
                                          icon.highlight_color=$GREEN                   \
                                          script="$SVIM_POPUP_SCRIPT"                   \
           --subscribe system.svim        front_app_switched window_focus               \
                                                                                        \
           --add       item               svim.cmdline popup.system.svim                \
           --set       svim.cmdline       icon="Command: "                              \
                                                                                        \
           --add       item               system.mic right                              \
           --set       system.mic         update_freq=100                               \
                                          label.drawing=off                             \
                                          script="$PLUGIN_DIR/mic.sh"                   \
           --subscribe system.mic         mouse.clicked                                 \
                                                                                        \
           --add       bracket            system                                        \
                                          system.svim                                   \
                                          system.mic
