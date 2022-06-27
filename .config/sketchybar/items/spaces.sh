#!/usr/bin/env sh

sketchybar --add   space          space_template left                \
           --set   space_template icon.highlight_color=0xff9dd274    \
                                  label.drawing=off                  \
                                  drawing=off                        \
                                  updates=on                         \
                                  associated_display=1               \
                                  label.font="$FONT:Black:13.0"      \
                                  icon.font="$FONT:Bold:17.0"        \
                                  script="$PLUGIN_DIR/space.sh"      \
                                  icon.padding_right=6               \
                                  icon.padding_left=3                \
                                  background.padding_left=2          \
                                  background.padding_right=2         \
                                  icon.background.height=2           \
                                  icon.background.color=$ICON_COLOR  \
                                  icon.background.color=$ICON_COLOR  \
                                  icon.background.y_offset=-13       \
                                  click_script="$SPACE_CLICK_SCRIPT" \
                                                                     \
           --clone spaces_1.label label_template                     \
           --set   spaces_1.label label=spc                          \
                                  label.width=38                     \
                                  label.align=center                 \
                                  associated_display=1               \
                                  position=left                      \
                                  drawing=on                         \
                                                                     \
           --clone spaces_1.code  space_template                     \
           --set   spaces_1.code  associated_space=1                 \
                                  icon=$SPACES_CODE                  \
                                  icon.highlight_color=$GREEN        \
                                  icon.background.color=$GREEN       \
                                  drawing=on                         \
                                                                     \
           --clone spaces_1.tex   space_template                     \
           --set   spaces_1.tex   associated_space=2                 \
                                  icon=$SPACES_TEX                   \
                                  icon.highlight_color=$ORANGE       \
                                  icon.background.color=$ORANGE      \
                                  drawing=on                         \
                                                                     \
           --clone spaces_1.web   space_template                     \
           --set   spaces_1.web   associated_space=3                 \
                                  icon=$SPACES_WEB                   \
                                  icon.highlight_color=$BLUE         \
                                  icon.background.color=$BLUE        \
                                  drawing=on                         \
                                                                     \
           --clone spaces_1.idle  space_template                     \
           --set   spaces_1.idle  associated_space=4                 \
                                  icon=$SPACES_IDLE                  \
                                  icon.highlight_color=$YELLOW       \
                                  icon.background.color=$YELLOW      \
                                  drawing=on                         \
                                                                     \
           --add   bracket        spaces_1                           \
                                  spaces_1.label                     \
                                  spaces_1.code                      \
                                  spaces_1.web                       \
                                  spaces_1.tex                       \
                                  spaces_1.idle                      \
                                                                     \
           --set   space_template associated_display=2               \
                                                                     \
           --clone spaces_2.label label_template                     \
           --set   spaces_2.label label=spc                          \
                                  associated_display=2               \
                                  label.width=45                     \
                                  label.align=center                 \
                                  position=left                      \
                                  drawing=on                         \
                                                                     \
           --clone spaces_2.misc  space_template                     \
           --set   spaces_2.misc  associated_space=5                 \
                                  icon=$SPACES_MISC                  \
                                  icon.highlight_color=$GREEN        \
                                  icon.background.color=$GREEN       \
                                  drawing=on                         \
                                                                     \
           --clone spaces_2.doc   space_template                     \
           --set   spaces_2.doc   associated_space=6                 \
                                  icon=$SPACES_DOC                   \
                                  icon.highlight_color=$ORANGE       \
                                  icon.background.color=$ORANGE      \
                                  drawing=on                         \
                                                                     \
           --clone spaces_2.help  space_template                     \
           --set   spaces_2.help  associated_space=7                 \
                                  icon=$SPACES_HELP                  \
                                  icon.highlight_color=$BLUE         \
                                  icon.background.color=$BLUE        \
                                  drawing=on                         \
                                                                     \
           --clone spaces_2.music space_template                     \
           --set   spaces_2.music associated_space=8                 \
                                  icon=$SPACES_MUSIC                 \
                                  icon.highlight_color=$YELLOW       \
                                  icon.background.color=$YELLOW      \
                                  drawing=on                         \
                                                                     \
           --add   bracket        spaces_2                           \
                                  spaces_2.label                     \
                                  spaces_2.misc                      \
                                  spaces_2.doc                       \
                                  spaces_2.help                      \
                                  spaces_2.music
