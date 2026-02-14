#!/bin/bash

# Highlight focused workspace and show app icons per workspace

source "$CONFIG_DIR/colors.sh"

# Workspace ID from item name (space.1 -> 1)
SID="${NAME#space.}"

# Get focused workspace (from event env var, or query if not set)
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"

# Highlight active workspace
if [ "$SID" = "$FOCUSED" ]; then
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
