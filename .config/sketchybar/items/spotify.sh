SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"
POPUP_SCRIPT="sketchybar -m --set spotify.cover popup.drawing=toggle"

sketchybar --add       event           spotify_change $SPOTIFY_EVENT       \
           --add       item            spotify.cover center                \
           --set       spotify.cover   click_script="$POPUP_SCRIPT"        \
                                       popup.horizontal=on                 \
                                       popup.align=center                  \
                                       popup.background.image.scale=0.5    \
                                       popup.background.corner_radius=0    \
                                       icon.drawing=off                    \
                                       label.drawing=off                   \
                                                                           \
           --add       item            spotify.title q                     \
           --set       spotify.title   click_script="$POPUP_SCRIPT"        \
                                       icon=􀑪                              \
                                       drawing=off                         \
                                       script="$PLUGIN_DIR/spotify.sh"     \
                                       background.padding_right=0          \
           --subscribe spotify.title   mouse.entered mouse.exited          \
                                       mouse.exited.global                 \
                                                                           \
           --add       item            spotify.artist e                    \
           --set       spotify.artist  click_script="$POPUP_SCRIPT"        \
                                       icon=􀓤                              \
                                       drawing=off                         \
                                       background.padding_left=0           \
                                       script="$PLUGIN_DIR/spotify.sh"     \
           --subscribe spotify.artist  mouse.entered mouse.exited          \
                                       mouse.exited.global                 \
                                                                           \
           --add       item            spotify.back popup.spotify.cover    \
           --set       spotify.back    icon=􀊎                              \
                                       icon.padding_left=5                 \
                                       icon.padding_right=5                \
                                       script="$PLUGIN_DIR/spotify.sh"     \
                                       label.drawing=off                   \
           --subscribe spotify.back    mouse.clicked                       \
                                                                           \
           --add       item            spotify.play popup.spotify.cover    \
           --set       spotify.play    icon=􀊔                              \
                                       icon.padding_left=5                 \
                                       icon.padding_right=5                \
                                       updates=on                          \
                                       label.drawing=off                   \
                                       script="$PLUGIN_DIR/spotify.sh"     \
           --subscribe spotify.play    mouse.clicked spotify_change        \
                                                                           \
           --add       item            spotify.next popup.spotify.cover    \
           --set       spotify.next    icon=􀊐                              \
                                       icon.padding_left=5                 \
                                       icon.padding_right=10               \
                                       label.drawing=off                   \
                                       script="$PLUGIN_DIR/spotify.sh"     \
           --subscribe spotify.next    mouse.clicked                       \
                                                                           \
           --add       item            spotify.shuffle popup.spotify.cover \
           --set       spotify.shuffle icon=􀊝                              \
                                       icon.highlight_color=0xff1DB954     \
                                       icon.padding_left=5                 \
                                       icon.padding_right=5                \
                                       label.drawing=off                   \
                                       script="$PLUGIN_DIR/spotify.sh"     \
           --subscribe spotify.shuffle mouse.clicked                       \
                                                                           \
           --add       item            spotify.repeat popup.spotify.cover  \
           --set       spotify.repeat  icon=􀊞                              \
                                       icon.highlight_color=0xff1DB954     \
                                       icon.padding_left=5                 \
                                       icon.padding_right=5                \
                                       label.drawing=off                   \
                                       script="$PLUGIN_DIR/spotify.sh"     \
           --subscribe spotify.repeat  mouse.clicked                       \
                                                                           \
           --add      bracket          spotify spotify.back                \
                                               spotify.play                \
                                               spotify.next                \
                                               spotify.shuffle             \
                                               spotify.repeat              \
           --set      spotify          blur_radius=30                      \
                                       background.color=0x60000000         \
                                       background.corner_radius=9          \
                                       background.drawing=on               \
                                       drawing=off
