#!/bin/zsh

# Usage:
#   ./install.sh --full     # full desktop setup
#   ./install.sh --minimal  # shell, tmux, nvim, starship, claude only

CODE_DIR=$HOME/code
OS="$(uname)"
DOTFILES=${0:A:h}        # directory this script lives in
STATE_DIR=$HOME/.cache/dotfiles

# Re-run a step only when a watched file's contents change — a lightweight
# take on chezmoi's run_onchange_ scripts. The file's hash is recorded under
# $STATE_DIR; while it's unchanged the step is skipped.
#   run_onchange <key> <watched-file> <command> [args...]
run_onchange() {
  local key=$1 watch=$2
  shift 2
  mkdir -p $STATE_DIR
  local stamp=$STATE_DIR/$key.sha256
  local current
  current=$(shasum -a 256 "$watch" | cut -d' ' -f1)
  if [[ -f $stamp && "$current" == "$(cat $stamp)" ]]; then
    echo "Skipped $key (unchanged)"
    return 0
  fi
  "$@" && print -r -- "$current" > $stamp
}

case "${1:-}" in
  --full)    PROFILE=full ;;
  --minimal) PROFILE=minimal ;;
  *)
    echo "Usage: ./install.sh --full|--minimal"
    echo "  --full     Full desktop setup (emacs, email, window manager, etc.)"
    echo "  --minimal  Shell, tmux, nvim, starship, claude only"
    exit 1
    ;;
esac

mkdir -p $CODE_DIR

if [[ "$OS" == "Darwin" ]]; then
  # macOS Installation

  echo "Installing commandline tools..."
  xcode-select --install

  echo "Installing Brew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew analytics off

  echo "Installing essential packages..."
  run_onchange brewfile "$DOTFILES/Brewfile" brew bundle --file="$DOTFILES/Brewfile"
  brew tap homebrew/autoupdate
  brew autoupdate start --upgrade

  # tmux-urlview looks for a `urlview`/`extract_url` binary by name; point it at
  # urlscan (the maintained replacement) via a symlink in Homebrew's bin (always
  # on PATH on macOS).
  if command -v urlscan &>/dev/null; then
    ln -sf "$(command -v urlscan)" "$(brew --prefix)/bin/urlview"
  fi

  if [[ "$PROFILE" != "minimal" ]]; then
    echo "Installing full desktop packages..."
    run_onchange brewfile-full "$DOTFILES/Brewfile.full" brew bundle --file="$DOTFILES/Brewfile.full"

    # libsasl2 only loads plugins from its own keg; this copy is lost
    # whenever cyrus-sasl is rebuilt (see docs/email-xoauth2.md)
    cp "$(brew --prefix cyrus-sasl-xoauth2)"/lib/sasl2/libxoauth2.* \
       "$(brew --prefix cyrus-sasl)"/lib/sasl2/
    pipx install m365auth

    # Touch ID for sudo, the native way (macOS Sonoma+): a single PAM line in
    # sudo_local, which survives OS updates and needs no third-party tap or
    # root daemon. Replaces the old sudo-touchid formula.
    if ! grep -q 'pam_tid.so' /etc/pam.d/sudo_local 2>/dev/null; then
      echo "Enabling Touch ID for sudo (needs sudo)..."
      echo 'auth       sufficient     pam_tid.so' | sudo tee /etc/pam.d/sudo_local >/dev/null
    fi

    echo "Changing macOS defaults..."
    run_onchange macos-defaults "$DOTFILES/macos/defaults.sh" zsh "$DOTFILES/macos/defaults.sh"
  fi

  mkdir -p $HOME/Library/LaunchAgents $HOME/.log

