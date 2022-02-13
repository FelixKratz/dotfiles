#!/usr/bin/env sh

NOTIFICATIONS="$(gh api notifications)"
COUNT="$(echo "$NOTIFICATIONS" | jq 'length')"
args=()
if [ "$NOTIFICATIONS" = "[]" ]; then
  args+=(--set $NAME icon=􀋚 label="0")
else
  args+=(--set $NAME icon=􀝗 label="$COUNT")
fi

# For sound to play around with:
# afplay /System/Library/Sounds/Morse.aiff

args+=(--remove '/github.notification\.*/')

COUNT=0
COLOR=0xffe1e3e4
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
    "'Issue'") COLOR=0xff9dd274; ICON=􀍷; PADDING=0; URL="$(gh api "$(echo "${url}" | sed -e "s/^'//" -e "s/'$//")" | jq .html_url)"
    ;;
    "'Discussion'") COLOR=0xffe1e3e4; ICON=􀒤; PADDING=0; URL="https://www.github.com/notifications"
    ;;
    "'PullRequest'") COLOR=0xffba9cf3; ICON="􀙡"; PADDING=4; URL="$(gh api "$(echo "${url}" | sed -e "s/^'//" -e "s/'$//")" | jq .html_url)"
    ;;
  esac
  
  if [ "$IMPORTANT" != "" ]; then
    COLOR=0xffff6578
    ICON=􀁞
    args+=(--set github.bell icon.color=$COLOR)
  fi
  args+=(--add item github.notification.$COUNT popup.github.bell                                      \
         --set github.notification.$COUNT background.padding_left=7                                   \
                                          background.padding_right=7                                  \
                                          background.color=0x22e1e3e4                                 \
                                          background.drawing=off                                      \
                                          icon.background.height=2                                    \
                                          icon.background.y_offset=-12                                \
                                          icon.background.color=$COLOR                                \
                                          icon.padding_left="$PADDING"                                \
                                          icon.color=$COLOR                                           \
                                          icon.background.shadow.color=0xff2a2f38                     \
                                          icon.background.shadow.angle=25                             \
                                          icon.background.shadow.distance=2                           \
                                          icon.background.shadow.drawing=on                           \
                                          icon="$ICON $(echo "$repo" | sed -e "s/^'//" -e "s/'$//"):" \
                                          label="$(echo "$title" | sed -e "s/^'//" -e "s/'$//")"      \
                                          script='case "$SENDER" in
                                                    "mouse.entered") sketchybar --set $NAME background.drawing=on
                                                    ;;
                                                    "mouse.exited") sketchybar --set $NAME background.drawing=off
                                                    ;;
                                                  esac' \
                                          click_script="open $URL;
                                                        sketchybar --set github.bell popup.drawing=off"
        --subscribe github.notification.$COUNT mouse.entered mouse.exited)
done <<< "$(echo "$NOTIFICATIONS" | jq -r '.[] | [.repository.name, .subject.latest_comment_url, .subject.type, .subject.title] | @sh')"

sketchybar -m "${args[@]}" 
