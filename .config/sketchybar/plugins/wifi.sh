#!/usr/bin/env sh

CURRENT_WIFI="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)"
SSID="$(echo "$CURRENT_WIFI" | grep -o "SSID: .*" | sed 's/^SSID: //')"
AUTH="$(echo "$CURRENT_WIFI" | grep -o "link auth: .*" | sed 's/^link auth: //')"
CURR_TX="$(echo "$CURRENT_WIFI" | grep -o "lastTxRate: .*" | sed 's/^lastTxRate: //')"
MAX_TX="$(echo "$CURRENT_WIFI" | grep -o "maxRate: .*" | sed 's/^maxRate: //')"

sketchybar --set $NAME icon="$SSID:" label="$CURR_TX / $MAX_TX (Mbps) - $AUTH"
