---
name: readable-code
description: Readable, maintainable code standards for R, Julia, Stan, and statistical or scientific computing. Use when writing, editing, reviewing, or discussing code in these languages or domains.
---

# Readable scientific code

## Shared principles

- Match mathematical notation in the source model. Document a concise symbol
  glossary where it is needed; spell out non-mathematical names.
- Keep functions cohesive. Do not split a coherent derivation merely to meet an
  arbitrary size limit.
- Validate inputs early, handle missing values explicitly, and avoid hidden side
  effects.
- Separate model or estimation logic from I/O and plotting where practical.
- Name constants and cite sources for domain constants.
- Preserve reproducibility with explicit seeds and a pinned environment.
- Prioritise numerical stability: use log-scale probability calculations,
  `log1p`/`expm1`, and stable log-sum-exp forms where appropriate.
- Check callers, imports, tests, and public interfaces before changing code.

## R

- Use `snake_case`; avoid dots in new names.
- Handle `NA` deliberately. Prefer clear vectorised operations, `vapply`, or
  `purrr` over opaque `apply` chains; pre-allocate loops when needed.
- Use `renv`, `testthat`, and current `roxygen2` documentation for packages.

## Julia

- Use idiomatic lowercase names, `UpperCamelCase` types, `const` globals, and
  `!` suffixes for mutation. Unicode mathematical names are appropriate.
- Prefer multiple dispatch and type-stable functions. Explicit loops,
  pre-allocation, and broadcasting are idiomatic when they clarify the work.
- Use `Project.toml`/`Manifest.toml`, `Test`, and `BenchmarkTools`.

## Stan

- Place calculations in the appropriate Stan block and constrain parameters to
  their support.
- Vectorise sampling statements where it remains clear. Work on the log scale
  and use stable Stan math functions.
- Use generated quantities for posterior predictions and pointwise log
  likelihoods; document priors and reparameterisation choices.

## Completion check

Confirm that the requested behaviour, dependants, tests, documentation,
reproducibility, and numerical assumptions remain consistent. Avoid unrelated
refactoring.

