#!/usr/bin/env python3
"""Generate mbsyncrc, msmtprc and Emacs email-accounts.el from accounts.yaml.

The Emacs output is intentionally small — only the bits that genuinely depend
on accounts.yaml (identities, Fcc dirs, alternative-emails, per-account saved
searches). All other email config lives hand-written in email.el, which loads
this file.
"""

import argparse
import yaml
from pathlib import Path

CONFIG = Path.home() / ".config" / "email" / "accounts.yaml"
MBSYNCRC = Path.home() / ".mbsyncrc"
MSMTPRC = Path.home() / ".msmtprc"
EMACS_ACCOUNTS = Path.home() / ".config" / "doom-private" / "email-accounts.el"

GENERATED_HEADER = "# Auto-generated from accounts.yaml — do not edit directly\n"


def load_config():
    with open(CONFIG) as f:
        config = yaml.safe_load(f)
    for acc in config.get("accounts", []):
        acc.setdefault("sent_folder", "Sent")
        acc.setdefault("drafts_folder", "Drafts")
        acc.setdefault("trash_folder", "Trash")
    return config


def _mail_accounts(config):
    return [a for a in config["accounts"] if not a.get("smtp_only")]


def _default_account(config):
    for acc in config["accounts"]:
        if acc.get("default"):
            return acc
    return config["accounts"][0]


def _inbox_folder(name):
    """Return the on-disk case for the INBOX folder of account `name`.

    macOS is case-insensitive, but notmuch indexes the on-disk name and
    queries it case-sensitively, so we mirror whatever mbsync created.
    """
    maildir = Path.home() / "Maildir" / name
    if maildir.is_dir():
        for entry in maildir.iterdir():
            if entry.is_dir() and entry.name.lower() == "inbox":
                return entry.name
    return "INBOX"


def generate_mbsyncrc(config):
    lines = [GENERATED_HEADER]
    defaults = config.get("defaults", {})
    cert_file = defaults.get("certificate_file", "/opt/homebrew/share/ca-certificates/cacert.pem")
    accounts = _mail_accounts(config)

    for acc in accounts:
        name = acc["name"]
        lines.append(f"MaildirStore local-{name}")
        lines.append(f"Path ~/Maildir/{name}/")
        lines.append(f"Inbox ~/Maildir/{name}/INBOX")
        if acc.get("subfolders_verbatim"):
            lines.append("Subfolders Verbatim")
        lines.append("")

    for acc in accounts:
        name = acc["name"]
        email = acc["email"]
        imap_host = acc["imap_host"]
        imap_user = acc.get("imap_user", email)
        auth = acc.get("auth", defaults.get("auth", "plain"))
        tls_type = acc.get("tls_type", defaults.get("tls_type", "IMAPS"))
        acc_cert = acc.get("certificate_file", cert_file)

        lines.append(f"IMAPStore {name}")
        lines.append(f"Host {imap_host}")
        lines.append(f"User {imap_user}")

        if auth == "xoauth2":
            lines.append("AuthMech XOAUTH2")
            lines.append(f'PassCmd +"{acc["password_cmd"]}"')
        else:
            lines.append("AuthMech PLAIN")
            cmd = (
                "/usr/bin/security -v find-internet-password -w "
                f"-a {email} -s {imap_host} ~/Library/Keychains/login.keychain"
            )
            lines.append(f'PassCmd +"{cmd}"')

        lines.append(f"TLSType {tls_type}")
        if acc_cert:
            lines.append(f"CertificateFile {acc_cert}")
        lines.append("")

    for acc in accounts:
        name = acc["name"]
        folders = acc.get("folders", ["INBOX"])
        patterns = " ".join(f'"{f}"' for f in folders)

        lines.append(f"Channel {name}")
        lines.append(f"Far :{name}:")
        lines.append(f"Near :local-{name}:")
        lines.append(f"Patterns {patterns}")
        lines.append("Create Near")
        lines.append("Sync All")
        lines.append("Expunge Both")
        lines.append("SyncState *")
        if acc.get("copy_arrival_date"):
            lines.append("CopyArrivalDate yes")
        lines.append("")

        for archive in acc.get("archive_channels", []):
            arch_patterns = " ".join(f'"{p}"' for p in archive["patterns"])
            lines.append(f"Channel {archive['name']}")
            lines.append(f"Far :{name}:")
            lines.append(f"Near :local-{name}:")
            lines.append(f"Patterns {arch_patterns}")
            lines.append("Sync All")
            lines.append("Create Both")
            lines.append("Expunge Far")
            lines.append("")

    return "\n".join(lines)


