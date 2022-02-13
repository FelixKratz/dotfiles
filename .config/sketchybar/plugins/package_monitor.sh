#!/usr/bin/env bash

update() {
  # specify the package managers you want the program to use
  # valid manager names "brew" "npm" "yarn" "apm" "mas" "pip" and "gem"
  USE='brew mas'

  # Checks to see if the brew command is avaliable and the package manager is in the enabled list above.
  if [[ -x "$(command -v brew)" ]] && [[ $USE == *"brew"* ]]; then

    # runs the outdated command and stores the output as a list variable.
    brewLIST=$(brew outdated)

    # checks to see if the returned list is empty. If so, it sets the outdated packages list to zero, if not, sets it to the line count of the list.
    if [[ $brewLIST == "" ]]; then
      BREW='0'
      brewLIST=""
    else
      BREW=$(echo "$brewLIST" | wc -l)
    fi

  fi

  # Checks to see if the pip command is avaliable and the package manager is in the enabled list above.
  if [[ -x "$(command -v pip3)" ]] && [[ $USE == *"pip3"* ]]; then

    # runs the outdated command and stores the output as a list variable.
    pipLIST=$(pip3 list --outdated)
    tempPIP=$(echo "$pipLIST" | wc -l)

    # checks to see if the returned list is empty. If so, it sets the outdated packages list to zero, if not, sets it to the line count of the list.
    if [[ $tempPIP -gt 1 ]]; then
      PIP=$(($tempPIP - 2))
    else
      PIP="0"
      pipLIST=""
    fi

  fi

  # Checks to see if the npm command is avaliable and the package manager is in the enabled list above.
  if [[ -x "$(command -v npm)" ]] && [[ $USE == *"npm"* ]]; then

    npm update &> /dev/null

    # runs the outdated command and stores the output as a list variable.
    npmLIST=$(npm outdated)

    # checks to see if the returned list is empty. If so, it sets the outdated packages list to zero, if not, sets it to the line count of the list.
    if [[ $npmLIST == "" ]]; then
      NPM='0'
      npmLIST=""
    else
      NPM=$(echo "npmLIST" | wc -l)
    fi

  fi

  # Checks to see if the yarn command is avaliable and the package manager is in the enabled list above.
  if [[ -x "$(command -v yarn)" ]] && [[ $USE == *"yarn"* ]]; then

    # runs the outdated command and stores the output as a list variable.
    yarnLIST=$(yarn outdated)

    # checks to see if the returned list is empty. If so, it sets the outdated packages list to zero, if not, sets it to the line count of the list.
    if [[ $yarnLIST == "" ]]; then
      YARN='0'
      yarnLIST=""
    else
      YARN=$(echo "$yarnLIST" | wc -l)
    fi

  fi

  # Checks to see if the apm command is avaliable and the package manager is in the enabled list above.
  if [[ -x "$(command -v apm)" ]] && [[ $USE == *"apm"* ]]; then

    apm update &> /dev/null

    # runs the outdated command and stores the output as a list variable.
    apmLIST="$(apm outdated)"

    # checks to see if the returned list is empty. If so, it sets the outdated packages list to zero, if not, sets it to the line count of the list.
    if [[ $apmLIST == *"empty"* ]]; then
      APM='0'
      apmLIST=""
    else
    tempAPM=$(echo "$apmLIST" | wc -l)
    APM=$((tempAPM - 1))
    fi

  fi

  # Checks to see if the gem command is avaliable and the package manager is in the enabled list above.
  if [[ -x "$(command -v gem)" ]] && [[ $USE == *"gem"* ]]; then

    # runs the outdated command and stores the output as a list variable.
    gemLIST=$(gem outdated)

    # checks to see if the returned list is empty. If so, it sets the outdated packages list to zero, if not, sets it to the line count of the list.
    if [[ $gemLIST == "" ]]; then
      GEM='0'
      gemLIST=""
    else
      GEM=$(echo "$gemLIST" | wc -l)
    fi

  fi

  # Checks to see if the mas command is avaliable and the package manager is in the enabled list above.
  if [[ -x "$(command -v mas)" ]] && [[ $USE == *"mas"* ]]; then

    # runs the outdated command and stores the output as a list variable.
    masLIST=$(mas outdated)

    # checks to see if the returned list is empty. If so, it sets the outdated packages list to zero, if not, sets it to the line count of the list.
    if [[ $masLIST == "" ]]; then
      MAS='0'
      masLIST=""
    else
      MAS=$(echo "$masLIST" | wc -l)
    fi

  fi

  DEFAULT="0"

  # sum of all outdated packages
  SUM=$(( ${BREW:-DEFAULT} + ${CASK:-DEFAULT} + ${PIP:-DEFAULT} + ${NPM:-DEFAULT} + ${YARN:-DEFAULT} + ${APM:-DEFAULT} + ${GEM:-DEFAULT} + ${MAS:-DEFAULT} ))

  # icon to be displayed if no packages are outdated. Change to `ZERO=""` if you want the widget to be invisible when no packages are out of date. Default: ✔︎
  ZERO="✔︎"

  if [[ $SUM -gt 0 ]]; then
    FINAL="$SUM"
  else
    FINAL="$ZERO"
  fi

  sketchybar --set $NAME label="$FINAL"
}

mouse_clicked() {
  sketchybar --set $NAME label=􀖇
  update
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  *) update 
  ;;
esac
