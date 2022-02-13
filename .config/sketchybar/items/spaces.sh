#!/usr/bin/env sh

sketchybar --add       space              space_template left                \
           --set       space_template     icon.highlight_color=0xff9dd274    \
                                          label.drawing=off                  \
                                          drawing=off                        \
                                          updates=on                         \
                                          associated_display=1               \
                                          label.font="$FONT:Black:13.0"      \
                                          icon.font="$FONT:Bold:17.0"        \
                                          script="$PLUGIN_DIR/space.sh"      \
                                          icon.padding_right=6               \
                                          icon.padding_left=2                \
                                          background.padding_left=2          \
                                          background.padding_right=2         \
                                          icon.background.height=2           \
                                          icon.background.color=$ICON_COLOR  \
                                          icon.background.y_offset=-12       \
                                          click_script="$SPACE_CLICK_SCRIPT" \
                                                                             \
           --clone     spaces_1.label     label_template                     \
           --set       spaces_1.label     label=spc                          \
                                          label.width=38                     \
                                          label.align=center                 \
                                          associated_display=1               \
                                          position=left                      \
                                          drawing=on                         \
                                                                             \
           --clone     code               space_template                     \
           --set       code               associated_space=1                 \
                                          icon=􀤙                             \
                                          icon.highlight_color=0xff9dd274    \
                                          icon.background.color=0xff9dd274   \
                                          drawing=on                         \
                                                                             \
           --clone     tex                space_template                     \
           --set       tex                associated_space=2                 \
                                          icon=􀓕                             \
                                          icon.highlight_color=0xfff69c5e    \
                                          icon.background.color=0xfff69c5e   \
                                          drawing=on                         \
                                                                             \
           --clone     web                space_template                     \
           --set       web                associated_space=3                 \
                                          icon=􀼺                             \
                                          icon.highlight_color=0xff72cce8    \
                                          icon.background.color=0xff72cce8   \
                                          drawing=on                         \
                                                                             \
           --clone     idle               space_template                     \
           --set       idle               associated_space=4                 \
                                          icon=􀽎                             \
                                          icon.highlight_color=0xffeacb64    \
                                          icon.background.color=0xffeacb64   \
                                          drawing=on                         \
                                                                             \
           --add       bracket            spaces_1                           \
                                          spaces_1.label                     \
                                          code                               \
                                          web                                \
                                          tex                                \
                                          idle                               \
                                                                             \
           --set       spaces_1           background.drawing=on              \
                                                                             \
           --set       space_template     associated_display=2               \
                                                                             \
           --clone     spaces_2.label     label_template                     \
           --set       spaces_2.label     label=spc                          \
                                          associated_display=2               \
                                          label.width=45                     \
                                          label.align=center                 \
                                          position=left                      \
                                          drawing=on                         \
                                                                             \
           --clone     misc               space_template                     \
           --set       misc               associated_space=5                 \
                                          icon=􀤙                             \
                                          icon.highlight_color=0xff9dd274    \
                                          icon.background.color=0xff9dd274   \
                                          drawing=on                         \
                                                                             \
           --clone     doc                space_template                     \
           --set       doc                associated_space=6                 \
                                          icon=􀓕                             \
                                          icon.highlight_color=0xfff69c5e    \
                                          icon.background.color=0xfff69c5e   \
                                          drawing=on                         \
                                                                             \
           --clone     help               space_template                     \
           --set       help               associated_space=7                 \
                                          icon=􀼺                             \
                                          icon.highlight_color=0xff72cce8    \
                                          icon.background.color=0xff72cce8   \
                                          drawing=on                         \
                                                                             \
           --clone     music              space_template                     \
           --set       music              associated_space=8                 \
                                          icon=􀽎                             \
                                          icon.highlight_color=0xffeacb64    \
                                          icon.background.color=0xffeacb64   \
                                          drawing=on                         \
                                                                             \
           --add       bracket            spaces_2                           \
                                          spaces_2.label                     \
                                          misc                               \
                                          doc                                \
                                          help                               \
                                          music                              \
                                                                             \
           --set       spaces_2           background.drawing=on
