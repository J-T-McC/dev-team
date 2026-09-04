# Coding Standards

> Sections marked _TBD_ are **placeholders** — customize per project. Until customized, the Senior Developer must ask the Project Owner before assuming a convention. Owned by the Principal Engineer (proposes) and Project Owner (approves).

## Commit messages (active)

Format: `<type>(<scope>): <task IDs> <what changed>`

- **Type:** `feat` | `fix` | `refactor` | `test` | `docs` | `chore` | `perf` | `build`.
- **Scope:** the feature slug for pipeline work (`user-authentication`), the fix slug for fast-path work, the doc area for doc-only commits (`standards`, `backlog`).
- **Task IDs:** range (`T1-T10`) or list (`T2, T5`) of the tasks the commit completes; a backlog item uses its ID (`B7`). Omit when no task or item applies.
- **Subject:** imperative, lowercase after the colon, no trailing period, ≤72 characters total.

```
feat(user-authentication): T1-T4 users table, hashing, register endpoint
fix(session-expiry-off-by-one): clamp TTL to the configured window
docs(standards): add commit message format
```

Body is optional and terse — **one summarized line per fact, ≤5 lines**. Facts only: behaviour changed, migration required, deviation from the plan. No paragraphs, no restating the diff, no narrating process. Anything longer belongs in the task's completion notes or the fix record, which the commit references rather than repeats.

Footer, when needed: `Refs: docs/tasks/<slug>/index.md`, `Closes: #<issue>`.

One commit per coherent unit of work: a task, a batch of tasks completed together, or one fast-path fix. Never mix pipeline work with unrelated fixes.

## Naming
_TBD — casing, file naming, module naming._

## Project structure
_TBD — directory layout, module boundaries._

## Error handling
_TBD — error types, propagation, user-facing messages._

## Logging
_TBD — levels, format, what must never be logged (secrets, credentials, tokens)._

## Comments and documentation in code
_TBD — when to comment, docstring format._

## Dependencies
_TBD — approval process for adding dependencies. Default: new dependencies require an ADR._
