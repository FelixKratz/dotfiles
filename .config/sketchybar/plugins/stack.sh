#!/usr/bin/env sh

# Exit if Not in Stack
CURRENT=$(yabai -m query --windows --window | jq '.["stack-index"]')
if [[ $CURRENT -eq 0 ]]; then
  sketchybar --set $NAME drawing=off
  exit 0
fi

# Use Numbers in place of Dots if the Stack is greater than 10
# Use a larger font for the unicode dots
LAST=$(yabai -m query --windows --window stack.last | jq '.["stack-index"]')
if [[ $LAST -gt 10 ]]; then
  sketchybar --set $NAME drawing=on \
                         label=$(printf "[%s/%s]" "$CURRENT" "$LAST")
  exit 0
fi

# Create Stack Indicator
declare -a dots=()
for i in $(seq 0 $(expr $LAST - 1))
do  
  if [ $(expr $CURRENT - 1) -eq $i ]; then
    dots+="􀜞"
  else 
    dots+="􀧙"
  fi
done

# Display Indicator
sketchybar --set $NAME drawing=on \
                 label=$(printf "%s" ${dots[@]})
