#!/usr/bin/env sh

sketchybar --clone network.label label_template                  \
           --set   network.label label=net                       \
                                 associated_space=3              \
                                 position=left                   \
                                 drawing=on                      \
                                                                 \
           --add   item          network.vpn left                \
           --set   network.vpn   update_freq=15                  \
                                 associated_space=3              \
                                 icon.font="$FONT:Bold:16.0"     \
                                 script="$PLUGIN_DIR/vpn.sh"     \
                                                                 \
           --add   item          network.up left                 \
           --set   network.up    label.font="$FONT:Heavy:9"      \
                                 icon.font="$FONT:Heavy:9"       \
                                 icon=􀅃                          \
                                 icon.highlight_color=0xffff6578 \
                                 width=0                         \
                                 y_offset=5                      \
                                 associated_space=3              \
                                 update_freq=2                   \
                                 script="$PLUGIN_DIR/network.sh" \
                                 lazy=on                         \
                                                                 \
           --add   item          network.down left               \
           --set   network.down  label.font="$FONT:Heavy:9"      \
                                 icon.font="$FONT:Heavy:9"       \
                                 icon=􀅄                          \
                                 icon.highlight_color=0xff72cce8 \
                                 y_offset=-5                     \
                                 associated_space=3              \
                                                                 \
           --add   bracket       network                         \
                                 network.label                   \
                                 network.vpn                     \
                                 network.up                      \
                                 network.down                    \
                                                                 \
           --set   network       background.drawing=on
