#!/bin/zsh

# Re-link dotfiles (safe to run multiple times)

CODE_DIR=$HOME/code

mkdir -p $HOME/.config
mkdir -p $HOME/Library/LaunchAgents

for dir in $CODE_DIR/dotfiles*; do
  if [ -d $dir/config ]; then
    for file in $dir/config/*; do
      ln -sfh $file $HOME/.config
      echo "Linked $file → ~/.config/$(basename $file)"
    done
  fi
  if [ -d $dir/root ]; then
    for file in $dir/root/*; do
      ln -sfh $file $HOME/.$(basename $file)
      echo "Linked $file → ~/.$(basename $file)"
    done
  fi
  if [ -d "$dir/Application Support" ]; then
    for file in "$dir/Application Support"/*; do
      ln -sf "$file" "$HOME/Library/Application Support"
      echo "Linked $file → ~/Library/Application Support/$(basename "$file")"
    done
  fi
done

for file in $CODE_DIR/dotfiles/launchagents/*; do
  ln -sf $file $HOME/Library/LaunchAgents
  echo "Linked $file → ~/Library/LaunchAgents/$(basename $file)"
done

# Link scripts to ~/.local/bin
mkdir -p ~/.local/bin
mkdir -p ~/.msmtpq
for file in $CODE_DIR/dotfiles/bin/*; do
  ln -sf $file ~/.local/bin/
  echo "Linked $file → ~/.local/bin/$(basename $file)"
done

# Keep ~/bin as symlink for backwards compatibility
ln -sfh $CODE_DIR/dotfiles/bin ~/bin
echo "Linked bin → ~/bin"

echo "\nDone. Run 'doom sync' if Emacs config changed."
