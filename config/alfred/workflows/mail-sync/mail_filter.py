#!/usr/bin/env python3
"""Alfred script filter: pick mail accounts to sync with getmail.sh.

Accounts come from ~/.config/email/accounts.yaml, read through yq so the
workflow needs no third-party Python modules. Typing several words offers a
combined sync, so `mail work public` syncs both in one go.
"""

import json
import os
import subprocess
import sys

ACCOUNTS_YAML = os.path.expanduser("~/.config/email/accounts.yaml")
YQ = "/opt/homebrew/bin/yq"
FILTER = (
    '[.accounts[] | select(.smtp_only != true) '
    '| {name: .name, email: .email, key: (.search_key // "")}]'
)


def accounts():
    try:
        out = subprocess.run(
            [YQ, "-c", FILTER, ACCOUNTS_YAML],
            capture_output=True, text=True, check=True,
        ).stdout
        return json.loads(out)
    except (OSError, subprocess.CalledProcessError, ValueError):
        return []


def matches(account, token):
    token = token.lower()
    if account["name"].lower().startswith(token) or account["key"] == token:
        return True
    # A single letter is a search key, so keep it from matching stray letters
    # inside an address
    return len(token) > 1 and token in account["email"].lower()


def resolve(accs, token):
    """The single account a token names, or None if it is ambiguous."""
    hits = [a for a in accs if matches(a, token)]
    exact = [a for a in hits if a["name"].lower() == token.lower()]
    if exact:
        return exact[0]
    return hits[0] if len(hits) == 1 else None


def item(title, subtitle, arg, uid=None, valid=True):
    entry = {"title": title, "subtitle": subtitle, "arg": arg, "valid": valid}
    if uid:
        entry["uid"] = uid
    return entry


def main():
    query = " ".join(sys.argv[1:]).strip()
    tokens = query.split()
    accs = accounts()
    items = []

    # Several words, each naming an account: offer them as one sync
    if len(tokens) > 1:
        picked, seen = [], set()
        for token in tokens:
            account = resolve(accs, token)
            if account is None or account["name"] in seen:
                picked = []
                break
            seen.add(account["name"])
            picked.append(account["name"])
        if picked:
            names = " ".join(picked)
            items.append(item(
                "Sync " + " + ".join(picked),
                "%d accounts in parallel" % len(picked),
                names, uid="combo",
            ))

    if not tokens or "all".startswith(tokens[0].lower()):
        items.append(item(
            "Sync all accounts",
            "%d accounts in parallel" % len(accs) if accs else "every account",
            "all", uid="all",
        ))

    token = tokens[-1] if tokens else ""
    for account in accs:
        if not token or matches(account, token):
            key = account["key"]
            items.append(item(
                "Sync %s" % account["name"],
                "%s%s" % (account["email"], "   (key %s)" % key if key else ""),
                account["name"], uid=account["name"],
            ))

    if not items:
        items.append(item(
            "No account matches '%s'" % query,
            "Accounts are read from ~/.config/email/accounts.yaml",
            "", valid=False,
        ))

    json.dump({"items": items}, sys.stdout)


if __name__ == "__main__":
    main()
