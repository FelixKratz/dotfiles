# Alfred Mail Sync

Sync one, several or all mail accounts from Alfred. The sketchybar mail item
shows a spinner with the account names while mbsync runs.

## Usage

Type `mail`, then narrow by account name, address or notmuch search key:

```
mail            all accounts, plus one entry per account
mail work       a single account
mail w          the same, by search key
mail gmail      every account on that host
mail work pub   both accounts in one sync
```

Naming several accounts offers a combined entry at the top, so `both` is just
two words.

## How it works

`mail_filter.py` reads `~/.config/email/accounts.yaml` through `yq` (so the
workflow needs no third-party Python modules) and skips `smtp_only` accounts.
The action runs `~/.local/bin/getmail.sh <account>...` in the background,
logging to `~/.log/getmail.log`.

## Install

The packaged workflow is a build artefact (`*.alfredworkflow` is gitignored),
so zip the folder and open it:

```bash
cd config/alfred/workflows/mail-sync
zip -r ../mail-sync.alfredworkflow info.plist mail_filter.py README.md
open ../mail-sync.alfredworkflow
```

## Dependencies

- Python 3 (stdlib only)
- `yq`, `mbsync`, `notmuch` (installed by the Brewfile)
- Alfred 5 with Powerpack
