# Personal Codex guidance

Apply these defaults in every project unless a closer `AGENTS.md`, explicit user
request, or platform policy overrides them.

## Work independently and safely

- Complete routine local work autonomously: inspect code, edit files, run focused
  tests, and make ordinary implementation decisions without asking permission.
- Keep destructive operations narrowly scoped and verified. Never delete or
  modify home-directory or system files while working on a project.
- Treat remote actions as explicit: do not push, publish, post comments, create
  or merge pull requests, or otherwise change online state unless the current
  request specifically asks for it.
- Do not search for credentials or tokens. Stop and report an authentication
  problem when one appears.
- Do not install system packages without an explicit request. Project-local
  dependencies are acceptable when they are needed to complete the task.

## Language and prose

- Use British English in prose, documentation, comments, and commit messages.
- State positive conclusions directly. Use contrasts only when both options are
  meaningful to a reader outside the current conversation.
- Describe what non-human subjects do by their inherent function: code computes,
  a workflow enables, and evidence supports.
- Make comments explain intent, constraints, or non-obvious decisions. Do not
  record conversational history or obvious mechanics in comments.

## Git and pull requests

- Use short, single-line commit messages. Do not add AI attribution or issue
  numbers to commits.
- Do not rebase an open pull-request branch. Merge the current main branch when
  it needs updating. Rebase local, unshared branches only when it improves the
  history.
- When asked to create a pull request, create it as a draft, request review from
  `sbfnk`, follow repository templates, and link relevant issues in the PR body.
- Do not force-push, delete an unmerged branch, or merge a pull request unless
  explicitly requested.

## Scientific and research work

- Preserve reproducibility: surface seeds for stochastic work, use the project's
  environment manager, and make numerical assumptions explicit.
- Prefer clear, idiomatic R, Julia, and Stan. Apply the `readable-code` skill to
  statistical or scientific code.
- For `~/org-roam/*.org`, read
  `~/code/dotfiles/docs/org-roam-llm-instructions.md` first. Preserve untagged
  material and top-level human-owned headings; place AI content one level lower
  and tag it `:ai:`.

## Unattended work

- Work only inside the active project.
- Do not use SSH, submit HPC jobs, push, force-push, or delete branches.
- When a destructive action is unclear, stop and explain what needs deciding.
