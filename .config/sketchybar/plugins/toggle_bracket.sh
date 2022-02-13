#!/usr/bin/env bash

BRACKET_NAME="$(echo $NAME | tr '.' ' ' | awk "{ print \$1 }")"
ITEMS="$(sketchybar --query $BRACKET_NAME | jq -r ".bracket[]")"
args=()
while read -r item
do
  if [ "$item" != "$NAME" ]; then
    args+=(--set "$item" drawing=toggle)
  fi
done <<< "$ITEMS"

sketchybar -m "${args[@]}"

