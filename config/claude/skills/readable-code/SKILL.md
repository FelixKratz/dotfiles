---
name: readable-code
description: Readable, maintainable code standards for R, Julia, Stan and statistical/scientific computing. Use when writing, editing, reviewing, or discussing such code.
---

# Readable code for statistical & scientific computing

> **Names are the primary interface for understanding code — but in statistical code, the maths is part of that interface.**

The **shared principles** below apply to R, Julia and Stan alike. Each language
then has a section for the conventions and idioms that genuinely diverge. When a
general software-engineering rule fights statistical idiom, the idiom wins.

---

# Shared principles

## Naming

- **Reveal intent.** A name should answer *why* it exists and *how* it is used.
- **Match the mathematics.** When code implements a model or derivation,
  variables should mirror the notation in the paper/derivation, including single
  letters and Greek names (`S`, `I`, `R`, `beta`/`β`, `gamma`/`γ`, `R0`, `Rt`,
  `mu`, `sigma`, `theta`). Expanding `beta` to `transmission_rate` when the maths
  uses β *reduces* readability by breaking the link to the source. Document the
  symbol→meaning mapping once (a glossary, `@param`, or a docstring), then use
  the notation.
- **Spell out non-mathematical names.** Outside the maths, avoid abbreviations
  and leetcode shortcuts: `current_node` not `curr`, `previous_value` not `prev`,
  `result` not `res`. `tmp` only for a genuinely throwaway intermediate.
- **Booleans read as questions:** `is_active`, `has_converged`, `should_retry`.
- *(Casing differs by language — see the language sections.)*

> **Rule:** If you need a comment to explain a non-mathematical name, rename it.
> If you need a comment to explain a mathematical name, add the glossary.

## Functions

- **One responsibility, one abstraction level** — but do not split a coherent
  derivation (a likelihood, a Gibbs step, a Stan `model` block) to hit a line
  count. Cohesion of the maths beats an arbitrary cap.
- **Arguments:** many named arguments with sensible defaults are *idiomatic* in
  statistical APIs (priors, tuning, control knobs). Do not force them into a
  struct/list; bundle only when arguments genuinely travel together as a unit.
  Prefer named over positional beyond the first one or two.
- **No hidden side effects.** A function named `check_convergence` must not also
  mutate state or write files.
- **Guard clauses / return early.** Validate up front; fail on bad input.
- **Clarity over cleverness.** A dense one-liner that must be reverse-engineered
  is worse than explicit multi-step logic.

## Code structure

- Guard clauses; flat over nested (~2 levels max); step-down rule (high-level
  first, helpers below).
- **Pipelines** (`|>`, `%>%`): one transformation per line; break long chains;
  name an intermediate when a step needs inspecting or reuse.
- Colocate related code; **separate the model/estimation core from I/O and
  plotting** so it can be tested and reused.
- **Named constants, not magic numbers** — and for domain constants (incubation
  period, reporting delay) name them *and* cite the source in a comment.

## Reproducibility, numerics & scale

> **Solve today's analysis with tomorrow's dataset — and a re-run six months from now — in mind.**

- **Reproducibility is non-negotiable.** Set and surface seeds for anything
  stochastic; pin the environment (tooling per language). Same seed + same
  environment → identical results.
- **Numerical stability.** Work on the log scale for probabilities and
  likelihoods; use `log1p`/`expm1`, `log_sum_exp`; guard against `exp` overflow
  and catastrophic cancellation. This is correctness, not optimisation.
- **Data scale.** Code should run on the full dataset, not just a sample. Watch
  memory and copying.
- **Fail loudly, recover cleanly.** Validate inputs and dimensions; handle
  missing values explicitly (mechanism per language) rather than letting them
  silently propagate or drop rows. A silent wrong number is the worst outcome.
- **Correctness first, then profile, then optimise** — never optimise on
  speculation; only against measured evidence.

## Comments & didacticism

> **The code is the explanation. Comments are the apology — except for the maths.**

- **No obvious comments** (`counter <- counter + 1  # add one`). Delete them.
- **No commented-out code.** Git remembers.
- **Brief, imperative clauses:** `# retry on timeout`, not `# this will retry…`.
- **Do document surprises and sources:** why a non-obvious approach was taken,
  the equation/paper a formula comes from (`# eq. 3 of Wallinga & Teunis 2004`),
  and the symbol glossary for mathematical variables. These are interface, not apology.

## Before editing any file

| Question | Why it matters |
|----------|----------------|
| What uses this? | Reverse dependencies, other exported functions, callers. |
| What does it import? | Interface changes ripple to dependants. |
| What tests cover this? | They will fail if behaviour changes. |
| Is it part of the public API? | Changing an exported signature breaks users downstream. |

