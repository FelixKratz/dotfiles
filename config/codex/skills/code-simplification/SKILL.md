---
name: code-simplification
description: Simplify or refactor existing code while preserving behaviour. Use when the user asks to improve readability, reduce complexity, remove duplication, streamline control flow, or make code easier to maintain.
---

# Simplify code safely

1. Identify the existing behaviour, public interfaces, callers, and tests.
2. Make the smallest cohesive change that improves clarity. Prefer meaningful
   names, guard clauses, direct data flow, and one source of truth over clever
   abstractions.
3. Preserve externally visible behaviour unless the user requests a behaviour
   change. Keep error messages and edge-case handling compatible when they are
   part of the interface.
4. Do not combine simplification with unrelated formatting churn or architecture
   changes.
5. Run relevant tests and state what was verified.

For statistical code, retain mathematical notation and domain conventions;
apply `readable-code` rather than general-purpose refactoring rules that make a
derivation harder to follow.

