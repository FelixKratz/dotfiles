#!/usr/bin/env python3
"""Tests for bin/claude-rate-limit-analyze.

Each test builds a synthetic session JSONL, runs the analyser with a
fixed --now, and asserts the verdict. Run directly:

    python3 tests/test-claude-rate-limit-analyze.py
"""

import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ANALYZER = os.path.join(HERE, "..", "bin", "claude-rate-limit-analyze")

# 2026-05-30T22:27:37Z in epoch seconds (the error timestamp used in
# fixtures). 2026-05-31 02:50 Europe/London (BST, +01:00) == reset.
ERR_TS = "2026-05-30T22:27:37.000Z"
ERR_EPOCH = 1780180057
RESET_0250_EPOCH = 1780192200  # 2026-05-31 02:50:00 +01:00


def user(text, ts="2026-05-30T22:00:00.000Z"):
    return {
        "type": "user",
        "timestamp": ts,
        "message": {"role": "user", "content": text},
    }


def assistant(text, ts="2026-05-30T22:01:00.000Z"):
    return {
        "type": "assistant",
        "timestamp": ts,
        "message": {
            "role": "assistant",
            "content": [{"type": "text", "text": text}],
        },
    }


def limit_error(text, ts=ERR_TS, status=429):
    return {
        "type": "assistant",
        "timestamp": ts,
        "isApiErrorMessage": True,
        "apiErrorStatus": status,
        "message": {
            "role": "assistant",
            "content": [{"type": "text", "text": text}],
        },
    }


def run(entries, now_epoch):
    fd, path = tempfile.mkstemp(suffix=".jsonl")
    try:
        with os.fdopen(fd, "w") as fh:
            for e in entries:
                fh.write(json.dumps(e) + "\n")
        out = subprocess.run(
            [sys.executable, ANALYZER, path, "--now", str(now_epoch)],
            capture_output=True, text=True, check=True,
        )
        return json.loads(out.stdout)
    finally:
        os.unlink(path)


CASES = []


def case(fn):
    CASES.append(fn)
    return fn


@case
def test_session_limit_still_in_future():
    v = run(
        [user("do a thing"),
         limit_error("You've hit your session limit · resets "
                     "2:50am (Europe/London)")],
        now_epoch=ERR_EPOCH + 60,  # 1 min after error, well before reset
    )
    assert v["stuck"] is True, v
    assert v["limit_type"] == "session", v
    assert v["reset_epoch"] == RESET_0250_EPOCH, v


@case
def test_session_limit_reset_passed():
    v = run(
        [user("do a thing"),
         limit_error("You've hit your session limit · resets "
                     "2:50am (Europe/London)")],
        now_epoch=RESET_0250_EPOCH + 5,
    )
    assert v["stuck"] is True, v
    assert v["reset_epoch"] <= RESET_0250_EPOCH + 5, v


@case
def test_resumed_after_error_is_not_stuck():
    v = run(
        [user("do a thing"),
         limit_error("You've hit your session limit · resets "
                     "2:50am (Europe/London)"),
         user("continue", ts="2026-05-31T03:00:00.000Z"),
         assistant("back to work", ts="2026-05-31T03:00:05.000Z")],
        now_epoch=RESET_0250_EPOCH + 1000,
    )
    assert v["stuck"] is False, v


@case
def test_server_throttle_is_not_a_usage_limit():
    v = run(
        [user("do a thing"),
         limit_error("API Error: Server is temporarily limiting "
                     "requests (not your usage limit) · Rate "
                     "limited")],
        now_epoch=ERR_EPOCH + 60,
    )
    assert v["stuck"] is False, v


@case
def test_overloaded_529_is_not_a_usage_limit():
    v = run(
        [user("do a thing"),
         limit_error("API Error: 529 Overloaded. This is a "
                     "server-side issue.", status=None)],
        now_epoch=ERR_EPOCH + 60,
    )
    assert v["stuck"] is False, v


@case
def test_usage_policy_refusal_is_not_a_usage_limit():
    v = run(
        [user("do a thing"),
         limit_error("API Error: Claude Code is unable to respond to "
                     "this request, which appears to violate our "
                     "Usage Policy")],
        now_epoch=ERR_EPOCH + 60,
    )
    assert v["stuck"] is False, v


@case
def test_out_of_extra_usage_with_other_timezone():
    # America/New_York; 10:50am EDT (-04:00) on 2026-05-31.
    v = run(
        [user("do a thing"),
         limit_error("You're out of extra usage · resets "
                     "10:50am (America/New_York)")],
        now_epoch=ERR_EPOCH + 60,
    )
    assert v["stuck"] is True, v
    assert v["limit_type"] == "extra_usage", v
    # 2026-05-31 10:50 America/New_York == 14:50Z
    assert v["reset_epoch"] == 1780239000, v


@case
def test_weekly_limit_detected():
    v = run(
        [user("do a thing"),
         limit_error("You've hit your weekly limit · resets "
                     "8am (Europe/London)")],
        now_epoch=ERR_EPOCH + 60,
    )
    assert v["stuck"] is True, v
    assert v["limit_type"] == "weekly", v
    assert v["reset_epoch"] is not None, v


@case
def test_monthly_limit_has_no_reset_epoch():
    v = run(
        [user("do a thing"),
         limit_error("You've hit your org's monthly usage limit")],
        now_epoch=ERR_EPOCH + 60,
    )
    assert v["stuck"] is True, v
    assert v["limit_type"] == "monthly", v
    assert v["reset_epoch"] is None, v


@case
def test_monthly_spend_limit_has_no_reset_epoch():
    # Verbatim from a local transcript (Claude Code 2.1.220).
    v = run(
        [user("do a thing"),
         limit_error("You've hit your monthly spend limit · raise it at "
                     "claude.ai/settings/usage?from=cc_cli_limit_message")],
        now_epoch=ERR_EPOCH + 60,
    )
    assert v["stuck"] is True, v
    assert v["limit_type"] == "monthly", v
    assert v["reset_epoch"] is None, v


@case
def test_clean_session_is_not_stuck():
    v = run(
        [user("do a thing"),
         assistant("done")],
        now_epoch=ERR_EPOCH + 60,
    )
    assert v["stuck"] is False, v


@case
def test_latest_error_wins_after_retries():
    # Several retry errors; reset clock changes on the last one.
    v = run(
        [user("do a thing"),
         limit_error("You've hit your session limit · resets "
                     "2am (Europe/London)"),
         limit_error("You've hit your session limit · resets "
                     "2:50am (Europe/London)")],
        now_epoch=ERR_EPOCH + 60,
    )
    assert v["stuck"] is True, v
    assert v["reset_epoch"] == RESET_0250_EPOCH, v


def main():
    failed = 0
    for fn in CASES:
        try:
            fn()
            print(f"ok   {fn.__name__}")
        except AssertionError as exc:
            failed += 1
            print(f"FAIL {fn.__name__}: {exc}")
        except Exception as exc:  # noqa: BLE001
            failed += 1
            print(f"ERR  {fn.__name__}: {exc!r}")
    print(f"\n{len(CASES) - failed}/{len(CASES)} passed")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
