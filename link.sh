#!/bin/zsh

# Re-link dotfiles (safe to run multiple times, works on macOS and Linux)

CODE_DIR=$HOME/code

# macOS ln uses -h, GNU ln uses -n to avoid following existing symlinks
if [[ "$(uname)" == "Darwin" ]]; then
  LN_FLAG="-sfh"
else
  LN_FLAG="-sfn"
fi

mkdir -p $HOME/.config
if [[ "$(uname)" == "Darwin" ]]; then
  mkdir -p $HOME/Library/LaunchAgents
fi

for dir in $CODE_DIR/dotfiles*; do
  if [ -d $dir/config ]; then
    for file in $dir/config/*; do
      ln $LN_FLAG $file $HOME/.config
      echo "Linked $file → ~/.config/$(basename $file)"
    done
  fi
  if [ -d $dir/root ]; then
    for file in $dir/root/*; do
      ln $LN_FLAG $file $HOME/.$(basename $file)
      echo "Linked $file → ~/.$(basename $file)"
    done
  fi
  if [[ "$(uname)" == "Darwin" ]] && [ -d "$dir/Application Support" ]; then
    for file in "$dir/Application Support"/*; do
      ln $LN_FLAG "$file" "$HOME/Library/Application Support"
      echo "Linked $file → ~/Library/Application Support/$(basename "$file")"
    done
  fi
done

if [[ "$(uname)" == "Darwin" ]]; then
  for file in $CODE_DIR/dotfiles/launchagents/*; do
    ln $LN_FLAG $file $HOME/Library/LaunchAgents
    echo "Linked $file → ~/Library/LaunchAgents/$(basename $file)"
  done
fi

# Link scripts to ~/.local/bin
mkdir -p ~/.local/bin
mkdir -p ~/.msmtpq
for file in $CODE_DIR/dotfiles/bin/*; do
  ln $LN_FLAG $file ~/.local/bin/
  echo "Linked $file → ~/.local/bin/$(basename $file)"
done

# Email config generator (accounts.yaml is in dotfiles_private/config/email)
if [ -d $CODE_DIR/email-config ]; then
  ln $LN_FLAG $CODE_DIR/email-config/generate.py $HOME/.config/email/
  echo "Linked generate.py → ~/.config/email/"
fi

echo "\nDone. Run 'doom sync' if Emacs config changed."
