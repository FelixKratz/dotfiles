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

## Public + private split

Personal data (real email accounts, signatures, calendar IDs, etc.) lives in
a separate `dotfiles_private` repo with the same directory layout. `link.sh`
walks both `~/code/dotfiles` and `~/code/dotfiles_private`. For most paths the
private repo wins (its symlink overrides the public one). For these
directories `link.sh` merges file-by-file so both repos contribute entries:

- `config/claude/agents/`, `config/claude/commands/` → `~/.claude/`
- `config/email/`                                    → `~/.config/email/`
- `config/doom-private/`                             → `~/.config/doom-private/`

`install.sh` clones `dotfiles_private` best-effort: if you don't have access,
the clone fails silently and only the public configuration is linked.

`install.sh` also activates a gitleaks pre-commit hook (`core.hooksPath
.githooks`) on the public repo that scans staged changes for credentials.
Bypass with `--no-verify` only if a finding is a confirmed false positive.

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

### Forking

`./install.sh --minimal` works without `dotfiles_private` access — you get
shell, tmux, nvim, ripgrep, etc. For `--full`, populate your own private
overlay first:

- `config/email/accounts.yaml` — copy `config/email/accounts.example.yaml`,
  fill in your accounts. Run `~/.config/email/generate.py --write` to emit
  `~/.mbsyncrc`, `~/.msmtprc`, `~/.config/doom-private/email-accounts.el`,
  and one `~/Library/LaunchAgents/none.mail.<account>.plist` per account
  (polls inbox every 5 min via `getmail.sh`).
- `config/doom-private/signatures.el` — `(setq sf/email-signatures '(("name"
  . "body") ...))`. Loaded with no-error by `email.el`.
- launchagents: keep the `__HOME__` placeholder in the plist source. `link.sh`
  substitutes `$HOME` at install time and writes real files to
  `~/Library/LaunchAgents/`.

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
- **Email** - `config/doom-private/email.el` (notmuch + mu4e + org-msg).
  Account-specific data is generated from `config/email/accounts.yaml` into
  `email-accounts.el` by `config/email/generate.py`; signatures live in
  `signatures.el` in the private overlay.
- **kitty** - `config/kitty/`
- **Alfred workflows** - `config/alfred/workflows/`
