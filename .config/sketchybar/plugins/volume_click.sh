#!/usr/bin/env sh

MUTED=$(osascript -e 'output muted of (get volume settings)')

if [ "$MUTED" = "false" ]; then
  osascript -e 'set volume output muted true'
else
  osascript -e 'set volume output muted false'
fi