> **Rule:** Edit the file and all dependents in the same task. Never leave broken
> references or stale documentation.

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
- [ ] **All files edited?** Including dependents, tests, documentation.
- [ ] **Runs / passes tests?**
- [ ] **Naming right?** Language casing correct; mathematical notation matches the source; no `curr`/`prev`/`res`.
- [ ] **Constants named and sourced?** No bare magic numbers.
- [ ] **Reproducible?** Seeds set for stochastic code; environment pinned.
- [ ] **Numerically sound?** Log-scale where needed; no silent overflow or missing-value drop.
- [ ] **Not over-engineered?** No struct-wrapping idiomatic argument lists; no abstraction for a hypothetical need.
- [ ] **Readable?** Would a collaborator who knows the model understand it without explanation?

> **Rule:** If any check fails, fix it before completing.

---

# R

- **Naming:** `snake_case` for functions and variables (tidyverse). Avoid dots in
  new names (`.` implies S3 dispatch). Data-frame columns `snake_case`. Constants
  `UPPER_SNAKE_CASE` or `snake_case` (R has no true constant).
- **Missing data:** handle `NA` explicitly (`na.rm`, `is.na()`, `tidyr::drop_na`);
  never let it silently propagate or quietly drop rows.
- **Vectorise where it is clearer** than a loop, but avoid dense nested
  `apply`/`Reduce`; prefer `purrr::map`/`vapply` over a *named* function to a
  cryptic anonymous one-liner. Pre-allocate if you must loop.
- **Large data:** `data.table` or `arrow` when base R's copy-on-modify semantics
  bite; avoid needless copies of big objects.
- **Environment:** `renv`. **Tests:** `testthat`. **Docs:** `roxygen2` (keep
  `@param`/`@return` current; re-`document()` after signature changes; mind the
  `NAMESPACE` and reverse dependencies). **Profiling:** `bench`, `profvis`, `Rprof`.

# Julia

- **Naming:** lowercase functions/variables, words **run together** when readable
  (`isempty`, `haskey`); underscores **only** where needed for legibility — Julia
  discourages `snake_case` by default. Types and modules `UpperCamelCase`. Use
  `const` for module-level constants and globals. **Mutating functions end with
  `!`** (`sort!`, `rand!`).
- **Unicode identifiers are idiomatic** for maths: write `β`, `σ`, `μ`, `θ`, `λ`
  directly (type `\beta<tab>` in the REPL/editor). Match the paper's notation —
  this is *more* idiomatic than ASCII `beta`, and scientific packages do it.
- **Multiple dispatch is the core idiom.** Express behaviour as small methods
  specialised on argument types, not as `if`/`else` type-switching or OOP-style
  objects with attached methods. Add methods to existing generic functions.
- **Type stability matters** (correctness *and* speed): functions should return a
  consistent type; avoid untyped, non-`const` globals; use concrete or
  parametric struct fields; check hot paths with `@code_warntype`; use function
  barriers to isolate type-unstable code.
- **Loops are fast and idiomatic** — do **not** carry R's reflex to vectorise
  away from loops. An explicit `for` loop (with `eachindex`, `@views` to avoid
  allocations, pre-allocation + a mutating `foo!`) is often the clearest, fastest
  choice.
- **Broadcasting** for elementwise work: `f.(x)`, fused dotted operators
  (`y .= a .* x .+ b`).
- **`missing` vs `nothing`:** `missing` for statistical missing data (propagates,
  three-valued logic, `skipmissing`); `nothing` for absence/void. Choose
  deliberately.
- **Environment:** `Project.toml`/`Manifest.toml`. **Tests:** `Test`. **Docs:**
  docstrings (`"""…"""` above the definition). **Profiling:**
  `BenchmarkTools.@btime`, `@profile`/`Profile`.

# Stan

- **Use the right block:** `data`, `transformed data`, `parameters`,
  `transformed parameters`, `model`, `generated quantities`. Compute constants in
  `transformed data`, not inside `model`; put reusable deterministic transforms in
  `transformed parameters`.
- **Declare types with constraints/bounds:** `real<lower=0> sigma;`,
  `simplex[K] theta;`, `cov_matrix[K] Sigma;`. Constraints define the support and
  materially improve sampling — they are not decoration.
- **Vectorise sampling statements:** `y ~ normal(mu, sigma);` over an explicit
  loop — faster and clearer.
- **Work on the log scale:** prefer `target += ..._lpdf(...)` /`_lupdf` for
  density increments; use `log_sum_exp`, `log1m`, `log_inv_logit` rather than
  composing `exp`/`log` by hand.
- **Reparameterise for geometry:** use the non-centred parameterisation for
  hierarchical models when it helps the sampler, and comment *why*.
- **`generated quantities`** for posterior-predictive draws (`y_rep`) and
  pointwise `log_lik` (for LOO/WAIC) — keep them out of `model`.
- **Name parameters to match the model notation** and comment each prior with its
  rationale or source.
