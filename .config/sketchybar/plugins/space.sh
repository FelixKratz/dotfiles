#!/usr/bin/env sh

args=()
if [ "$NAME" != "space_template" ]; then
  args+=(--set $NAME label=$NAME \
                     icon.highlight=$SELECTED)
fi

if [ "$SELECTED" = "true" ]; then
  args+=(--set spaces_$DID.label label=${NAME#"spaces_$DID."} \
         --set $NAME icon.background.y_offset=-12              )
else
  args+=(--set $NAME icon.background.y_offset=-22)
fi

sketchybar -m --animate tanh 15 "${args[@]}"
