# dotfiles

Configuration files for macOS and Linux.

## Structure

```
root/          → symlinked to ~/.<filename> (zshrc, tmux.conf, etc.)
config/        → symlinked to ~/.config/<dirname> (doom, kitty, alfred, etc.)
bin/           → symlinked to ~/.local/bin/
launchagents/  → symlinked to ~/Library/LaunchAgents/ (macOS only)
docs/          → reference material (org-roam workflow, slide style, etc.)
.githooks/     → gitleaks pre-commit hook (activated by install.sh)
```

Private configurations (calendar aliases, email accounts, etc.) live in a
separate `dotfiles_private` repo with the same structure.

`install.sh` activates a gitleaks pre-commit hook (`core.hooksPath
.githooks`) that scans staged changes for credentials. Bypass with
`--no-verify` only if a finding is a confirmed false positive.

## Setup

### Desktop machine

```bash
git clone <repo> ~/code/dotfiles
git clone <private-repo> ~/code/dotfiles_private
cd ~/code/dotfiles
./install.sh --full   # installs packages, links configs, sets up services
```

### Production/remote machine

```bash
git clone <repo> ~/code/dotfiles
git clone <private-repo> ~/code/dotfiles_private  # optional
cd ~/code/dotfiles
./install.sh --minimal  # just shell essentials (zsh, tmux, nvim, ripgrep, etc.)
```

### Updating

Safe to re-run — brew/apt skip already-installed packages, links are
overwritten.

```bash
cd ~/code/dotfiles && git pull && ./install.sh --full    # or --minimal
cd ~/code/dotfiles_private && git pull  # if using private configs
```

## Key configs

- **zsh** (zim framework) - `root/zshrc`, `root/zimrc`
- **tmux** - `root/tmux.conf` (C-a prefix, vim-tmux-navigator, tpm plugins)
- **Doom Emacs** - `config/doom/` (vulpea for org-roam notes)
- **kitty** - `config/kitty/`
- **Alfred workflows** - `config/alfred/workflows/`
