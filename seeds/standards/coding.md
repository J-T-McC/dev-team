# Coding Standards

> Owned by the Principal Engineer (proposes) and the approver dev-team `workflow/handoffs.md` § Autonomy names (the Owner, below autonomous). Setup fills what it can from the code; a section marked _open_ is set by the first plan that needs it, which proposes it. Until then, follow the code around you and never guess a new convention.

## Commit messages (active)

Format: `<type>(<scope>): <ID> <what changed>`

- **Type:** `feat` | `fix` | `refactor` | `test` | `docs` | `chore` | `perf` | `build`.
- **Scope:** the feature slug for pipeline work (`user-authentication`), the fix slug for fast-path work, the doc area for doc-only commits (`standards`, `backlog`).
- **ID:** the ticket ID when the work has one (`ENG-123`), from the `Ticket:` line in its documents or its `status.md` row, so people can find the ticket from the history. With no ticket, the task IDs the commit completes (range `T1-T4` or list `T2, T5`) or the backlog item's ID (`B7`) — the last resort, since only dev-team's agents know what they mean. Omit when nothing applies. The ID goes after the colon: `feat(auth) - ENG-123` is not a conventional commit, so release tools and commit linters skip it.
- **Subject:** imperative, lowercase after the colon, no trailing period, ≤72 characters total.

```
feat(user-authentication): ENG-123 users table, hashing, register endpoint
fix(session-expiry-off-by-one): ENG-131 clamp TTL to the configured window
docs(standards): add commit message format
```

Without a ticket, the first would be `feat(user-authentication): T1-T4 users table, hashing, register endpoint`.

Body is optional and terse — **one summarized line per fact, ≤5 lines**. Facts only: behaviour changed, migration required, deviation from the plan. No paragraphs, no restating the diff, no narrating process. Anything longer belongs in the task's completion notes or the fix record, which the commit references rather than repeats.

Footer, when needed: `Refs: <feature>/tasks/index.md`, `Closes: #<issue>`.

One commit per coherent unit of work: a task, a batch of tasks completed together, or one fast-path fix. Never mix pipeline work with unrelated fixes.

## Stacked PRs (active when `gh stack` is installed)
Applies when `gh extension list` shows `github/gh-stack`. Who syncs what is decided by what is in flight, not fixed: adapt as stacks form and change.

- **Build on unmerged work; don't wait for the merge.** A task that depends on work whose PR has not merged builds on that PR's branch as a stacked PR: `gh stack checkout <PR#>` (or `gh stack init <lower-branch>`), `gh stack add <branch>`, commit, then `gh stack submit --auto` (new PRs open as drafts) and set the real title. A branch can be checked out in only one worktree, so under Orca the task goes to the home that holds the lower branch, or that home detaches first (`git checkout --detach`).
- **Each PR is reviewed on its own diff.** Its base is the branch below it; that branch's head is the Review manifest's base commit.
- **A stack merges together, bottom up,** once every PR in it is reviewed and green. A green lower PR never merges alone: `main` stays shippable for anyone releasing.
- **Keeping branches current — the owner syncs by default.** Your own stack (every branch yours): `gh stack sync`, which rebases and force-pushes the whole stack with lease. Where force-pushes aren't allowed (Claude Code's auto mode blocks them without a permission rule), merge the branch below into each of yours instead, and fix a wrong commit subject in the PR title, which the squash merge uses. A stack shared with others: bring only your branch up to date — merge the branch below into it and push — and never run `gh stack sync`, which would rewrite their branches. When many hands share stacks, the orchestrator (the coordinator under Orca) may name one **stack keeper** for a while: it brings lower changes up with merge commits only, never force-pushes, and tells each owner to pull. Say who syncs when a stack forms, and change it when the stack changes.

## Naming
_Open — casing, file naming, module naming._

## Project structure
_Open — directory layout, module boundaries._

## Error handling
_Open — error types, propagation, user-facing messages._

## Logging
- Never log secrets, credentials, tokens, or personal data.
- _Open — levels, format._

## Comments and documentation in code
- Comment only the *why* the code cannot say: a non-obvious choice, a constraint or workaround, a link to the issue or spec behind it. Most code needs none.
- Never: narrate what the code does, restate a name or signature, log history ("changed X to Y"), or leave commented-out code.
- Docstrings only on public interfaces, one or two lines, in the language's usual format.

## Dependencies
- A new dependency is a major decision: an ADR, signed as dev-team `workflow/handoffs.md` § Autonomy says.
- Prefer an established, maintained library over writing your own; prefer what the project already uses over a new one.
