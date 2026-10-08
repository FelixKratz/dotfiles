#!/bin/bash

# Highlight focused workspace and show app icons per workspace

source "$CONFIG_DIR/colors.sh"

# Display and workspace ID from item name (space.2.1 -> display 2, workspace 1)
DID="${NAME#space.}"
DID="${DID%%.*}"
SID="${NAME##*.}"

# Workspace shown on this item's display. Sketchybar's arrangement id matches
# the index of the screen in NSScreen.screens.
SHOWN="$(aerospace list-workspaces --monitor all --visible \
  --format '%{workspace} %{monitor-appkit-nsscreen-screens-id}' |
  awk -v d="$DID" '$2 == d { print $1 }')"

# Highlight the workspace this display shows
if [ "$SID" = "$SHOWN" ]; then
  COLOR=$GREY
  HIGHLIGHT=on
else
  COLOR=$BACKGROUND_2
  HIGHLIGHT=off
fi

# Build app icon strip for this workspace
APPS="$(aerospace list-windows --workspace "$SID" --format '%{app-name}' 2>/dev/null)"
ICON_STRIP=""
if [ -n "$APPS" ]; then
  source "$CONFIG_DIR/plugins/icon_map.sh"
  while IFS= read -r app; do
    icon_map "$app"
    ICON_STRIP+=" $icon_result"
  done <<< "$APPS"
else
  ICON_STRIP=" —"
fi

sketchybar --set "$NAME" \
  icon.highlight=$HIGHLIGHT \
  label.highlight=$HIGHLIGHT \
  background.border_color=$COLOR \
  label="$ICON_STRIP"
