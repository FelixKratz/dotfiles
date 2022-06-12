#!/usr/bin/env sh

update() {
  source "$HOME/.config/sketchybar/colors.sh"
  source "$HOME/.config/sketchybar/icons.sh"

  NOTIFICATIONS="$(gh api notifications)"
  COUNT="$(echo "$NOTIFICATIONS" | jq 'length')"
  args=()
  if [ "$NOTIFICATIONS" = "[]" ]; then
    args+=(--set $NAME icon=$BELL label="0")
  else
    args+=(--set $NAME icon=$BELL_DOT label="$COUNT")
  fi

  PREV_COUNT=$(sketchybar --query github.bell | jq -r .text.label)
  # For sound to play around with:
  # afplay /System/Library/Sounds/Morse.aiff

  args+=(--remove '/github.notification\.*/')

  COUNT=0
  COLOR=$WHITE
  args+=(--set github.bell icon.color=$COLOR)

  while read -r repo url type title 
  do
    COUNT=$((COUNT + 1))
    IMPORTANT="$(echo "$title" | egrep -i "(deprecat|break|broke)")"
    COLOR=0xff72cce8
    PADDING=0
    if [ "${repo}" = "" ] && [ "${title}" = "" ]; then
      repo="Note"
      title="No new notifications"
    fi 
    case "${type}" in
      "'Issue'") COLOR=$GREEN; ICON=$GIT_ISSUE; PADDING=0; URL="$(gh api "$(echo "${url}" | sed -e "s/^'//" -e "s/'$//")" | jq .html_url)"
      ;;
      "'Discussion'") COLOR=$WHITE; ICON=$GIT_DISCUSSION; PADDING=0; URL="https://www.github.com/notifications"
      ;;
      "'PullRequest'") COLOR=$MAGENTA; ICON=$GIT_PULL_REQUEST; PADDING=4; URL="$(gh api "$(echo "${url}" | sed -e "s/^'//" -e "s/'$//")" | jq .html_url)"
      ;;
    esac
    
    if [ "$IMPORTANT" != "" ]; then
      COLOR=0xffff6578
      ICON=􀁞
      args+=(--set github.bell icon.color=$COLOR)
    fi
    
    args+=(--clone github.notification.$COUNT github.template \
           --set github.notification.$COUNT label="$(echo "$title" | sed -e "s/^'//" -e "s/'$//")" \
                                            icon="$ICON $(echo "$repo" | sed -e "s/^'//" -e "s/'$//"):" \
                                            icon.padding_left="$PADDING" \
                                            icon.color=$COLOR \
                                            position=popup.github.bell \
                                            icon.background.color=$COLOR \
                                            drawing=on \
                                            script="$PLUGIN_DIR/glow_on_hover.sh" \
                                            click_script="open $URL;
                                                          sketchybar --set github.bell popup.drawing=off")
  done <<< "$(echo "$NOTIFICATIONS" | jq -r '.[] | [.repository.name, .subject.latest_comment_url, .subject.type, .subject.title] | @sh')"

  sketchybar -m "${args[@]}"

  if [ "$COUNT" != "$PREV_COUNT" ]; then
    sketchybar --animate tanh 15 --set github.bell label.y_offset=5 icon.highlight=on label.y_offset=0
  fi
}

popup() {
  sketchybar --set $NAME popup.drawing=$1 icon.highlight=$1
}

case "$SENDER" in
  "routine"|"forced") update
  ;;
  "mouse.entered") popup on
  ;;
  "mouse.exited"|"mouse.exited.global") popup off
  ;;
  "mouse.clicked") popup toggle
  ;;
esac

