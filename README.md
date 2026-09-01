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
./install.sh --minimal  # shell essentials (zsh, tmux, nvim, ripgrep, ...) + Emacs
```

### Profiles

| | `--minimal` | `--full` |
|---|---|---|
| shell, tmux, nvim, ripgrep, fzf, yazi, gh | ✅ | ✅ |
| Emacs + Doom (magit, file editing) | ✅ | ✅ |
| org-mode, org-roam notes, bibliography, PDF, Jupyter | | ✅ |
| vterm (needs a C toolchain to build its module) | | ✅ |
| mail (isync, notmuch, msmtp), openconnect | | ✅ |
| window manager, terminal, launcher and other GUI configs | | ✅ |
| systemd timers / launch agents (org-roam sync, mail polling) | | ✅ |

`link.sh` records the profile in `~/.cache/dotfiles/profile`, and
`config/doom/profile.el` reads it into `sf/doom-full`. `init.el` gates the
desktop-only Doom modules on that variable and `config.org` gates the matching
packages, so a `--minimal` machine builds Emacs for magit and editing without
pulling in org-roam, mail or the writing tools. Machines with no marker file
are treated as full, so existing setups are unaffected.

On Linux, Emacs installs as the text-only build with weak dependencies
disabled: the `emacs` metapackage otherwise brings in the GTK build along with
postfix, mailutils and the MySQL/Postgres client libraries.

### Forking

`./install.sh --minimal` works without `dotfiles_private` access — you get
shell, tmux, nvim, ripgrep and Emacs. For `--full`, populate your own private
overlay first:

- `config/email/accounts.yaml` — copy `config/email/accounts.example.yaml`,
  fill in your accounts. Run `~/.config/email/generate.py --write` to emit
  `~/.mbsyncrc`, `~/.msmtprc`, `~/.config/doom-private/email-accounts.el`,
  and one `~/Library/LaunchAgents/none.mail.<account>.plist` per account
  (polls inbox every 15 min via `getmail.sh`, as a backstop for the IMAP IDLE
  agent).
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
- **Doom Emacs** - `config/doom/` (vulpea for org-roam notes). `config.org` is
  the source: `doom sync` tangles it into `config.el` and `packages.el`, so
  edit the org file. `profile.el` decides which modules a machine gets.
- **org-roam sync** - `bin/org-roam-sync` commits, rebases and pushes
  `~/org-roam` every 15 min (launchd on macOS, systemd timer on Linux). When it
  needs a hand — a rebase conflict, or a remote unreachable for four runs — it
  writes `~/.local/state/org-roam-sync/stalled`, sends a desktop notification,
  and every new shell greets you with the reason until the next good sync
  clears it. Attached tmux sessions show a red `roam sync stalled` segment in
  the status bar (`bin/org-roam-stall-status`, wired in by `bin/tmux-theme-sync`),
  which is what surfaces it over `ssht`. Log: `~/.log/org-roam-sync.log`.
- **Email** - `config/doom-private/email.el` (notmuch + mu4e + org-msg).
  Account-specific data is generated from `config/email/accounts.yaml` into
  `email-accounts.el` by `config/email/generate.py`; signatures live in
  `signatures.el` in the private overlay. Office365 XOAUTH2 setup and
  troubleshooting: `docs/email-xoauth2.md`.
- **Fetching mail** - `bin/getmail.sh <account>...`, `--key <notmuch key>` or
  `all`. Accounts sync in parallel, and a running account is listed in
  `~/.cache/mail-sync/`, which locks it against a second run and drives the
  sketchybar spinner. Three ways to trigger it by hand: AeroSpace `alt-m` then
  the account's notmuch search key (`a` for all), the Alfred `mail` keyword, or
  a click on the sketchybar mail item (syncs all).
- **kitty** - `config/kitty/`
- **Alfred workflows** - `config/alfred/workflows/`
