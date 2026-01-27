# dotfiles

Configuration files for macOS and Linux.

## Structure

```
root/          → symlinked to ~/.<filename> (zshrc, tmux.conf, etc.)
config/        → symlinked to ~/.config/<dirname> (doom, kitty, alfred, etc.)
bin/           → symlinked to ~/.local/bin/
launchagents/  → symlinked to ~/Library/LaunchAgents/ (macOS only)
```

Private configurations (calendar aliases, email accounts, etc.) live in a
separate `dotfiles_private` repo with the same structure.

## Setup

### Fresh machine

```bash
git clone <repo> ~/code/dotfiles
git clone <private-repo> ~/code/dotfiles_private
cd ~/code/dotfiles
./install.sh   # macOS only: installs Homebrew packages, fonts, etc.
./link.sh      # symlinks configs (works on macOS and Linux)
```

### Remote/Linux machine

Only `link.sh` is needed. It detects the OS and skips macOS-specific paths
(LaunchAgents, Application Support).

```bash
git clone <repo> ~/code/dotfiles
git clone <private-repo> ~/code/dotfiles_private  # optional
cd ~/code/dotfiles && ./link.sh
```

### Updating

```bash
cd ~/code/dotfiles && git pull && ./link.sh
cd ~/code/dotfiles_private && git pull  # if using private configs
```

## Key configs

- **zsh** (zim framework) - `root/zshrc`, `root/zimrc`
- **tmux** - `root/tmux.conf` (C-a prefix, vim-tmux-navigator, tpm plugins)
- **Doom Emacs** - `config/doom/` (vulpea for org-roam notes)
- **kitty** - `config/kitty/`
- **Alfred workflows** - `config/alfred/workflows/`
