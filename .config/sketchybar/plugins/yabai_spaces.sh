#!/usr/bin/env bash
# TODO: Remove spaces that do not exist anymore

icons=("􀃉" "􀃋" "􀃍" "􀃏" "􀃑" "􀃓" "􀃕" "􀃗" "􀃙" "􀃛" "􀕒" "􀕓" "􀕔" "􀕕" "􀕖") #0 to 14
highlight_colors=("" "0xff9dd274" "0xfff69c5e" "0xff72cce8" "0xffeacb64" "0xff9dd274" "0xfff69c5e" "0xff72cce8" "0xffeacb64" "0xff9dd274" "0xfff69c5e" "0xff72cce8" "0xffeacb64" "0xff9dd274" "0xfff69c5e")

args=()
QUERY="$(yabai -m query --spaces | jq -r '.[] | [.index, .windows[0], .label, .display, .["is-visible"]] | @sh')"

NAMES=""
while read -r index window yabai_name display visible
do
  NAME="$(echo "${yabai_name}" | tr -d "'")"
  if [ "${window}" = "null" ]; then
    label="$NAME"
  else
    label="$NAME*"
  fi
  if [ "$NAME" = "" ] || [ "$NAME" = " " ]; then 
    NAME="${index}"
  fi
  
  NAMES="$NAMES $NAME"
  args+=(--clone "$NAME" space_template after \
         --set "$NAME" label="${label}" \
                       icon="${icons[${index}]}" \
                       icon.highlight_color="${highlight_colors[${index}]}" \
                       associated_display=${display} \
                       icon.highlight=${visible} \
                       drawing=on)
done <<< "$QUERY"

args+=(--reorder $NAMES)
sketchybar -m ${args[@]} &> /dev/null 
