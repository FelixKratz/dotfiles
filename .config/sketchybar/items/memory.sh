#!/usr/bin/env sh

sketchybar --add       item               topmem left                                   \
           --set       topmem             associated_space=1                            \
                                          icon.padding_left=15                          \
                                          update_freq=15                                \
                                          script="$PLUGIN_DIR/topmem.sh"
