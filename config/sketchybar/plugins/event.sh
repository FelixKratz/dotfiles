#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Hide label immediately on mouse exit
if [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" label.drawing=off
  exit 0
fi

WORK_CAL="Calendar"

RAW=$(icalbuddy -ic "$WORK_CAL" -ea -li 1 -n -nc -nrd -npn -b "" \
  -iep "datetime,title" -po "datetime,title" \
  -df "" -tf "%H:%M" \
  eventsToday 2>/dev/null)

if [ -z "$RAW" ]; then
  sketchybar --set "$NAME" icon.color=$GREEN label.drawing=off
  exit 0
fi

# Extract start and end times, and title from multiline output
START=$(echo "$RAW" | grep -o '[0-9][0-9]:[0-9][0-9]' | head -1)
END=$(echo "$RAW" | grep -o '[0-9][0-9]:[0-9][0-9]' | tail -1)
TITLE=$(echo "$RAW" | grep -v '^[[:space:]]*[0-9][0-9]:[0-9][0-9]' | head -1 | xargs | cut -c1-25)

if [ -z "$START" ]; then
  sketchybar --set "$NAME" icon.color=$GREEN label.drawing=off
  exit 0
fi

TIMERANGE="$START"
[ -n "$END" ] && [ "$END" != "$START" ] && TIMERANGE="${START}-${END}"

# Minutes until event
EVENT_H=${START%%:*}
EVENT_M=${START##*:}
NOW_H=$(date +%H)
NOW_M=$(date +%M)
MINS=$(( (10#$EVENT_H * 60 + 10#$EVENT_M) - (10#$NOW_H * 60 + 10#$NOW_M) ))

if [ "$MINS" -lt 10 ]; then
  COLOR=$RED
elif [ "$MINS" -lt 30 ]; then
  COLOR=$YELLOW
else
  COLOR=$WHITE
fi

LABEL="${TIMERANGE} ${TITLE}"

if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set "$NAME" label="$LABEL" label.drawing=on label.color=$COLOR icon.color=$COLOR
else
  sketchybar --set "$NAME" label="$LABEL" label.drawing=off icon.color=$COLOR
fi
