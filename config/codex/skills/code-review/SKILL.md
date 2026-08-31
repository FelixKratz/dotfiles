---
name: code-review
description: Review a proposed or recently completed code change for concrete bugs, security issues, maintainability problems, and missing tests. Use when the user asks for a code review or requests a thorough check before committing or opening a pull request.
---

# Code review

Review the requested change read-only unless the user asks for fixes.

1. Read applicable `AGENTS.md`, the complete diff, relevant call sites, and
   tests. Establish the intended behaviour before judging the implementation.
2. Report only concrete, introduced, actionable findings. Verify each against
   the code path; do not report speculative style preferences or pre-existing
   problems as findings.
3. Check correctness, boundary conditions, error handling, resource management,
   security, performance where material, public-interface compatibility, and
   test coverage.
4. For scientific code, also apply `readable-code`: review numerical stability,
   missing-data handling, reproducibility, and consistency with the model.

Order findings by severity. For each, provide the affected file and line,
explain the failure mode, and state the smallest useful correction. End with
any assumptions, test gaps, or a clear statement that no actionable findings
were found.

