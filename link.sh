#!/bin/zsh

# Re-link dotfiles (safe to run multiple times, works on macOS and Linux)
#
# Usage:
#   ./link.sh --full     # full desktop setup
#   ./link.sh --minimal  # shell, tmux, nvim, starship, claude only

CODE_DIR=$HOME/code
OS="$(uname)"

case "${1:-}" in
  --full)    PROFILE=full ;;
  --minimal) PROFILE=minimal ;;
  *)
    echo "Usage: ./link.sh --full|--minimal"
    echo "  --full     Full desktop setup (emacs, email, window manager, etc.)"
    echo "  --minimal  Shell, tmux, nvim, starship, claude only"
    exit 1
    ;;
esac

# macOS ln uses -h, GNU ln uses -n to avoid following existing symlinks
[[ "$OS" == "Darwin" ]] && LN_FLAG="-sfh" || LN_FLAG="-sfn"

# Desktop-only configs (skipped in minimal mode)
DESKTOP_ONLY=(aerospace alfred doom kitty sketchybar svim email doom-private goimapnotify oauth2ms github-copilot)

mkdir -p $HOME/.config
[[ "$OS" == "Darwin" ]] && mkdir -p $HOME/Library/LaunchAgents

for dir in $CODE_DIR/dotfiles*; do
  if [ -d $dir/config ]; then
    for file in $dir/config/*; do
      name="$(basename $file)"

      # Skip desktop-only configs in minimal mode
      if [[ "$PROFILE" == "minimal" ]] && (( ${DESKTOP_ONLY[(Ie)$name]} )); then
        echo "Skipped $name (minimal mode)"
        continue
      fi

      case "$name" in
        claude)
          # Claude Code config: only link shareable config, not runtime state
          # Runtime state (history.jsonl, cache/, projects/, etc.) stays local
          mkdir -p $HOME/.claude
          for entry in CLAUDE.md settings.json; do
            cf="$file/$entry"
            [ -e "$cf" ] || continue
            ln $LN_FLAG $cf $HOME/.claude/
            echo "Linked $cf → ~/.claude/$entry"
          done
          # Link agents/commands/skills entry-by-entry so both dotfiles and
          # dotfiles_private can contribute, and locally-installed skills (e.g.
          # humanizer) survive. Replace any legacy whole-dir symlink.
          for subdir in agents commands skills; do
            sd="$file/$subdir"
            [ -d "$sd" ] || continue
            [ -L "$HOME/.claude/$subdir" ] && rm "$HOME/.claude/$subdir"
            mkdir -p "$HOME/.claude/$subdir"
            for f in $sd/*; do
              [ -e "$f" ] || continue
              ln $LN_FLAG "$f" "$HOME/.claude/$subdir/"
              echo "Linked $f → ~/.claude/$subdir/$(basename $f)"
            done
          done
          ;;
        email|doom-private)
          # These configs are split across dotfiles and dotfiles_private:
          #   email/        — scripts/docs in public, accounts.yaml in private
          #   doom-private/ — generic elisp in public, generated/personal in private
          # Link file-by-file so both repos contribute to ~/.config/<name>/.
          [ -L "$HOME/.config/$name" ] && rm "$HOME/.config/$name"
          mkdir -p "$HOME/.config/$name"
          for f in $file/*; do
            [ -e "$f" ] || continue
            ln $LN_FLAG "$f" "$HOME/.config/$name/"
            echo "Linked $f → ~/.config/$name/$(basename $f)"
          done
          ;;
        *)
          ln $LN_FLAG $file $HOME/.config
          echo "Linked $file → ~/.config/$name"
          ;;
      esac
    done
  fi

  if [ -d $dir/root ]; then
    for file in $dir/root/*; do
      ln $LN_FLAG $file $HOME/.$(basename $file)
      echo "Linked $file → ~/.$(basename $file)"
    done
  fi

  if [[ "$OS" == "Darwin" ]] && [ -d "$dir/Application Support" ]; then
    for file in "$dir/Application Support"/*; do
      ln $LN_FLAG "$file" "$HOME/Library/Application Support"
      echo "Linked $file → ~/Library/Application Support/$(basename "$file")"
    done
  fi
done

if [[ "$OS" == "Darwin" ]]; then
  mkdir -p $HOME/Library/LaunchAgents
  for file in $CODE_DIR/dotfiles/launchagents/*; do
    dest=$HOME/Library/LaunchAgents/$(basename $file)
    # Plists can't expand $HOME at runtime, so we substitute it at install
    # time. Remove any legacy symlink first to avoid writing through it
    # back into the repo.
    [ -L "$dest" ] && rm "$dest"
    sed "s|__HOME__|$HOME|g" "$file" > "$dest"
    echo "Generated $dest"
  done
fi

# Link scripts to ~/.local/bin
mkdir -p ~/.local/bin ~/.msmtpq
for file in $CODE_DIR/dotfiles/bin/*; do
  ln $LN_FLAG $file ~/.local/bin/
  echo "Linked $file → ~/.local/bin/$(basename $file)"
done

echo "\nDone."
[[ "$PROFILE" != "minimal" ]] && echo "Run 'doom sync' if Emacs config changed."
