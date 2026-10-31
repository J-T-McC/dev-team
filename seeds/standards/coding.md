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

Footer, when needed: `Refs: <feature>/tasks/index.md`, `Closes: #<issue>`.

One commit per coherent unit of work: a task, a batch of tasks completed together, or one fast-path fix. Never mix pipeline work with unrelated fixes.

## Stacked PRs (active when `gh stack` is installed)
Applies when `gh extension list` shows `github/gh-stack`. Who syncs what is decided by what is in flight, not fixed: adapt as stacks form and change.

- **Build on unmerged work; don't wait for the merge.** A task that depends on work whose PR has not merged builds on that PR's branch as a stacked PR: `gh stack checkout <PR#>` (or `gh stack init <lower-branch>`), `gh stack add <branch>`, commit, then `gh stack submit --auto` (new PRs open as drafts) and set the real title.
- **Each PR is reviewed on its own diff.** Its base is the branch below it; that branch's head is the Review manifest's base commit.
- **A stack merges together, bottom up,** once every PR in it is reviewed and green. A green lower PR never merges alone: `main` stays shippable for anyone releasing.
- **Keeping branches current — the owner syncs by default.** Your own stack (every branch yours): `gh stack sync`, which rebases and force-pushes the whole stack with lease. A stack shared with others: bring only your branch up to date — merge the branch below into it and push — and never run `gh stack sync`, which would rewrite their branches. When many hands share stacks, the orchestrator (the coordinator under Orca) may name one **stack keeper** for a while: it brings lower changes up with merge commits only, never force-pushes, and tells each owner to pull. Say who syncs when a stack forms, and change it when the stack changes.

## Naming
_TBD — casing, file naming, module naming._

## Project structure
_TBD — directory layout, module boundaries._

## Error handling
_TBD — error types, propagation, user-facing messages._

## Logging
_TBD — levels, format, what must never be logged (secrets, credentials, tokens)._

## Comments and documentation in code
- Comment only the *why* the code cannot say: a non-obvious choice, a constraint or workaround, a link to the issue or spec behind it. Most code needs none.
- Never: narrate what the code does, restate a name or signature, log history ("changed X to Y"), or leave commented-out code.
- Docstrings only on public interfaces, one or two lines. _Customize: docstring format, if any._

## Dependencies
_TBD — approval process for adding dependencies. Default: new dependencies require an ADR._
