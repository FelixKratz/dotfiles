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

`--minimal` and `--full` are install-time shorthands. What a machine actually
runs is a list of config groups — `desktop`, `mail`, `notes` — declared in
`~/.config/dotfiles/profile`, one per line. `install.sh` writes that file once;
after that it is yours to edit, and `link.sh` only ever reads it, so relinking
can never change what a machine is. `config/doom/profile.el` parses it into
`sf/doom-groups`, and `init.el` and `config.org` gate modules and packages with
`sf/doom-group-p`. Details and the reasoning: `docs/profiles.md`.

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

### Keyboard remapping

`bin/hidutil-remap` applies the `hidutil` key mappings, run at login and every
minute by `none.hidutil.remap`. Globally: caps lock → escape, right cmd → right
alt, right alt → right ctrl. On external PC keyboards it additionally maps
F10/F11/F12 to mute, volume down and volume up, since macOS gives those
keyboards no media keys and the Keyboard settings function-key toggle has no
effect on them.

To cover another keyboard, add its IDs to `media_keyboards` in the script:

```sh
ioreg -c IOHIDDevice -r -d1 | grep -E '"(Product|VendorID|ProductID)"'
```

A per-device mapping replaces the global one for that device rather than adding
to it, which is why the script repeats the base mappings for each keyboard it
lists.

If the built-in keyboard's F-keys stop acting as media keys — a giveaway is one
of them revealing the desktop instead — the culprit is System Settings →
Keyboard → Keyboard Shortcuts → Function Keys. That switch is global despite
the per-keyboard picker sitting above it, and the pane holds the live state:
`defaults write`/`delete` on `com.apple.keyboard.fnState` changes the stored
value without changing behaviour, so trust the switch rather than the pref.
Leave it off; the external keyboards get their volume keys from `hidutil`
regardless of how it is set.

### Updating

Safe to re-run — brew/apt skip already-installed packages, links are
overwritten.

```bash
cd ~/code/dotfiles && git pull && ./link.sh   # groups come from ~/.config/dotfiles/profile
cd ~/code/dotfiles_private && git pull  # if using private configs
```

## Key configs

- **zsh** (zim framework) - `root/zshrc`, `root/zimrc`
- **tmux** - `root/tmux.conf` (C-a prefix, vim-tmux-navigator, tpm plugins)
- **Doom Emacs** - `config/doom/` (vulpea for org-roam notes). `config.org` is
  the source: `doom sync` tangles it into `config.el` and `packages.el`, so
  edit the org file. `profile.el` decides which modules a machine gets.
- **org-roam sync** - `bin/org-roam-sync` commits, rebases and pushes
  `~/org-roam` every 15 min (launchd on macOS, systemd timer on Linux). A rebase
  conflict, or a remote unreachable for four runs, raises a nudge (below);
  the next good sync clears it. Log: `~/.log/org-roam-sync.log`.
- **nudges** - `bin/nudge` collects the standing conditions a machine wants you
  to know about: a stalled sync, an overdue `claude-projects` backup, a pending
  restart (`/var/run/reboot-required` on Linux, macOS's own pending-update list).
  Producers raise a condition and clear it when it resolves, so nothing needs
  dismissing by hand. It surfaces in the tmux status bar (`nudge bar`, wired in
  by `bin/tmux-theme-sync` — this is what reaches you over `ssht`) and in new
  shells (`nudge shell`). `nudge snooze` (prefix + `N` in tmux) buys 4h of quiet
  that expires early if the condition changes, and anything standing for a week
  drops out of the bar into `nudge list`. Polled checks run hourly from
  `launchagents/none.nudge.check.plist` or `systemd/nudge-check.timer`.
- **sbfnk-bot issues** - assign an issue to `sbfnk-bot` and `bin/sbfnk-bot-issues`
  works on it, publishing nothing until you approve. It runs every 10 min as
  its own macOS account, which cannot read your home folder, and Claude works
  in a sandboxed clone with a fresh configuration, no GitHub access and
  nothing but the issue and the repository. A second model with no tools
  screens the result for anything the issue and the repository do not
  account for. The work then waits for `bin/sbfnk-bot-review`: `approve`
  opens the draft PR (or posts the question), `answer` replies to a question
  privately, `discard` drops it. A nudge says when something waits. Only
  assignments made by sbfnk count, only sbfnk's comments are instructions,
  and only repositories in `config/sbfnk-bot/repos` are worked on. Set up a
  machine with `sudo ~/.local/bin/sbfnk-bot-setup install` (see its `--help`); elsewhere,
  put that machine's ssh alias in `~/.config/dotfiles/bot-host`.
- **Email** - `config/doom-private/email.el` (notmuch + mu4e + org-msg).
  Account-specific data is generated from `config/email/accounts.yaml` into
  `email-accounts.el` by `config/email/generate.py`; signatures live in
  `signatures.el` in the private overlay. Office365 XOAUTH2 setup and
  troubleshooting: `docs/email-xoauth2.md`.
- **Triaging mail** - flag anywhere (Outlook, phone, `F` in notmuch), then `C`
  on the message captures it as a dated TODO in `~/org-roam/mail.org` and clears
  the flag, so `tag:flagged` is the untriaged queue. `docs/mail-workflow.md`.
  `bin/org-roam-active-tags` repairs the `:active:` filetag that decides which
  notes reach the agenda; notes written outside Emacs never get it on their own.
- **Fetching mail** - `bin/getmail.sh <account>...`, `--key <notmuch key>` or
  `all`. Accounts sync in parallel, and a running account is listed in
  `~/.cache/mail-sync/`, which locks it against a second run and drives the
  sketchybar spinner. Three ways to trigger it by hand: AeroSpace `alt-m` then
  the account's notmuch search key (`a` for all), the Alfred `mail` keyword, or
  a click on the sketchybar mail item (syncs all).
- **Claude/Codex skills** - skills you write live in
  `config/claude/skills/` (and a condensed twin in `config/codex/skills/`, which
  Codex reads); `link.sh` links them entry-by-entry, so they reach every machine
  by `git pull`. A skill tracking an upstream stays its own clone instead —
  `humanizer` is a fork we merge releases into, cloned by `install.sh` and kept
  current by a hook in the private Claude settings. Skills needing Python
  packages declare them in a `requirements.txt` beside `SKILL.md`.
- **kitty** - `config/kitty/`
- **Alfred workflows** - `config/alfred/workflows/`
