#!/bin/zsh

SAVE_DIR=$(pwd)
CODE_DIR=$HOME/code

mkdir $CODE_DIR

# Install xCode cli tools
echo "Installing commandline tools..."
xcode-select --install

# Homebrew
## Install
echo "Installing Brew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

## Taps
echo "Tapping Brew..."
brew tap homebrew/cask-fonts
brew tap FelixKratz/formulae
brew tap koekeishiya/formulae
brew tap d12frosted/emacs-plus
brew tap artginzburg/tap
brew tap sbfnk/formulae

## Formulae
echo "Installing Brew Formulae..."
### Essentials
brew install gsl
brew install llvm
brew install boost
brew install libomp
brew install python

### Tools
brew install wget
brew install tmux
brew install ripgrep
brew install mas
brew install gh
brew install ifstat
brew install switchaudio-osx
brew install sketchybar
brew install borders
brew install yabai
brew install nnn
brew install jq

## sudo
brew install --cask git-credential-manager
brew install sudo-touchid
brew services start sudo-touchid

### Science
brew install mactex

### Terminal
brew install neovim

### Nice to have
brew install btop
brew install svim

### Additional apps
brew install dropbox
brew install mailmate
brew install slack

### Emacs
brew install emacs-plus
brew install --HEAD sbfnk/formulae/isync
brew install mu
brew install msmtp
brew install timelimit

### Python tools (m365auth for OAuth2)
pipx install m365auth

## Casks
echo "Installing Brew Casks..."
### Terminals & Browsers
brew install --cask kitty
brew install --cask 1password
brew install --cask arc

### R
brew install --cask r

### Office
brew install --cask inkscape
brew install --cask zoom
brew install --cask skim
brew install --cask busycal

### Essential
brew install --cask karabiner-elements

### Nice to have
brew install --cask alfred
brew install --cask spotify
brew install --cask telegram
brew install --cask whatsapp

### Fonts
brew install --cask sf-symbols
brew install --cask font-hack-nerd-font
brew install --cask font-jetbrains-mono
brew install --cask font-fira-code

# Mac App Store Apps
echo "Installing Mac App Store Apps..."
mas install 360593530 #Notability

# macOS Settings
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

## prepare directories for launchagents
mkdir -p $HOME/Library/LaunchAgents
mkdir -p $HOME/.log

## install doom emacs
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

# Copying and checking out configuration files
echo "Planting Configuration Files..."
git clone git@github.com:sbfnk/dotfiles.git $CODE_DIR/dotfiles
git clone git@github.com:sbfnk/dotfiles_private.git $CODE_DIR/dotfiles_private
git clone git@github.com:sbfnk/email-config.git $CODE_DIR/email-config

# linking dot files
$CODE_DIR/dotfiles/link.sh

# load and start launchagents
for file in $CODE_DIR/dotfiles/launchagents/*; do
  filename=$(basename $file .plist)
  launchctl load $HOME/Library/LaunchAgents/$filename.plist
  launchctl start $filename
done

# Installing Fonts
git clone git@github.com:shaunsingh/SFMono-Nerd-Font-Ligaturized.git /tmp/SFMono_Nerd_Font
mv /tmp/SFMono_Nerd_Font/* $HOME/Library/Fonts
rm -rf /tmp/SFMono_Nerd_Font/

curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v1.0.23/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf

# Start Services
echo "Starting Services (grant permissions)..."
yabai --start-service
skhd --start-service
brew services start sketchybar
brew services start borders
brew services start svim

csrutil status
echo "Add sudoer manually:\n '$(whoami) ALL = (root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | awk "{print \$1;}") $(which yabai) --load-sa' to '/private/etc/sudoers.d/yabai'"

cd $SAVE_DIR
echo "Installation complete...\n"