def generate_msmtprc(config):
    lines = [GENERATED_HEADER, "defaults", "tls on", "tls_starttls on",
             "timeout 30", "logfile ~/.log/msmtp.log", ""]
    defaults = config.get("defaults", {})
    default_name = None

    for acc in config["accounts"]:
        smtp_host = acc.get("smtp_host")
        if not smtp_host:
            continue

        name = acc["name"]
        email = acc["email"]
        smtp_user = acc.get("smtp_user", email)
        auth = acc.get("auth", defaults.get("auth", "plain"))
        port = acc.get("msmtp_port", defaults.get("msmtp_port", 587))
        starttls = acc.get("msmtp_tls_starttls",
                           defaults.get("msmtp_tls_starttls", True))

        lines.append(f"account {name}")
        lines.append(f"host {smtp_host}")
        lines.append(f"from {email}")
        lines.append(f"tls_starttls {'on' if starttls else 'off'}")
        lines.append(f"port {port}")

        if auth == "xoauth2":
            lines.append("auth xoauth2")
            lines.append("tls_certcheck on")
            lines.append(f"user {smtp_user}")
            pwd_cmd = acc.get("msmtp_password_cmd", acc.get("password_cmd", ""))
            lines.append(f'passwordeval "{pwd_cmd}"')
        else:
            lines.append("auth on")
            lines.append(f"user {smtp_user}")
            imap_host = acc.get("imap_host", "")
            if imap_host:
                lines.append(
                    f'passwordeval "security find-internet-password'
                    f' -s {imap_host} -a {email} -w"'
                )

        lines.append("")

        if acc.get("default"):
            default_name = name

    if default_name:
        lines.append(f"account default : {default_name}")
        lines.append("")

    return "\n".join(lines)


def _fcc_path(name, sent_folder):
    """Quote Fcc paths that contain spaces or [Gmail]-style brackets."""
    path = f"{name}/{sent_folder}"
    if " " in path or "[" in path:
        return f'\\"{path}\\"'
    return path


def _bookmark_maildir(name, folder):
    """Return `maildir:PATH` for inside an elisp string, escaping inner quotes
    if PATH contains spaces or brackets."""
    path = f"/{name}/{folder}"
    if " " in path or "[" in path:
        return f'maildir:\\"{path}\\"'
    return f'maildir:{path}'


def _elisp_escape(s):
    """Escape backslashes and double quotes for embedding in an elisp string."""
    return s.replace("\\", "\\\\").replace('"', '\\"')


def _mu4e_context_form(acc, default_full_name):
    """Emit a `make-mu4e-context` form for one account.

    Wrapped in a function in email-accounts.el so the form is only evaluated
    once mu4e is loaded (where `make-mu4e-context` is defined).
    """
    name = acc["name"]
    email = acc["email"]
    full_name = _elisp_escape(acc.get("full_name", default_full_name))
    sent = acc["sent_folder"]
    drafts = acc["drafts_folder"]
    trash = acc["trash_folder"]
    return f"""   (make-mu4e-context
    :name "{name}"
    :match-func (lambda (msg)
                  (when msg (string-prefix-p "/{name}" (mu4e-message-field msg :maildir))))
    :vars '((user-mail-address  . "{email}")
            (user-full-name     . "{full_name}")
            (mu4e-sent-folder   . "/{name}/{sent}")
            (mu4e-drafts-folder . "/{name}/{drafts}")
            (mu4e-trash-folder  . "/{name}/{trash}")))"""


def _mu4e_bookmark_lines(acc):
    """Two bookmarks per account: today's mail (lowercase key) and all (uppercase)."""
    name = acc["name"]
    label = name[0].upper() + name[1:]
    key = acc.get("search_key", name[0])
    inbox = _inbox_folder(name)
    sent = acc["sent_folder"]
    inbox_q = _bookmark_maildir(name, inbox)
    sent_q = _bookmark_maildir(name, sent)
    today_q = f"({inbox_q} OR {sent_q}) AND (date:today..now OR flag:unread)"
    all_q = f"{inbox_q} OR {sent_q}"
    return [
        f'    (:name "{label} email (today)" :query "{today_q}" :key ?{key})',
        f'    (:name "{label} email" :query "{all_q}" :key ?{key.upper()})',
    ]


