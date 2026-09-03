# Machine profiles

What a machine runs is declared in `~/.config/dotfiles/profile`, one config
group per line. Blank lines and `#` comments are ignored.

```
# Config groups this machine runs.
desktop
mail
notes
```

## Groups

| Group | Configs linked | Doom modules |
|---|---|---|
| `desktop` | aerospace, alfred, kitty, sketchybar, svim, github-copilot | vterm, pdf, ein, grammar, biblio, collab, atomic-chrome, bluesky |
| `mail` | email, doom-private, goimapnotify, oauth2ms | notmuch, the `mail-config.el` chapter, org-msg, telega, mastodon |
| `notes` | — | org, vulpea, org-ref, the `notes.el` chapter |

Anything not owned by a group is linked everywhere: shell, tmux, nvim, doom,
starship, yazi, claude, codex. A machine that declares no groups still gets
Emacs for magit and file editing.

## The rule

**`link.sh` reads this file and never writes it.** It takes no arguments — the
profile is a property of the machine, declared once by hand, so no routine
command can change what a machine is.

Only two things write it:

- `install.sh`, once, on a machine that has no profile yet. `--minimal` writes
  an empty group list; otherwise it writes all three.
- You, with an editor, when a machine's role changes.

Adding or dropping a group takes effect on the next `./link.sh`, and for Emacs
after `doom sync` and a restart — `init.el` chooses its module list from the
same file.

### Why it works this way

`link.sh` used to take `--full`/`--minimal` and write the answer to
`~/.cache/dotfiles/profile` as a side effect. Two problems followed from that.

Running `./link.sh --minimal` on a desktop — a reasonable thing to want, if you
only mean to refresh the shell and editor configs — silently demoted the
machine. It happened here in August 2026: the marker read `minimal` for a
fortnight while every desktop config stayed linked and working, because the
tangled `config.el` predated the gating and loaded mail unconditionally. The
next `doom sync` regenerated `config.el` with the gate in place, and mail and
notes vanished from Emacs with no error to search for — `SPC e` was simply
undefined.

The second problem was that one word answered two questions: *what should this
run* and *what am I linking right now*. Those want to be separate, so they are.

A cache directory was also the wrong home for a hand-edited declaration, hence
the move to `~/.config/dotfiles/profile`.

## Checking

`profile.el` warns at startup if the file is missing and enables no groups —
failing closed, since a machine loading mail modules it has no binaries for is
worse off than one loading none. `link.sh` refuses to run at all and prints the
file to create.

From Emacs, `sf/doom-groups` holds the parsed list and `(sf/doom-group-p 'mail)`
tests one. `sf/doom-full` survives as an alias for the `desktop` group, used by
gates not yet sorted into a more specific one.
