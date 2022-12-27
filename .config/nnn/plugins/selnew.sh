#!/usr/bin/env sh

sel="$HOME/.config/nnn/.selection"
targets=()
if [ -s "$sel" ]; then
  while IFS= read -r -d '' entry || [ -n "$entry" ]; do
    targets+=("\"$entry\"")
  done < "$sel"
else
  targets+=("\"$*\"")
fi

alacritty msg create-window -e zsh -c "cd \"$PWD\" && export PATH="$PATH" && source $HOME/.zshrc && sleep 0.1 && $(which nvim) ${targets[*]}"
