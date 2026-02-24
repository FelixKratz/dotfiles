# Terminal title: show current directory basename
zstyle ':zim:termtitle' format '%1~'

# Aliases for common dirs
alias home="cd ~"

# System Aliases
alias ..="cd .."
alias x="exit"

# Git Aliases
alias add="git add"
alias commit="git commit"
alias pull="git pull"
alias stat="git status"
alias gdiff="git diff HEAD"
alias vdiff="git difftool HEAD"
alias log="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias cfg="git --git-dir=$HOME/dotfiles/ --work-tree=$HOME"
alias push="git push"
alias g="lazygit"


eval "$(starship init zsh)"

alias ssh="TERM=xterm-256color ssh"

# Sketchybar interactivity overloads
function brew() {
  command brew "$@" 

  if [[ $* =~ "upgrade" ]] || [[ $* =~ "update" ]] || [[ $* =~ "outdated" ]]; then
    sketchybar --trigger brew_update
  fi
}

alias n="nnn"
function nnn () {
    command nnn "$@"

    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
    fi
}

function zen () {
  ~/.config/sketchybar/plugins/zen.sh $1
}

function kill () {
  command kill -KILL $(pidof "$@")
}


# Only load conda into path but dont actually use the bloat that comes with it
export PATH="$HOME/miniforge3/bin:/usr/local/anaconda3/bin:$PATH"
export NNN_TMPFILE="$HOME/.config/nnn/.lastd"
export EDITOR="$(which nvim)"
export VISUAL="$(which nvim)"
export MANPAGER="$(which nvim) +Man!"
export XDG_CONFIG_HOME="$HOME/.config"

# Handy du summary: depth 1, sorted by size
alias du1='du -hd 1 | sort -h'
