#!/bin/zsh

# Usage:
#   ./install.sh --full     # full desktop setup
#   ./install.sh --minimal  # shell, tmux, nvim, starship, claude only

CODE_DIR=$HOME/code
OS="$(uname)"

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
  brew install git wget tmux ripgrep gh jq node neovim btop python

  if [[ "$PROFILE" != "minimal" ]]; then
    echo "Tapping Brew..."
    brew tap homebrew/cask-fonts
    brew tap FelixKratz/formulae
    brew tap nikitabobko/tap
    brew tap d12frosted/emacs-plus
    brew tap artginzburg/tap
    brew tap sbfnk/formulae

    echo "Installing Brew Formulae..."
    brew install gsl llvm boost libomp
    brew install mas ifstat switchaudio-osx sketchybar ical-buddy nnn
    brew install --cask git-credential-manager
    brew install sudo-touchid
    brew services start sudo-touchid
    brew install mactex svim
    brew install dropbox mailmate slack
    brew install emacs-plus
    brew install --HEAD sbfnk/formulae/isync
    brew install mu msmtp timelimit
    pipx install m365auth

    echo "Installing Brew Casks..."
    brew install --cask kitty 1password arc r inkscape zoom skim
    brew install --cask nikitabobko/tap/aerospace
    brew install --cask alfred spotify telegram whatsapp
    brew install --cask sf-symbols font-hack-nerd-font font-jetbrains-mono font-fira-code

    echo "Installing Mac App Store Apps..."
    mas install 360593530 # Notability

    echo "Changing macOS defaults..."
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock "mru-spaces" -bool "false"
    defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
    defaults write com.apple.LaunchServices LSQuarantine -bool false
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write NSGlobalDomain _HIHideMenuBar -bool true
    defaults write NSGlobalDomain AppleHighlightColor -string "0.65098 0.85490 0.58431"
    defaults write NSGlobalDomain AppleAccentColor -int 1
    defaults write com.apple.screencapture location -string "$HOME/Desktop"
    defaults write com.apple.screencapture disable-shadow -bool true
    defaults write com.apple.screencapture type -string "png"
    defaults write com.apple.finder DisableAllAnimations -bool true
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
    defaults write com.apple.Finder AppleShowAllFiles -bool true
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    defaults write com.apple.finder ShowStatusBar -bool false
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool YES
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
    defaults write com.freron.MailMate MmMessagesOutlineMoveStrategy -string "unreadOrPrevious"
  fi

  mkdir -p $HOME/Library/LaunchAgents $HOME/.log

elif [[ "$OS" == "Linux" ]]; then
  # Linux Installation
  if command -v apt-get &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y git zsh tmux neovim ripgrep jq wget curl htop btop fzf zoxide fd-find bat gh nodejs npm python3 python3-pip pipx
    [[ "$PROFILE" != "minimal" ]] && sudo apt-get install -y emacs isync mu4e msmtp openconnect
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y git zsh tmux neovim ripgrep jq wget curl htop btop fzf zoxide fd-find bat gh nodejs npm python3 python3-pip pipx
    [[ "$PROFILE" != "minimal" ]] && sudo dnf install -y emacs isync maildir-utils msmtp openconnect
  elif command -v pacman &>/dev/null; then
    sudo pacman -Syu --noconfirm git zsh tmux neovim ripgrep jq wget curl htop btop fzf zoxide fd bat github-cli nodejs npm python python-pip python-pipx
    [[ "$PROFILE" != "minimal" ]] && sudo pacman -S --noconfirm emacs isync mu msmtp openconnect
  else
    echo "Warning: Unknown package manager. Please install packages manually."
  fi

  # Install tpm (tmux plugin manager)
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing tmux plugin manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
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
[ ! -d "$CODE_DIR/dotfiles_private" ] && git clone git@github.com:sbfnk/dotfiles_private.git $CODE_DIR/dotfiles_private
[[ "$PROFILE" != "minimal" ]] && [ ! -d "$CODE_DIR/email-config" ] && git clone git@github.com:sbfnk/email-config.git $CODE_DIR/email-config

$CODE_DIR/dotfiles/link.sh --$PROFILE

# macOS-only post-installation (full mode)
if [[ "$OS" == "Darwin" ]] && [[ "$PROFILE" != "minimal" ]]; then
  for file in $CODE_DIR/dotfiles/launchagents/*; do
    filename=$(basename $file .plist)
    launchctl load $HOME/Library/LaunchAgents/$filename.plist
    launchctl start $filename
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
