# julia-lsp

Julia language server for Claude Code, backed by LanguageServer.jl.

## Supported extensions
`.jl`

## Requirements

Install into the default environment, which is what `--project=@v#.#` selects:

```julia
julia -e 'using Pkg; Pkg.activate(); Pkg.add("LanguageServer")'
```

The first query against a package indexes its dependencies and can take a
minute or more; later queries are served from the symbol cache in
`~/.julia/scratchspaces`.
