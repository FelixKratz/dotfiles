Review a change in this repository and report what is worth acting on.

Find the review specification and follow it, in this order:

1. `.github/REVIEW.md`
2. `.claude/commands/review.md` — if it only points somewhere else, follow the
   pointer
3. `AGENTS.md` or `CLAUDE.md`, which may name one

That file is the repository's own standard: what counts as a finding, what to
look for in this codebase, and what to stay quiet about. Follow it rather than a
general review checklist, so the review matches what a maintainer here would
raise. Pass through whatever arguments were given — a PR number, `--since <sha>`
for a re-review of just the recent commits, `--post` to leave inline comments.

**If the repository has no review specification**, say so and stop rather than
improvising one. Offer to write it: an agreed bar for what counts as a finding
is what keeps a review from turning into a list of things that are merely true.
