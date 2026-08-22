#!/bin/bash
# Animate the mail item while accounts are syncing. Started by mail.sh, holds a
# lock so only one animator runs, and hands the item back to mail.sh when the
# last account drops its marker in ~/.cache/mail-sync/.

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

STATE_DIR="$HOME/.cache/mail-sync"
LOCK="$HOME/.cache/mail-spinner.lock"
MAX_SECONDS=900

mkdir "$LOCK" 2>/dev/null || exit 0
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

frame=0
while [[ $SECONDS -lt $MAX_SECONDS ]]; do
  running=()
  for marker in "$STATE_DIR"/*; do
    [[ -f $marker ]] || continue
    owner=$(cat "$marker" 2>/dev/null)
    # A marker left behind by a killed sync would spin forever otherwise
    if [[ -n $owner ]] && ! kill -0 "$owner" 2>/dev/null; then
      rm -f "$marker"
      continue
    fi
    running+=("$(basename "$marker")")
  done
  [[ ${#running[@]} -gt 0 ]] || break
  # Names stay readable up to a couple of accounts; a full sync just counts
  if [[ ${#running[@]} -le 2 ]]; then
    label="${running[*]}"
  else
    label="${#running[@]} accounts"
  fi
  sketchybar --set mail icon="${SPINNER_FRAMES[$frame]}" \
                        icon.font="$SPINNER_FONT" \
                        icon.color=$BLUE \
                        icon.y_offset=$SPINNER_Y_OFFSET \
                        icon.width=$SPINNER_WIDTH \
                        label="$label"
  frame=$(( (frame + 1) % ${#SPINNER_FRAMES[@]} ))
  sleep 0.1
done

# Back to the unread counts
sketchybar --set mail icon.font="$MAIL_ICON_FONT" \
                      icon.y_offset=0 icon.width=dynamic
sketchybar --trigger mail_sync
