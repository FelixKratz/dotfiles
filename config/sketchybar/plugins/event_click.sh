#!/bin/bash

WORK_CAL="Calendar"

# Get URL, notes, and location from the next event
RAW=$(icalbuddy -ic "$WORK_CAL" -ea -li 1 -n -nc -nrd -npn -b "" \
  -iep "url,notes,location" -po "url,notes,location" \
  -ps " | " \
  eventsToday 2>/dev/null)

[ -z "$RAW" ] && exit 0

# Look for a meeting URL in url, notes, or location fields
URL=$(echo "$RAW" | grep -oE 'https?://[^ ]+\.(zoom\.us|teams\.microsoft\.com|meet\.google\.com)[^ ]*' | head -1)

if [ -z "$URL" ]; then
  # Fallback: any https URL in the event
  URL=$(echo "$RAW" | grep -oE 'https?://[^ ]+' | head -1)
fi

if [ -n "$URL" ]; then
  open "$URL"
fi
