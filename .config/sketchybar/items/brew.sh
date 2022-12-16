#!/usr/bin/env sh

# Trigger the brew_udpate event when brew update or upgrade is run from cmdline
# e.g. via function in .zshrc

sketchybar --add event brew_update                 \
           --add item brew right                   \
           --set brew script="$PLUGIN_DIR/brew.sh" \
                      icon=􀐛                       \
                      label=?                      \
                      background.padding_right=10  \
          --subscribe brew brew_update