elif [[ "$OS" == "Linux" ]]; then
  # Linux Installation
  if command -v apt-get &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y git zsh tmux neovim ripgrep jq wget curl htop btop fzf zoxide fd-find bat gh nodejs npm python3 python3-pip pipx urlscan trash-cli unzip
    [[ "$PROFILE" != "minimal" ]] && sudo apt-get install -y emacs isync mu4e msmtp openconnect
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y git zsh tmux neovim ripgrep jq wget curl htop btop fzf zoxide fd-find bat gh nodejs npm python3 python3-pip pipx urlscan trash-cli unzip
    [[ "$PROFILE" != "minimal" ]] && sudo dnf install -y emacs isync maildir-utils msmtp openconnect
  elif command -v pacman &>/dev/null; then
    sudo pacman -Syu --noconfirm git zsh tmux neovim ripgrep jq wget curl htop btop fzf zoxide fd bat github-cli nodejs npm python python-pip python-pipx urlscan trash-cli unzip yazi
    [[ "$PROFILE" != "minimal" ]] && sudo pacman -S --noconfirm emacs isync mu msmtp openconnect
  else
    echo "Warning: Unknown package manager. Please install packages manually."
  fi

  # yazi isn't in the Debian/Ubuntu/Fedora repos — install the static musl
  # binary from the latest GitHub release into ~/.local/bin (skipped where a
  # package provided it, e.g. pacman).
  if ! command -v yazi &>/dev/null; then
    echo "Installing yazi from GitHub releases..."
    YAZI_TMP=$(mktemp -d)
    if curl -fsSL -o "$YAZI_TMP/yazi.zip" \
        "https://github.com/sxyazi/yazi/releases/latest/download/yazi-$(uname -m)-unknown-linux-musl.zip" \
        && unzip -q "$YAZI_TMP/yazi.zip" -d "$YAZI_TMP"; then
      mkdir -p $HOME/.local/bin
      install "$YAZI_TMP"/yazi-*/yazi "$YAZI_TMP"/yazi-*/ya $HOME/.local/bin/
    else
      echo "Warning: yazi install failed — see https://github.com/sxyazi/yazi/releases"
    fi
    rm -rf "$YAZI_TMP"
  fi

  # Auto-empty trash items older than 30 days (mirrors macOS Finder's
  # FXRemoveOldTrashItems setting); trash-empty comes with trash-cli.
  if command -v trash-empty &>/dev/null && command -v crontab &>/dev/null; then
    if ! crontab -l 2>/dev/null | grep -q trash-empty; then
      (crontab -l 2>/dev/null; echo "@daily $(command -v trash-empty) -f 30") | crontab -
    fi
  fi

  # Install tpm (tmux plugin manager)
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing tmux plugin manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi

  # tmux-urlview looks for a `urlview`/`extract_url` binary by name; point it at
  # urlscan (the maintained replacement) via a symlink on PATH.
  if command -v urlscan &>/dev/null; then
    mkdir -p $HOME/.local/bin
    ln -sf "$(command -v urlscan)" $HOME/.local/bin/urlview
  fi

  mkdir -p $HOME/.log

else
  echo "Unknown OS: $OS"
  exit 1
fi

# Common installation (macOS and Linux)

if [[ "$PROFILE" != "minimal" ]] && [ ! -d "$HOME/.config/emacs" ]; then
  echo "Installing Doom Emacs..."
  git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
  ~/.config/emacs/bin/doom install
fi

echo "Cloning dotfiles..."
[ ! -d "$CODE_DIR/dotfiles" ] && git clone git@github.com:sbfnk/dotfiles.git $CODE_DIR/dotfiles

# Private repos are only accessible to the owner — best-effort, skip on failure.
[ ! -d "$CODE_DIR/dotfiles_private" ] && \
  git clone git@github.com:sbfnk/dotfiles_private.git $CODE_DIR/dotfiles_private \
    2>/dev/null || true
[[ "$PROFILE" != "minimal" ]] && [ ! -d "$CODE_DIR/email-config" ] && \
  git clone git@github.com:sbfnk/email-config.git $CODE_DIR/email-config \
    2>/dev/null || true

# Enable the gitleaks pre-commit hook (idempotent — safe to re-run).
git -C "$CODE_DIR/dotfiles" config core.hooksPath .githooks

$CODE_DIR/dotfiles/link.sh --$PROFILE

# macOS-only post-installation (full mode)
if [[ "$OS" == "Darwin" ]] && [[ "$PROFILE" != "minimal" ]]; then
  # Load everything in ~/Library/LaunchAgents starting with our `none.` prefix.
  # This covers both static plists installed by link.sh and per-account mail
  # plists written by generate.py (so the loop doesn't need to know which is
  # which).
  for file in $HOME/Library/LaunchAgents/none.*.plist; do
    [ -e "$file" ] || continue
    filename=$(basename $file .plist)
    launchctl load "$file" 2>/dev/null
    launchctl start "$filename"
  done

  git clone git@github.com:shaunsingh/SFMono-Nerd-Font-Ligaturized.git /tmp/SFMono_Nerd_Font
  mv /tmp/SFMono_Nerd_Font/* $HOME/Library/Fonts
  rm -rf /tmp/SFMono_Nerd_Font/

  curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v1.0.23/sketchybar-app-font.ttf \
    -o $HOME/Library/Fonts/sketchybar-app-font.ttf

  echo "Installing Alfred workflows..."
  for workflow in $CODE_DIR/dotfiles/config/alfred/workflows/*.alfredworkflow; do
    [ -f "$workflow" ] && open "$workflow" && sleep 2
  done

  echo "Starting Services (grant permissions)..."
  open /Applications/AeroSpace.app
  brew services start sketchybar
  brew services start svim
fi

echo "Installation complete.\n"
