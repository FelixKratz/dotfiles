#!/usr/bin/env sh

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged" # Spotify Event for track changes

sketchybar --add       event              spotify_change $SPOTIFY_EVENT                                  \
           --add       item               spotify.back popup."Control Center,Sound"                      \
           --set       spotify.back       icon=􀊎                                                         \
                                          script="$PLUGIN_DIR/spotify.sh"                                \
                                          updates=on                                                     \
           --subscribe spotify.back       mouse.clicked                                                  \
                                                                                                         \
           --add       item               spotify.play_pause popup."Control Center,Sound"                \
           --set       spotify.play_pause icon=􀊈                                                         \
                                          script="$PLUGIN_DIR/spotify.sh"                                \
                                          updates=on                                                     \
           --subscribe spotify.play_pause mouse.clicked spotify_change                                   \
                                                                                                         \
           --add       item               spotify.next popup."Control Center,Sound"                      \
           --set       spotify.next       icon=􀊐                                                         \
                                          script="$PLUGIN_DIR/spotify.sh"                                \
                                          updates=on                                                     \
                                          label.padding_right=6                                          \
           --subscribe spotify.next       mouse.clicked                                                  \
                                                                                                         \
           --add       item               spotify.shuffle popup."Control Center,Sound"                   \
           --set       spotify.shuffle    icon=􀊝                                                         \
                                          script="$PLUGIN_DIR/spotify.sh"                                \
                                          updates=on                                                     \
                                          icon.highlight_color=0xff1DB954                                \
           --subscribe spotify.shuffle    mouse.clicked                                                  \
                                                                                                         \
           --add       item               spotify.repeat popup."Control Center,Sound"                    \
           --set       spotify.repeat     icon=􀊞                                                         \
                                          script="$PLUGIN_DIR/spotify.sh"                                \
                                          updates=on                                                     \
                                          icon.highlight_color=0xff1DB954                                \
           --subscribe spotify.repeat     mouse.clicked
