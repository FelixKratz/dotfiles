---
name: readable-code
description: Readable, maintainable code standards for R, Julia, Stan and statistical/scientific computing. Use when writing, editing, reviewing, or discussing such code.
---

# Readable code for statistical & scientific computing

> **Names are the primary interface for understanding code — but in statistical code, the maths is part of that interface.**

This adapts general readable-code standards to R, Julia and Stan. Where a rule
from general software engineering fights statistical idiom, the statistical
idiom wins, and the divergence is noted explicitly.

## Naming

- **Reveal intent.** A name should answer *why* it exists and *how* it is used.
- **Match the mathematics.** When code implements a model or derivation,
  variables should mirror the notation in the paper/derivation, including
  single letters and Greek names: `S`, `I`, `R`, `beta`, `gamma`, `R0`, `Rt`,
  `mu`, `sigma`, `theta`, `n`, `x`, `y`. Expanding `beta` to
  `transmission_rate` when the surrounding maths uses β *reduces* readability by
  breaking the link to the source. Document the symbol→meaning mapping once (a
  parameter glossary or roxygen `@param` block), then use the notation.
- **Spell out non-mathematical names.** Outside the maths, avoid abbreviations
  and leetcode shortcuts: `current_node` not `curr`, `previous_value` not
  `prev`, `result` not `res`, `index` not `idx`. `tmp` is acceptable only for a
  genuinely throwaway intermediate.
- **Language conventions:**
  - **R** — `snake_case` for functions and variables (tidyverse style). Avoid
    dots in new names (`.` implies S3 dispatch). Data-frame columns
    `snake_case`. Package-level constants `UPPER_SNAKE_CASE` or `snake_case` by
    convention (R has no true `const`).
  - **Julia** — variables/functions lowercase, `snake_case` for multiword
    readability; types and modules `UpperCamelCase`; `const` names often
    `UPPER_SNAKE_CASE` or `CamelCase`. Mutating functions end with `!`
    (`sort!`, `rand!`). Predicates read as questions (`isvalid`, `has_converged`).
- **Booleans read as questions:** `is_active`, `has_permission`, `should_retry`,
  `converged`.

> **Rule:** If you need a comment to explain a non-mathematical name, rename it.
> If you need a comment to explain a mathematical name, add the glossary, not a longer name.

## Functions

- **One responsibility, one abstraction level.** But do not split a coherent
  mathematical derivation (a likelihood, a Gibbs step, a Stan `model` block)
  just to hit a line count. Cohesion of the maths beats an arbitrary length cap.
- **Arguments:** many named arguments with sensible defaults are *idiomatic* in
  R/Julia statistical APIs (think model-fitting functions with priors, tuning
  and control knobs). Do **not** force these into a struct/list. Bundle into a
  config object only when the arguments genuinely travel together as a unit
  (e.g. a `control` list). Prefer named over positional beyond the first one or
  two arguments.
- **No hidden side effects.** A function named `check_convergence` must not also
  mutate state or write files. In Julia, signal mutation with a trailing `!`.
- **Guard clauses / return early** (`if (!is.numeric(x)) stop(...)`,
  `stopifnot()`, `rlang::abort()`; Julia `@assert`, `throw(ArgumentError(...))`).
- **Vectorise where it is clearer**, but a dense nested `apply`/`Reduce`/
  `purrr` one-liner that has to be reverse-engineered is worse than an explicit
  loop or a `map` over a *named* function. Clarity over cleverness.

## Code structure

- Guard clauses; flat over nested (max ~2 levels of visual nesting).
- Step-down rule: high-level functions first, helpers below.
- **Pipelines** (`|>`, `%>%`): one transformation per line; break long chains;
  name an intermediate when a step needs inspecting or reuse. Don't chain 15
  steps into an undebuggable wall.
- Colocate related code; separate the model/estimation core from I/O and
  plotting so it can be tested and reused.
- **Named constants, not magic numbers** — and for domain constants (a fixed
  incubation period, a reporting delay), name them *and* cite the source in a
  comment.

