---
name: epi-user-review
description: Review an epidemiological R package, analysis interface, documentation, function names, parameters, error messages, or workflow from the perspective of an epidemiologist who is not necessarily an R expert. Use when the user asks whether a scientific software interface is intuitive and usable.
---

# Epidemiologist user review

Evaluate the interface from the first task a working epidemiologist would try to
complete. Focus on whether names, defaults, output, and documentation make the
scientific choices legible.

Check:

- Function and parameter names for plain, domain-appropriate meaning.
- Defaults and required inputs for safety and discoverability.
- Error messages for an actionable next step.
- Documentation and examples for prerequisites, units, assumptions, and common
  interpretation mistakes.
- Outputs for uncertainty, labels, diagnostics, and a clear route to the next
  analytical step.
- Workflows for unnecessary R-specific knowledge or avoidable ceremony.

Report the few changes that would most improve successful use, with concrete
replacement wording or interface suggestions where helpful. Distinguish blocking
confusion from polish.
