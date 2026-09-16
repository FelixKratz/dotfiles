#!/bin/bash

source "$CONFIG_DIR/colors.sh"

WORK_CAL="Calendar"

# While a meeting is under way it stays on the bar; the next one takes over
# this many minutes before it starts.
SWITCH_MINS=15

# One line per event: "@09:45 - 12:00~Project meeting". -n drops events that
# have already finished, so the first line is either the meeting under way or
# the next one to start.
RAW=$(icalbuddy -ic "$WORK_CAL" -ea -n -nc -nrd -npn -b "@" -ps "|~|" \
  -iep "datetime,title" -po "datetime,title" \
  -df "" -tf "%H:%M" \
  eventsToday 2>/dev/null)

if [ -z "$RAW" ]; then
  sketchybar --set "$NAME" icon.color=$GREEN label.drawing=off
  exit 0
fi

NOW=$(( 10#$(date +%H) * 60 + 10#$(date +%M) ))

# Both the meeting under way and the next one to start, so the handover can
# happen on time rather than the moment a meeting begins.
UPCOMING_LABEL=""
UPCOMING_MINS=""
CURRENT_LABEL=""

while IFS= read -r line; do
  case "$line" in
    @*~*) ;;
    *) continue ;;
  esac

  times="${line#@}"
  times="${times%%~*}"
  title="${line#*~}"
  start="${times%% *}"
  end="${times##* }"

  case "$start" in
    [0-9][0-9]:[0-9][0-9]) ;;
    *) continue ;;
  esac

  mins=$(( (10#${start%%:*} * 60 + 10#${start##*:}) - NOW ))

  timerange="$start"
  [ -n "$end" ] && [ "$end" != "$start" ] && timerange="${start}-${end}"
  label="${timerange} $(echo "$title" | xargs | cut -c1-25)"

  if [ "$mins" -ge 0 ]; then
    UPCOMING_LABEL="$label"
    UPCOMING_MINS="$mins"
    break
  fi

  # Overlapping meetings: the one that started most recently is the one you
  # are actually in, so let each in-progress line overwrite the last.
  end_mins=$(( 10#${end%%:*} * 60 + 10#${end##*:} ))
  [ "$end_mins" -gt "$NOW" ] && CURRENT_LABEL="$label"
done <<< "$RAW"

if [ -n "$CURRENT_LABEL" ] && { [ -z "$UPCOMING_LABEL" ] || [ "$UPCOMING_MINS" -gt "$SWITCH_MINS" ]; }; then
  LABEL="$CURRENT_LABEL"
  COLOR=$GREY
elif [ -n "$UPCOMING_LABEL" ]; then
  LABEL="$UPCOMING_LABEL"
  if [ "$UPCOMING_MINS" -lt 10 ]; then
    COLOR=$RED
  elif [ "$UPCOMING_MINS" -lt 30 ]; then
    COLOR=$YELLOW
  else
    COLOR=$WHITE
  fi
else
  sketchybar --set "$NAME" icon.color=$GREEN label.drawing=off
  exit 0
fi

sketchybar --set "$NAME" label="$LABEL" label.drawing=on \
                        label.color=$COLOR icon.color=$COLOR
