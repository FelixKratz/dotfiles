#!/bin/bash

# Open sbfnk-bot-review in a new kitty window, through kitty's remote-control
# socket so it lands in the running instance, or as a new instance otherwise.

CMD='sbfnk-bot-review; exec zsh'
SOCK=$(ls /tmp/kitty-* 2>/dev/null | head -1)

if [ -n "$SOCK" ] && /Applications/kitty.app/Contents/MacOS/kitten @ \
  --to "unix:$SOCK" launch --type=os-window zsh -ic "$CMD" >/dev/null 2>&1; then
  exit 0
fi
open -na kitty --args zsh -ic "$CMD"
