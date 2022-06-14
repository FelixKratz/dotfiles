#!/usr/bin/env sh

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged" # Spotify Event for track changes
POPUP_POS="popup.Control Center,Sound"

sketchybar --add       event              spotify_change $SPOTIFY_EVENT       \
           --add       item               spotify.back "$POPUP_POS"           \
           --set       spotify.back       icon=$SPOTIFY_BACK                  \
                                          script="$PLUGIN_DIR/spotify.sh"     \
                                          updates=on                          \
           --subscribe spotify.back       mouse.clicked                       \
                                                                              \
           --add       item               spotify.play_pause "$POPUP_POS"     \
           --set       spotify.play_pause icon=􀊈                              \
                                          script="$PLUGIN_DIR/spotify.sh"     \
                                          updates=on                          \
           --subscribe spotify.play_pause mouse.clicked spotify_change        \
                                                                              \
           --add       item               spotify.next "$POPUP_POS"           \
           --set       spotify.next       icon=􀊐                              \
                                          script="$PLUGIN_DIR/spotify.sh"     \
                                          updates=on                          \
                                          label.padding_right=6               \
           --subscribe spotify.next       mouse.clicked                       \
                                                                              \
           --add       item               spotify.shuffle "$POPUP_POS"        \
           --set       spotify.shuffle    icon=􀊝                              \
                                          script="$PLUGIN_DIR/spotify.sh"     \
                                          updates=on                          \
                                          icon.highlight_color=$SPOTIFY_GREEN \
           --subscribe spotify.shuffle    mouse.clicked                       \
                                                                              \
           --add       item               spotify.repeat "$POPUP_POS"         \
           --set       spotify.repeat     icon=􀊞                              \
                                          script="$PLUGIN_DIR/spotify.sh"     \
                                          updates=on                          \
                                          icon.highlight_color=$SPOTIFY_GREEN \
                                          label.drawing=off                   \
                                          background.padding_right=7          \
           --subscribe spotify.repeat     mouse.clicked                       \
                                                                              \
           --add       bracket            spotify                             \
                                          spotify.back                        \
                                          spotify.play_pause                  \
                                          spotify.next                        \
                                          spotify.shuffle                     \
                                          spotify.repeat                      \
           --set       spotify            background.color=0x99000000         \
                                          background.corner_radius=5          \
                                          background.drawing=on               \
