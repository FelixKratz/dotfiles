#!/bin/bash

source "$CONFIG_DIR/colors.sh"

/opt/homebrew/bin/brew update &>/dev/null
COUNT=$(HOMEBREW_NO_AUTO_UPDATE=1 /opt/homebrew/bin/brew outdated 2>/dev/null | grep -cv 'backtrace\|Error\|Warning')
[[ -z "$COUNT" ]] && COUNT="?"

COLOR=$RED

case "$COUNT" in
  [3-5][0-9]) COLOR=$ORANGE
  ;;
  [1-2][0-9]) COLOR=$YELLOW
  ;;
  [1-9]) COLOR=$WHITE
  ;;
  0) COLOR=$GREEN
     COUNT=􀆅
  ;;
esac

sketchybar --set $NAME label=$COUNT icon.color=$COLOR