def generate_email_accounts(config):
    """Emit a small email-accounts.el with only the account-derived bits."""
    default_acc = _default_account(config)
    default_full_name = config.get("defaults", {}).get("name", "User")
    accounts = _mail_accounts(config)
    all_emails = [a["email"] for a in config["accounts"]]

    emails_block = "\n         ".join(f'"{e}"' for e in all_emails)
    identities_block = "\n        ".join(
        f'"{a.get("full_name", default_full_name)} <{a["email"]}>"'
        for a in accounts
    )
    fcc_block = "\n        ".join(
        f'("{a["email"]}" . "{_fcc_path(a["name"], a["sent_folder"])}")'
        for a in accounts
    )
    fallback_fcc = _fcc_path(default_acc["name"], default_acc["sent_folder"])

    contexts_block = "\n".join(
        _mu4e_context_form(a, default_full_name) for a in accounts
    )
    bookmark_lines = []
    for acc in accounts:
        bookmark_lines.extend(_mu4e_bookmark_lines(acc))
    bookmarks_block = "\n".join(bookmark_lines)
    trash_block = "\n    ".join(
        f'("{a["name"]}" . "{_elisp_escape(a["trash_folder"])}")'
        for a in accounts
    )

    search_lines = []
    for acc in accounts:
        name = acc["name"]
        key = acc.get("search_key", name[0])
        inbox = _inbox_folder(name)
        query = f"folder:{name}/{inbox}"
        search_lines.append(
            f'        (:name "{name}" :query "{query}" '
            f':count-query "{query} AND tag:unread" :key "{key}" '
            f':search-type unthreaded)'
        )
    searches_block = "\n".join(search_lines)

    return f""";;; email-accounts.el --- Auto-generated from accounts.yaml -*- lexical-binding: t; -*-
;;; Commentary:
;; Auto-generated by generate.py — do not edit directly.
;; Edit accounts.yaml and re-run generate.py.
;;; Code:

(setq user-full-name "{default_full_name}"
      user-mail-address "{default_acc["email"]}")

(setq message-alternative-emails
      (regexp-opt
       '({emails_block})))

;; Notmuch identities — one per account
(setq notmuch-identities
      '({identities_block}))

;; Fcc dirs — where each identity saves sent mail
(setq notmuch-fcc-dirs
      '({fcc_block}
        (".*" . "{fallback_fcc}")))

;; Trash folder per account — used by sf/notmuch-move-to-trash in email.el
(defvar sf/notmuch-trash-folders
  '({trash_block})
  "Trash folder name per account, generated from accounts.yaml.")

;; mu4e contexts — wrapped in a defun so `make-mu4e-context` is only called
;; after mu4e has been loaded.
(defun sf/mu4e-account-contexts ()
  "Return mu4e contexts for the accounts in accounts.yaml."
  (list
{contexts_block}))

;; mu4e bookmarks — two per account (today + all)
(defvar sf/mu4e-account-bookmarks
  '(
{bookmarks_block})
  "Per-account mu4e bookmarks, generated from accounts.yaml.")

;; Per-account inbox saved searches — merged into notmuch-saved-searches in email.el
(defvar sf/notmuch-account-saved-searches
      '(
{searches_block})
      "Per-account inbox saved searches, generated from accounts.yaml.")

(provide 'email-accounts)
;;; email-accounts.el ends here
"""


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--mbsync", action="store_true", help="Print mbsyncrc to stdout")
    parser.add_argument("--msmtp", action="store_true", help="Print msmtprc to stdout")
    parser.add_argument("--emacs", action="store_true", help="Print email-accounts.el to stdout")
    parser.add_argument("--write", action="store_true",
                        help="Write outputs in place (default writes to .generated files for review)")
    args = parser.parse_args()

    config = load_config()

    if args.mbsync:
        print(generate_mbsyncrc(config)); return
    if args.msmtp:
        print(generate_msmtprc(config)); return
    if args.emacs:
        print(generate_email_accounts(config)); return

    outputs = {
        MBSYNCRC: generate_mbsyncrc(config),
        MSMTPRC: generate_msmtprc(config),
        EMACS_ACCOUNTS: generate_email_accounts(config),
    }

    for path, content in outputs.items():
        target = path if args.write else path.with_suffix(path.suffix + ".generated")
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content)
        print(f"{'Wrote' if args.write else 'Generated'} {target}")

    if not args.write:
        print("\nReview the .generated files, then re-run with --write to install in place.")


if __name__ == "__main__":
    main()
