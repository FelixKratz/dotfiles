# Email: isync with XOAUTH2

How mbsync authenticates to Office365 (the `work` account) and what to do
when it breaks. Gmail accounts use app passwords from the keychain and are
unaffected by any of this.

## Moving parts

- **isync** — built from HEAD with SASL support via the personal tap:
  `brew install --HEAD sbfnk/formulae/isync`. The homebrew-core formula
  lacks the SASL options needed for XOAUTH2.
- **cyrus-sasl-xoauth2** — SASL plugin providing the XOAUTH2 mechanism:
  `brew install sbfnk/formulae/cyrus-sasl-xoauth2`;
  `getmail.sh` points libsasl2 at it (see below).
- **m365auth** (`pipx install m365auth`) — supplies `~/.local/bin/refresh-token`,
  which `~/.mbsyncrc` uses as `PassCmd` for the work account to obtain an
  OAuth access token.

`install.sh --full` installs all three.

## The plugin directory

The xoauth2 plugin lives in the cyrus-sasl-xoauth2 keg, but libsasl2 only
loads plugins from `$(brew --prefix cyrus-sasl)/lib/sasl2/` by default. A
copy placed there is wiped whenever the cyrus-sasl keg is rebuilt
(`brew upgrade`, `brew reinstall`), so `getmail.sh` sets `SASL_PATH` to both
keg directories instead. Run mbsync by hand through `getmail.sh work`, or
with the same `SASL_PATH`, or it fails as below.

## Failure modes

A sync that keeps failing for 30 minutes raises a `mail-<account>` nudge
(macOS notification, tmux bar, shell greeting), which clears on the next
good sync.

- `dyld: Library not loaded: .../cyrus-sasl/lib/libsasl2.3.dylib` and mbsync
  aborts — cyrus-sasl was removed entirely (e.g. by `brew autoremove`, which
  doesn't know the HEAD-built isync links against it). Fix:
  `brew install cyrus-sasl`.
- `IMAP error: selected SASL mechanism(s) not available; selected: XOAUTH2`
  — libsasl2 cannot find the plugin: mbsync ran without the `SASL_PATH`
  from `getmail.sh`, or the cyrus-sasl-xoauth2 keg is missing
  (`brew install sbfnk/formulae/cyrus-sasl-xoauth2`).
- Token errors from the work account — run `~/.local/bin/refresh-token`
  manually to see the m365auth error; re-authenticate if the refresh token
  has expired.

## References

- https://github.com/moriyoshi/cyrus-sasl-xoauth2 (plugin upstream; see
  issue #9 for the plugin-directory discussion)
- Tap formulae: https://github.com/sbfnk/homebrew-formulae