## Scale, reproducibility & numerics

> **Solve today's analysis with tomorrow's dataset — and a re-run six months from now — in mind.**

- **Reproducibility is non-negotiable.** Set and surface seeds for anything
  stochastic; pin the environment (`renv` for R, `Project.toml`/`Manifest.toml`
  for Julia). Given the same seed and environment, results must be identical.
- **Numerical stability.** Work on the log scale for probabilities and
  likelihoods; use `log1p`/`expm1`, `logsumexp`; guard against `exp` overflow
  and catastrophic cancellation. This is correctness, not optimisation.
- **Data scale.** Code should run on the full dataset, not just a sample. Watch
  memory: avoid copying large objects; reach for `data.table`/`arrow` when R's
  copy semantics bite.
- **Fail loudly, recover cleanly.** Validate inputs and dimensions; handle `NA`
  explicitly rather than letting it propagate or silently drop rows. A silent
  wrong number is the worst outcome in analysis code.
- **Correctness first, then profile, then optimise.** Default to the clear
  implementation. Optimise only against measured evidence (`bench`, `Rprof`,
  `@btime`/`BenchmarkTools`, `@profile`) — never on speculation.

## Comments & didacticism

> **The code is the explanation. Comments are the apology — except for the maths.**

- **Do not state the obvious** (`counter <- counter + 1  # add one`). Delete it.
- **Do not leave commented-out code.** Git remembers.
- **Use brief, imperative clauses:** `# retry on timeout`, not `# this will retry…`.
- **Do document surprises and sources:** why a non-obvious approach was taken,
  the equation/paper a formula comes from (`# eq. 3 of Wallinga & Teunis 2004`),
  and the symbol→meaning glossary for mathematical variables. These are part of
  the interface, not an apology.
- Keep API docs current: roxygen for exported R functions, docstrings for Julia.

## Before editing any file

**Stop and think.**

| Question | Why it matters |
|----------|----------------|
| What uses this? | For a package: reverse dependencies and other exported functions. |
| What does it import? | `DESCRIPTION` Imports / `using`/`import` — interface changes ripple. |
| What tests cover this? | `testthat` / Julia `Test` will fail if behaviour changes. |
| Is it part of the public API? | Changing an exported signature breaks users downstream. |

> **Rule:** Edit the file and all dependents in the same task. Never leave broken
> references, stale roxygen, or an un-`document()`'d NAMESPACE.

## AI coding style

| Situation | Action |
|-----------|--------|
| Feature requested | Write it directly and clearly; fit it to the existing architecture. |
| Bug reported | Fix it; check whether the root cause affects other analyses. Don't over-explain unless asked. |
| No clear requirement | Ask, do not assume — especially about model/statistical intent. |
| Multiple valid approaches | Choose the most readable that respects existing boundaries, not the most impressive. |
| Messy existing code | Boy Scout rule: leave it cleaner; don't refactor unrelated code without permission. |
| Performance vs. readability | Default to readability and numerical correctness; optimise only on profiler evidence. |

## Self-check before completing

- [ ] **Goal met?** Exactly what was asked.
- [ ] **All files edited?** Including dependents, tests, roxygen/docstrings.
- [ ] **Runs / passes tests?** (`devtools::test()`, `Pkg.test()`.)
- [ ] **Naming right?** `snake_case` (R) / Julia conventions; mathematical
      notation matches the source; no `curr`/`prev`/`res`.
- [ ] **Constants named and sourced?** No bare magic numbers; domain values cited.
- [ ] **Reproducible?** Seeds set for stochastic code; environment pinned.
- [ ] **Numerically sound?** Log-scale where needed; no silent overflow or `NA` drop.
- [ ] **Not over-engineered?** No struct-wrapping idiomatic argument lists; no
      trivial one-liner extracted; no abstraction for a hypothetical need.
- [ ] **Readable?** Would a collaborator who knows the model understand it without explanation?

> **Rule:** If any check fails, fix it before completing.
