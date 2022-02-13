#!/usr/bin/env sh

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged" # Spotify Event for track changes

sketchybar --add       event              spotify_change $SPOTIFY_EVENT                                  \
           --clone     spotify.name       label_template                                                 \
           --set       spotify.name       position=right                                                 \
                                          click_script="sketchybar -m --set \$NAME popup.drawing=toggle" \
                                          popup.horizontal=on                                            \
                                          popup.align=center                                             \
                                          script="$PLUGIN_DIR/spotify.sh"                                \
                                          updates=on                                                     \
                                          background.padding_left=$PADDINGS                              \
                                                                                                         \
           --add       item               spotify.back popup.spotify.name                                \
           --set       spotify.back       icon=􀊎                                                         \
                                          script="$PLUGIN_DIR/spotify.sh"                                \
                                          updates=on                                                     \
           --subscribe spotify.back       mouse.clicked                                                  \
                                                                                                         \
           --add       item               spotify.play_pause popup.spotify.name                          \
           --set       spotify.play_pause icon=􀊔                                                         \
                                          script="$PLUGIN_DIR/spotify.sh"                                \
                                          updates=on                                                     \
           --subscribe spotify.play_pause mouse.clicked spotify_change                                   \
                                                                                                         \
           --add       item               spotify.next popup.spotify.name                                \
           --set       spotify.next       icon=􀊐                                                         \
                                          script="$PLUGIN_DIR/spotify.sh"                                \
                                          updates=on                                                     \
                                          label.padding_right=6                                          \
           --subscribe spotify.next       mouse.clicked                                                  \
                                                                                                         \
           --add       item               spotify.shuffle popup.spotify.name                             \
           --set       spotify.shuffle    icon=􀊝                                                         \
                                          script="$PLUGIN_DIR/spotify.sh"                                \
                                          updates=on                                                     \
                                          icon.highlight_color=0xff1DB954                                \
           --subscribe spotify.shuffle    mouse.clicked                                                  \
                                                                                                         \
           --add       item               spotify.repeat popup.spotify.name                              \
           --set       spotify.repeat     icon=􀊞                                                         \
                                          script="$PLUGIN_DIR/spotify.sh"                                \
                                          updates=on                                                     \
                                          icon.highlight_color=0xff1DB954                                \
           --subscribe spotify.repeat     mouse.clicked
