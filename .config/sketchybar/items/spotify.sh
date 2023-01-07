#!/bin/sh

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"
POPUP_SCRIPT="sketchybar -m --set spotify.anchor popup.drawing=toggle"

sketchybar --add       event           spotify_change $SPOTIFY_EVENT        \
           --add       item            spotify.anchor center                \
           --set       spotify.anchor  script="$PLUGIN_DIR/spotify.sh"      \
                                       click_script="$POPUP_SCRIPT"         \
                                       popup.horizontal=on                  \
                                       popup.align=center                   \
                                       popup.height=150                     \
                                       icon=􁁒                               \
                                       icon.font="$FONT:Regular:25.0"       \
                                       label.drawing=off                    \
                                       drawing=off                          \
                                       y_offset=2                           \
           --subscribe spotify.anchor  mouse.entered mouse.exited           \
                                       mouse.exited.global                  \
                                                                            \
           --add       item            spotify.cover popup.spotify.anchor   \
           --set       spotify.cover   script="$PLUGIN_DIR/spotify.sh"      \
                                       label.drawing=off                    \
                                       icon.drawing=off                     \
                                       padding_left=12                      \
                                       padding_right=10                     \
                                       background.image.scale=0.2           \
                                       background.image.drawing=on          \
                                       background.drawing=on                \
                                                                            \
           --add       item            spotify.title popup.spotify.anchor   \
           --set       spotify.title   icon.drawing=off                     \
                                       padding_left=0                       \
                                       padding_right=0                      \
                                       width=0                              \
                                       label.font="$FONT:Heavy:15.0"        \
                                       y_offset=55                          \
                                                                            \
           --add       item            spotify.artist popup.spotify.anchor  \
           --set       spotify.artist  icon.drawing=off                     \
                                       y_offset=30                          \
                                       padding_left=0                       \
                                       padding_right=0                      \
                                       width=0                              \
                                                                            \
           --add       item            spotify.album popup.spotify.anchor   \
           --set       spotify.album   icon.drawing=off                     \
                                       padding_left=0                       \
                                       padding_right=0                      \
                                       y_offset=15                          \
                                       width=0                              \
                                                                            \
           --add       slider          spotify.state popup.spotify.anchor   \
           --set       spotify.state   icon.drawing=on                      \
                                       icon.font="$FONT:Light Italic:10.0"  \
                                       icon="01:24"                         \
                                       icon.width=35                        \
                                       label.drawing=on                     \
                                       label.font="$FONT:Light Italic:10.0" \
                                       label="03:40"                        \
                                       label.width=35                       \
                                       padding_left=0                       \
                                       padding_right=0                      \
                                       y_offset=-15                         \
                                       width=0                              \
                                       slider.background.height=6           \
                                       slider.background.corner_radius=1    \
                                       slider.background.color=$GREY        \
                                       slider.highlight_color=$GREEN        \
                                       slider.percentage=40                 \
                                       slider.width=115                     \
                                       script="$PLUGIN_DIR/spotify.sh"      \
                                       update_freq=1                        \
                                       updates=when_shown                   \
           --subscribe spotify.state   mouse.clicked                        \
                                                                            \
           --add       item            spotify.shuffle popup.spotify.anchor \
           --set       spotify.shuffle icon=􀊝                               \
                                       icon.padding_left=5                  \
                                       icon.padding_right=5                 \
                                       icon.color=$BLACK                    \
                                       icon.highlight_color=$GREY           \
                                       label.drawing=off                    \
                                       script="$PLUGIN_DIR/spotify.sh"      \
                                       y_offset=-45                         \
           --subscribe spotify.shuffle mouse.clicked                        \
                                                                            \
           --add       item            spotify.back popup.spotify.anchor    \
           --set       spotify.back    icon=􀊎                               \
                                       icon.padding_left=5                  \
                                       icon.padding_right=5                 \
                                       icon.color=$BLACK                    \
                                       script="$PLUGIN_DIR/spotify.sh"      \
                                       label.drawing=off                    \
                                       y_offset=-45                         \
           --subscribe spotify.back    mouse.clicked                        \
                                                                            \
           --add       item            spotify.play popup.spotify.anchor    \
           --set       spotify.play    icon=􀊔                               \
                                       background.height=40                 \
                                       background.corner_radius=20          \
                                       width=40                             \
                                       align=center                         \
                                       background.color=$BLACK              \
                                       background.border_color=$WHITE       \
                                       background.border_width=0            \
                                       background.drawing=on                \
                                       icon.padding_left=4                  \
                                       icon.padding_right=5                 \
                                       icon.color=$WHITE                    \
                                       updates=on                           \
                                       label.drawing=off                    \
                                       script="$PLUGIN_DIR/spotify.sh"      \
                                       y_offset=-45                         \
           --subscribe spotify.play    mouse.clicked spotify_change         \
                                                                            \
           --add       item            spotify.next popup.spotify.anchor    \
           --set       spotify.next    icon=􀊐                               \
                                       icon.padding_left=5                  \
                                       icon.padding_right=5                 \
                                       icon.color=$BLACK                    \
                                       label.drawing=off                    \
                                       script="$PLUGIN_DIR/spotify.sh"      \
                                       y_offset=-45                         \
           --subscribe spotify.next    mouse.clicked                        \
                                                                            \
           --add       item            spotify.repeat popup.spotify.anchor  \
           --set       spotify.repeat  icon=􀊞                               \
                                       icon.highlight_color=$GREY           \
                                       icon.padding_left=5                  \
                                       icon.padding_right=10                \
                                       icon.color=$BLACK                    \
                                       label.drawing=off                    \
                                       script="$PLUGIN_DIR/spotify.sh"      \
                                       y_offset=-45                         \
           --subscribe spotify.repeat  mouse.clicked                        \
                                                                            \
           --add       item            spotify.spacer popup.spotify.anchor  \
           --set       spotify.spacer  width=5                              \
                                                                            \
           --add      bracket          spotify spotify.shuffle              \
                                               spotify.back                 \
                                               spotify.play                 \
                                               spotify.next                 \
                                               spotify.repeat               \
           --set      spotify          background.color=$GREEN              \
                                       background.corner_radius=11          \
                                       background.drawing=on                \
                                       y_offset=-45                         \
                                       drawing=off
