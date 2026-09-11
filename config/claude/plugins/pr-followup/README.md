# pr-followup

A PostToolUse hook: when a Bash call runs `gh pr create` and prints the new
pull request's URL, Claude is told to invoke `/wait-for-review` on it.

Claude Code sessions here run gh as sbfnk-bot, so this covers the pull
requests sbfnk-bot opens from a session. `sbfnk-bot-issues` opens its draft
pull requests from the script, outside Claude, so this does not fire for
those.

## Enable

```sh
claude plugin install pr-followup@dotfiles-lsp
```
