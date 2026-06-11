# Email: isync with XOAUTH2

How mbsync authenticates to Office365 (the `work` account) and what to do
when it breaks. Gmail accounts use app passwords from the keychain and are
unaffected by any of this.

## Moving parts

- **isync** — built from HEAD with SASL support via the personal tap:
  `brew install --HEAD sbfnk/formulae/isync`. The homebrew-core formula
  lacks the SASL options needed for XOAUTH2.
- **cyrus-sasl-xoauth2** — SASL plugin providing the XOAUTH2 mechanism:
  `brew install sbfnk/formulae/cyrus-sasl-xoauth2`. After installing, the
  plugin must be copied into the cyrus-sasl keg (see below) — libsasl2 only
  searches its own keg's plugin directory.
- **m365auth** (`pipx install m365auth`) — supplies `~/.local/bin/refresh-token`,
  which `~/.mbsyncrc` uses as `PassCmd` for the work account to obtain an
  OAuth access token.

`install.sh --full` installs all three and copies the plugin into place.

## The fragile bit

The xoauth2 plugin lives in the cyrus-sasl-xoauth2 keg, but libsasl2 only
loads plugins from `$(brew --prefix cyrus-sasl)/lib/sasl2/`. The copy into
that directory is destroyed whenever the cyrus-sasl keg is rebuilt or
removed (`brew upgrade`, `brew reinstall`, `brew autoremove`). Restore it
with:

```bash
cp "$(brew --prefix cyrus-sasl-xoauth2)"/lib/sasl2/libxoauth2.* \
   "$(brew --prefix cyrus-sasl)"/lib/sasl2/
```

## Failure modes

- `dyld: Library not loaded: .../cyrus-sasl/lib/libsasl2.3.dylib` and mbsync
  aborts — cyrus-sasl was removed entirely (e.g. by `brew autoremove`, which
  doesn't know the HEAD-built isync links against it). Fix:
  `brew install cyrus-sasl`, then re-copy the plugin as above.
- `IMAP error: selected SASL mechanism(s) not available; selected: XOAUTH2`
  — the plugin copy is missing from the cyrus-sasl keg. Re-copy as above.
- Token errors from the work account — run `~/.local/bin/refresh-token`
  manually to see the m365auth error; re-authenticate if the refresh token
  has expired.

## References

- https://github.com/moriyoshi/cyrus-sasl-xoauth2 (plugin upstream; see
  issue #9 for the plugin-directory discussion)
- Tap formulae: https://github.com/sbfnk/homebrew-formulae
