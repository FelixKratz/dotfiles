# julia-repl

A warm Julia session for Claude Code over MCP, backed by
[AgentREPL.jl](https://github.com/samtalki/AgentREPL.jl), with a skill on when to
use it and when to start a fresh process.

The server only starts Julia when the session opens inside a Julia project: the
nearest `Project.toml` or `JuliaProject.toml` from the session directory up to
the git root.
Everywhere else `bin/mcp-stub.py` answers the MCP handshake with no tools, so no
Julia process runs in sessions that never need one.

## Requirements

AgentREPL is unregistered, so develop it from GitHub into its own shared
environment, which the server selects with `--project=@AgentREPL`:

```julia
julia -e 'using Pkg; Pkg.activate("AgentREPL"; shared = true);
  Pkg.develop(url = "https://github.com/samtalki/AgentREPL.jl");
  Pkg.instantiate(); Pkg.precompile()'
```

The worker loads Revise from the default environment when it is there.

## Enable

```sh
claude plugin install julia-repl@dotfiles-lsp
```

Installed plugins are copied into `~/.claude/plugins/cache`, so bump the version
in the marketplace entry and run `claude plugin update julia-repl@dotfiles-lsp`
after changing anything here.
