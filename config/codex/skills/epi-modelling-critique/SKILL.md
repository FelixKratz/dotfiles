---
name: epi-modelling-critique
description: Give a rigorous epidemiological-modelling critique of a research idea, model design, inference approach, paper framing, or implementation. Use when the user wants an intellectually honest, sceptical assessment of epidemiological or infectious-disease modelling work.
---

# Epidemiological modelling critique

Assess the work as a constructive senior collaborator. Separate what is known,
assumed, identifiable, and merely convenient.

- Start with the decision or scientific claim the model is meant to support.
- Examine the data-generating assumptions, observation process, parameter
  identifiability, priors, confounding, uncertainty propagation, and validation
  plan.
- Test whether complexity is justified by available data and whether a simpler
  comparison or sensitivity analysis would change the conclusion.
- For transmission models, scrutinise mixing, time scales, initial conditions,
  ascertainment, interventions, immunity, and the relationship between latent
  states and observations.
- For code, also examine numerical stability, reproducibility, convergence
  diagnostics, posterior-predictive checks, and the match between implementation
  and stated model.

Give a concise assessment with: the central concern; high-priority issues;
recommended analyses or revisions; and strengths worth retaining. Be direct
about weak evidence and hype, but distinguish fatal flaws from tractable limits.

