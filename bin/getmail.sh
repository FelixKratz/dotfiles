#!/bin/bash
# Sync mail accounts with mbsync, then update both indexes.
#
# Usage:
#   getmail.sh <account>...     sync the named accounts, in parallel
#   getmail.sh --key <k>...     sync by notmuch search_key from accounts.yaml
#   getmail.sh all              sync every account that has IMAP
#
# While a sync runs the account is listed in ~/.cache/mail-sync/, which both
# locks it against a second run and drives the sketchybar spinner.

ACCOUNTS_YAML="$HOME/.config/email/accounts.yaml"
STATE_DIR="$HOME/.cache/mail-sync"
YQ=/opt/homebrew/bin/yq
MBSYNC=/opt/homebrew/bin/mbsync
NOTMUCH=/opt/homebrew/bin/notmuch
SYNC_TIMEOUT=600
SYNC_GRACE=20
NOTMUCH_ERR="$HOME/.log/getmail-notmuch.err"

usage() {
  sed -n '4,8p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-1}"
}

# Account name and search key of every non-smtp-only account. Without the
# private accounts.yaml the arguments are used as mbsync channel names.
NAMES=()
KEYS=()
read_accounts() {
  [[ -x $YQ && -r $ACCOUNTS_YAML ]] || return 1
  local name key
  while IFS=$'\t' read -r name key; do
    [[ -n $name ]] || continue
    NAMES+=("$name")
    KEYS+=("${key:-${name:0:1}}")
  done < <($YQ -r '.accounts[] | select(.smtp_only != true)
                   | [.name, (.search_key // "")] | @tsv' "$ACCOUNTS_YAML")
  [[ ${#NAMES[@]} -gt 0 ]]
}

by_key() {
  local i
  for i in "${!KEYS[@]}"; do
    [[ ${KEYS[$i]} == "$1" ]] && { echo "${NAMES[$i]}"; return 0; }
  done
  return 1
}

known_account() {
  local n
  for n in "${NAMES[@]}"; do [[ $n == "$1" ]] && return 0; done
  return 1
}

# Append to TARGETS unless already there, so `getmail.sh all work` syncs once
TARGETS=()
add_target() {
  local t
  for t in "${TARGETS[@]}"; do [[ $t == "$1" ]] && return; done
  TARGETS+=("$1")
}

have_accounts=false
read_accounts && have_accounts=true

[[ $# -gt 0 ]] || usage
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage 0
      ;;
    -k|--key)
      shift
      name=$(by_key "$1") || { echo "getmail.sh: no account with key '$1'" >&2; exit 1; }
      add_target "$name"
      ;;
    all)
      $have_accounts || { echo "getmail.sh: 'all' needs $ACCOUNTS_YAML" >&2; exit 1; }
      for name in "${NAMES[@]}"; do add_target "$name"; done
      ;;
    -*)
      usage
      ;;
    *)
      if $have_accounts && ! known_account "$1"; then
        echo "getmail.sh: unknown account '$1'" >&2
        exit 1
      fi
      add_target "$1"
      ;;
  esac
  shift
done

bar_update() {
  command -v sketchybar >/dev/null 2>&1 && sketchybar --trigger mail_sync
  return 0
}

# One marker file per running account, holding the pid that claimed it. A
# marker whose process is gone is stale and gets taken over.
mkdir -p "$STATE_DIR"
claim() {
  local marker="$STATE_DIR/$1" owner
  if (set -o noclobber; echo $$ > "$marker") 2>/dev/null; then
    return 0
  fi
  owner=$(cat "$marker" 2>/dev/null)
  if [[ -n $owner ]] && kill -0 "$owner" 2>/dev/null; then
    return 1
  fi
  echo $$ > "$marker"
}

CLAIMED=()
for account in "${TARGETS[@]}"; do
  if claim "$account"; then
    CLAIMED+=("$account")
  else
    echo "[$account] already syncing, skipped"
  fi
done

release_all() {
  local account
  for account in "${CLAIMED[@]}"; do rm -f "$STATE_DIR/$account"; done
  bar_update
}

[[ ${#CLAIMED[@]} -gt 0 ]] || exit 0
trap release_all EXIT INT TERM
bar_update

# mbsync forks a PassCmd helper to fetch each account's password, and the
# helper inherits mbsync's output pipe. The OAuth2 helper blocks on a socket
# read with no timeout, so a connection that drops mid-request leaves it
# hanging: it outlives a killed mbsync, holds the pipe open, and the account
# stays locked for as long as the machine is up. Give mbsync its own process
# group and signal the group, so the helpers go down with it.
run_sync() {
  local account=$1 pid watchdog rc
  set -m
  $MBSYNC "$account" 2>&1 &
  pid=$!
  { sleep "$SYNC_TIMEOUT"
    kill -TERM -"$pid" 2>/dev/null
    sleep "$SYNC_GRACE"
    kill -KILL -"$pid" 2>/dev/null; } >/dev/null 2>&1 &
  watchdog=$!
  set +m
  wait "$pid" 2>/dev/null
  rc=$?
  kill -KILL -"$watchdog" 2>/dev/null
  # A helper that survived a clean exit would hold the pipe open just as well
  kill -KILL -"$pid" 2>/dev/null
  (( rc > 128 )) && echo "timed out after ${SYNC_TIMEOUT}s"
  return $rc
}

for account in "${CLAIMED[@]}"; do
  (
    run_sync "$account" | sed "s/^/[$account] /"
    # Drop the marker as soon as this account is done so the bar shrinks to
    # the accounts still running
    rm -f "$STATE_DIR/$account"
    bar_update
  ) &
done
wait

# Update the notmuch index; Emacs reads the database directly, so there is
# nothing else to tell.
#
# Stderr used to go to /dev/null. That hid a post-new hook which could not find
# notmuch on the launchd PATH, so sent mail stopped being tagged for four days
# with nothing to show for it. Keep stderr, minus the note notmuch prints for
# every mbsync state file it walks past, which runs to thousands of lines a day
# and would bury the one line that matters.
scratch="$(mktemp)"
$NOTMUCH new 2>"$scratch"
if grep -v '^Note: Ignoring non-mail file:' "$scratch" | grep -q '[^[:space:]]'; then
  mkdir -p "$(dirname "$NOTMUCH_ERR")"
  {
    date '+%Y-%m-%d %H:%M:%S notmuch new:'
    grep -v '^Note: Ignoring non-mail file:' "$scratch"
  } >>"$NOTMUCH_ERR"
fi
rm -f "$scratch"
