# Mail workflow

How flagged mail becomes a dated TODO. Config lives in
`config/doom-private/email.el` (notmuch side) and `config/doom/config.org`
(capture templates); notes land in `~/org-roam/mail.org`.

## The one rule

A flag means *needs an answer and hasn't had one*. Capturing clears it, so
`tag:flagged` is the queue of things not yet turned into tasks. If it is
sitting above about ten, there is a backlog.

## The loop

1. **Flag anywhere.** Outlook, phone, or `F` in notmuch. Flags round-trip over
   IMAP as maildir flags, so it does not matter where you are when you flag.
2. **At the computer, work the queue.** `SPC e e` then the `=` saved search, or
   the Flagged link under Queries in `mail.org`.
3. **On each message press `C`**, pick a template. The message becomes a TODO in
   `mail.org` with a link back to it, and the flag clears — including in
   Outlook, once mbsync next runs.
4. **Do the TODOs from the agenda** — `SPC n a`. `RET` on the link reopens the
   message.

## Keys

| Key | Where | Does |
|---|---|---|
| `F` | show, search | toggle the flag |
| `C` | show, tree/unthreaded | capture and clear the flag |
| `e r` | capture menu | reply needed |
| `e d` | capture menu | decision needed |
| `e R` | capture menu | read later |

`C` is not bound in search mode: `ol-notmuch` cannot store a link from there.
The flagged search opens unthreaded, so this rarely bites.

## The three templates

- **`e r` reply** — files under `* Reply`. Prompts for a deadline. For mail that
  needs a fifteen-minute answer; three days is usually right.
- **`e d` decide** — files under `* Decide`. Prompts for *the question* and a
  deadline. Use it for invitations, review requests and anything where the
  answer is yes or no with consequences. Writing the question down is the point:
  "Priesemann" tells you nothing later, "go to Göttingen for a week?" does.
- **`e R` read** — files under `* Read`. No prompts, no deadline, finishes
  immediately. Reading is cheap; it does not need ceremony.

Aborting a capture with `C-c C-k` leaves the flag alone, so nothing falls
through a half-finished capture.

The date you give at capture is what keeps the task out of sight until it
matters: the agenda shows what is due, while `org-todo-list` lists every open
task regardless of date. Work from `SPC n a`; keep `org-todo-list` for a
stocktake. An `er` or `ed` capture always has a date, so it will surface on the
day you chose. An `eR` read-later has none, so it collects in the "Unscheduled"
block of the same agenda until you give it one or kill it.

## Queries

`mail.org` keeps a `* Queries` heading of `notmuch:` search links — flagged,
flagged over a month old, flagged with no reply over three months old, unread
work mail. Click one to open the search. The stale ones are worth a look after
any period of leave, when mail arrives with nobody sweeping up behind it.

## Agenda visibility, and how it breaks

`org-agenda-files` is built by `vulpea-active-files`, which queries the vulpea
DB for notes tagged `:active:`. That tag is maintained by
`vulpea-active-update-tag` on `find-file-hook` and `before-save-hook` — only
when a file passes through an Emacs buffer.

So a note written by anything else (an AI session, a sync from another machine)
can gain its first TODO and never get tagged, and its tasks stay invisible to
the agenda indefinitely. This is not hypothetical: twenty notes were in that
state in September 2026, including the FFLP file holding an `[#A]` task due that
week.

    bin/org-roam-active-tags          # list mismatches
    bin/org-roam-active-tags --fix    # correct them

Worth running after any stretch of notes being maintained outside Emacs. The
agenda reads the DB rather than the files, so restart Emacs or resync vulpea
afterwards.

`mail.org` shows up as a mismatch whenever it holds no TODOs — vulpea would
untag it. Harmless: the first capture puts the tag back.

## Gotchas

- `config/doom/config.el` is tangled from `config.org` and gitignored. Edit the
  org file and run `doom sync`.
- There is exactly one `setq org-capture-templates`, in `config.org`. A second
  one existed in the vulpea module and, because `setq` replaces the list rather
  than adding to it, whichever loaded last silently dropped the other's
  templates. Add to the existing list; do not start a new one.
- `ol-notmuch` stores `:subject`, `:from`, `:to`, `:date` — but no `:fromname`
  of the kind mu4e provides. `sf/org-capture-mail-sender` pulls the display name
  out of `:from` instead.

## Why it is shaped this way

A flag carries no date, no priority and no note on why it was flagged, so a
flagged pile is only readable by re-reading all of it — which is itself a task
you have to schedule, and so never happens. Forcing one keystroke of "by when"
at capture is the smallest change that turns the pile into an agenda.
