---
argument-hint: [PR-number] [--post] [--since <sha>]
description: Review a PR or the working diff against the repository's own review specification, reporting only findings worth acting on.
---

Review a change in this repository and report what is worth acting on.

Find the review specification and follow it, in this order:

1. `.github/REVIEW.md`
2. `AGENTS.md` or `CLAUDE.md`, which may name one
3. `.claude/commands/review.md`, if the repo happens to ship one

That file is the repository's own standard: what counts as a finding, what to
look for in this codebase, and what to stay quiet about. Follow it rather than a
general review checklist, so the review matches what a maintainer there would
raise. Pass `$ARGUMENTS` through to it — a PR number, `--since <sha>` to
re-review only the recent commits, `--post` to leave inline comments.

**If the repository has no review specification**, say so and stop rather than
improvising one. Offer to write it: an agreed bar for what counts as a finding is
what keeps a review from turning into a list of things that are merely true.

This is one pass, and it changes nothing. To review, fix, and re-review until an
independent pass comes back clean, use `/review-loop` instead.
