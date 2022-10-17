# Source zsh plugins
source $HOME/.config/.zsh-vi-mode/zsh-vi-mode.plugin.zsh

[ -d "/opt/homebrew/share/zsh-autosuggestions/" ] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
                                                  || source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

[ -d "/opt/homebrew/share/zsh-syntax-highlighting/highlighters" ] && export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters \
                                                                  || export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters

[ -d "/opt/homebrew/share/zsh-autosuggestions/" ] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
                                                  || source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Aliases for common dirs
alias home="cd ~"

# System Aliases
alias ..="cd .."

# Git Aliases
alias add="git add"
alias commit="git commit"
alias pull="git pull"
alias stat="git status"
alias gdiff="git diff HEAD"
alias vdiff="git difftool HEAD"
alias log="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias cfg="git --git-dir=$HOME/dotfiles/ --work-tree=$HOME"


eval "$(starship init zsh)"

alias ssh="TERM=xterm-256color ssh"

alias n="nnn"
function nnn () {
    command nnn "$@"

    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
    fi
}

# Fancy sketchybar commands
function margin () {
  if [ $1 = "on" ]; then
    yabai -m config top_padding 20
    sketchybar --animate sin 30 --bar margin=10 y_offset=10 corner_radius=9
  else
    yabai -m config top_padding 10
    sketchybar --animate sin 30 --bar margin=0 y_offset=0 corner_radius=0
  fi
}

function zen () {
  ~/.config/sketchybar/plugins/zen.sh $1
}

function suyabai () {
  SHA256=$(shasum -a 256 /opt/homebrew/bin/yabai | awk "{print \$1;}")
  sudo sed -i '' -e 's/sha256:[[:alnum:]]*/sha256:'${SHA256}'/' /private/etc/sudoers.d/yabai
}

# Only load conda into path but dont actually use the bloat that comes with it
export PATH="$HOME/miniforge3/bin:/usr/local/anaconda3/bin:$PATH"
export NNN_TMPFILE="$HOME/.config/nnn/.lastd"
export EDITOR="$(which nvim)"
export VISUAL="$HOME/.config/nnn/plugins/selnew.sh"
