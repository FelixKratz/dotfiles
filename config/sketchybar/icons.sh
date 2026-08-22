#!/bin/bash

# General Icons
LOADING=􀖇
APPLE=􀣺
PREFERENCES=􀺽
ACTIVITY=􀒓
LOCK=􀒳
BELL=􀋚
BELL_DOT=􀝗

# Git Icons
GIT_ISSUE=􀍷
GIT_DISCUSSION=􀒤
GIT_PULL_REQUEST=􀙡
GIT_COMMIT=􀡚
GIT_INDICATOR=􀂓

# Spotify Icons
SPOTIFY_BACK=􀊎
SPOTIFY_PLAY_PAUSE=􀊈
SPOTIFY_NEXT=􀊐
SPOTIFY_SHUFFLE=􀊝
SPOTIFY_REPEAT=􀊞

# Yabai Icons
YABAI_STACK=􀏭
YABAI_FULLSCREEN_ZOOM=􀏜
YABAI_PARENT_ZOOM=􀥃
YABAI_FLOAT=􀢌
YABAI_GRID=􀧍

# Battery Icons
BATTERY_100=􀛨
BATTERY_75=􀺸
BATTERY_50=􀺶
BATTERY_25=􀛩
BATTERY_0=􀛪
BATTERY_CHARGING=􀢋

# Volume Icons
VOLUME_100=􀊩
VOLUME_66=􀊧
VOLUME_33=􀊥
VOLUME_10=􀊡
VOLUME_0=􀊣

# WiFi
WIFI_CONNECTED=􀙇
WIFI_DISCONNECTED=􀙈

# svim
MODE_NORMAL=􀂯
MODE_INSERT=􀂥
MODE_VISUAL=􀂿
MODE_CMD=􀂙
MODE_PENDING=􀈏

# Mail Icons
MAIL=􀍜
MAIL_UNREAD=􀍛

# Sync spinner: braille frames need a Braille-capable face (Hack Nerd Font)
MAIL_ICON_FONT="SF Pro:Regular:16.0"
SPINNER_FONT="Hack Nerd Font:Bold:17.0"
SPINNER_FRAMES=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
# Braille sits high in the em box, and sketchybar measures the dots rather
# than the cell, so a one-column frame would shift the bar without a fixed width
SPINNER_Y_OFFSET=-2
SPINNER_WIDTH=15
