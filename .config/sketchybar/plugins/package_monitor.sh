#!/usr/bin/env sh
source "$HOME/.config/sketchybar/icons.sh"

update() {
  PREV=$(sketchybar --query packages | jq -r .text.label)
  sketchybar --set $NAME label=$LOADING

  # runs the outdated command and stores the output as a list variable.
  brewLIST=$(brew outdated)

  # checks to see if the returned list is empty. If so, it sets the outdated packages list to zero, if not, sets it to the line count of the list.
  if [[ $brewLIST == "" ]]; then
    BREW='0'
    brewLIST=""
  else
    BREW=$(echo "$brewLIST" | wc -l)
  fi


  # runs the outdated command and stores the output as a list variable.
  masLIST=$(mas outdated)

  # checks to see if the returned list is empty. If so, it sets the outdated packages list to zero, if not, sets it to the line count of the list.
  if [[ $masLIST == "" ]]; then
    MAS='0'
    masLIST=""
  else
    MAS=$(echo "$masLIST" | wc -l)
  fi

  DEFAULT="0"

  # sum of all outdated packages
  SUM=$(( ${BREW:-DEFAULT} + ${MAS:-DEFAULT} ))

  if [[ $SUM -gt 0 ]]; then
    FINAL="$SUM"
  else
    FINAL=$TICK
  fi

  sketchybar --set $NAME label="$FINAL"

  if [ "$FINAL" != "$PREV" ]; then
    sketchybar --animate tanh 15 --set $NAME label.y_offset=5 label.y_offset=0
  fi
}

case "$SENDER" in
  *) update 
  ;;
esac
