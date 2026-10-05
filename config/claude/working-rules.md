# Working rules

Rules for all work on sbfnk's repositories, in interactive sessions and by
sbfnk-bot alike. Interactive sessions load this file from the global
CLAUDE.md; the bot has it in every prompt.

## Language

- British English for all written content: documentation, commits,
  comments, issues, pull requests.
- Common differences: "modelling" not "modeling", "summarise" not
  "summarize", "behaviour" not "behavior".

## Writing

- The humanizer skill holds the writing rules. Follow them in everything you
  write, chat included, and run the humanizer on anything published (issues,
  pull request text, documentation, vignettes, README and NEWS entries,
  roxygen, docstrings, comments) before it is final.

## Issues

- Two paragraphs: what is wrong or missing, and what should happen instead
  or why it matters.
- Add a minimal reproducible example whenever there is something to
  reproduce: the least code that shows the problem, with its output.

## Commits

- Authored by sbfnk-bot, with the trailer
  `Co-authored-by: sbfnk <sebastian.funk@lshtm.ac.uk>`.
- Never mention Claude, Anthropic or any other AI model or tool anywhere in
  the work: no co-author trailer for one, no "Generated with ..." line, no
  reference in commit messages, pull requests, issues, comments or code.
- One short line, in British English. Never reference issue numbers in
  commit messages.
- Never rebase a branch that has an open pull request: merge main in
  instead.
- No introduce-then-revert pairs: a just-committed change that is revised
  is amended or squashed while the branch has no open pull request.

## Code comments

- Comments explain why the code does something, not the history of how it
  came to be.
- No comments reflecting earlier iterations or the conversation.

## Testing

- Run the tests for the code you changed: the test files that cover it, and
  any you added. Leave the full suite and the version and OS matrix to CI,
  which runs them on every push anyway.
- Write a test that fails before the fix where the change is a bug fix.
- When CI fails, read the failing job's log first, and fix the cause; do
  not rerun the whole suite locally to find it.

## Pull requests

- The description is at most two paragraphs, through the humanizer like
  all published prose.
- Link the issue in the description ("This PR closes #N"), never in commits.
- Follow the repository's PR and issue templates where they exist. No
  "Test plan" section.
- A pull request opens as a draft, with no reviewer. It stays a draft until
  a full review pass comes back clean and CI is green; then it is marked
  ready and sbfnk is asked to review. In interactive sessions,
  /wait-for-review does this.
- Never merge a pull request.
