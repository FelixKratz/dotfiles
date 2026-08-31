# r-lsp

R language server for Claude Code, backed by the `languageserver` package.

## Supported extensions
`.R`, `.r`, `.Rmd`, `.qmd`

## Requirements

```r
install.packages("languageserver")
```

Resolution is function-level. S4 and R6 method dispatch is not tracked, so
`findReferences` on a generic returns the generic rather than its methods.
