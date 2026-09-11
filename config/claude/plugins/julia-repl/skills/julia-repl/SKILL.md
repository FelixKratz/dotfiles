---
name: julia-repl
description: Evaluate Julia through the warm AgentREPL MCP session rather than `julia -e`, hot-reload edits with Revise, and filter TestItemRunner suites while iterating. Use for any Julia evaluation, package iteration, or test run, and to decide when a fresh process is needed instead.
---

# Julia REPL over MCP

The `mcp__plugin_julia-repl_julia-repl__*` tools drive a Julia process that stays
alive for the whole session, so startup and compilation cost is paid once rather
than on every `julia -e`.
The server only starts when the session opens inside a Julia project, found as the
nearest `Project.toml` from the session directory up to the git root.
Elsewhere the server connects with no tools; start the session from the project
directory to get it.

## Invoking it

| Tool | Use |
|---|---|
| `eval` | run code (`code`) |
| `revise` | reload edited files (`action="revise"`) |
| `info` | Julia version, active project, worker pid, user variables |
| `activate` | switch project (`path`), then `pkg` `action="instantiate"` |
| `pkg` | `add`, `rm`, `status`, `update`, `test`, `develop` |
| `session` | isolated named sessions (`action`, `name`) |
| `reset` | kill the worker and spawn a clean one |

The server activates the project it found, so in a package repo the package is
already the active project.
`log_viewer` opens a terminal window, so ask before calling it.

## Hot or cold

Iterate hot, verify cold.

Reach for a fresh process, either `reset` or plain `julia --project=.` in Bash,
when:

- verifying anything before a commit, so no result rests on session state
- measuring startup, TTFX, or precompilation
- a reload leaves behaviour that no longer makes sense

Everything else belongs in the warm session.

## Revise

Call `revise` with `action="revise"` after editing a `.jl` file, then re-eval.
Method changes reload.
Struct and const changes reload only on Julia 1.12 with Revise's `revise_structs`
preference on (the default from Revise 3.17); otherwise `reset` after changing a
struct.
`reset` is also the fix when a reload leaves the session inconsistent.
A script outside a package needs `revise` with `action="includet"` once.

## Tests

Narrow the filter while iterating, then run the full suite in a fresh process
before finishing.

```julia
@run_package_tests filter = ti -> contains(ti.filename, "growth")
@run_package_tests filter = ti -> ti.name == "growth rate stays positive"
@run_package_tests filter = ti -> :integration in ti.tags
```

`pkg` with `action="test"` is the cold run, since `Pkg.test` starts its own
process.

## One worker per session

Each Claude Code session starts its own server and its own worker, so sessions
never share state.
Each costs about 1 GB resident before any package loads, so drop named sessions
you no longer need with `session` `action="destroy"`.
