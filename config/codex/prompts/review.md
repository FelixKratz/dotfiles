Review a change in this repository and report what is worth acting on.

Find the review specification, which comes in two halves:

- **The org half** (the method — scoping, the finding bar, reporting, trust).
  Infer the owner (`gh repo view --json owner -q .owner.login`) and fetch that
  org's `.github` repository `REVIEW.md`:
  `gh api repos/<owner>/.github/contents/REVIEW.md -H "Accept: application/vnd.github.raw"`.
- **The repo half** (optional — the non-obvious traps specific to this codebase):
  `.github/REVIEW.md`, or a file named by `AGENTS.md` / `CLAUDE.md`. Most repos
  have none, which is fine: generic language knowledge and stated conventions
  belong to a competent reviewer and to the repo's own `CLAUDE.md`.

Follow whichever halves exist, plus the repo's `CLAUDE.md` for its conventions.

Pass through whatever arguments were given — a PR number, `--since <sha>` for a
re-review of just the recent commits, `--post` to leave inline comments.

**If neither half exists**, say so and stop rather than improvising a checklist.
Offer to write the org half: an agreed bar for what counts as a finding is what
keeps a review from turning into a list of things that are merely true.
