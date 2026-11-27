---
title: Orca runtime
description: Run every role as its own Claude Code session, several in parallel, launched and supervised by Orca from yours.
---

Projects run from Orca can switch to a second runtime. Every role then runs as a top-level **peer session**, never as a subagent. A peer is a plain Claude session with everything the project gives one: all MCP servers, project skills, memory plugins such as claude-mem, Bash. Roles, documents, gates and question docs don't change. Only where a role runs does.

Your own session becomes the **coordinator**. It routes work, checks gates, keeps `status.md` and takes your approvals, and it does no hands-on work at all (not even a quick fix or a test run), so it stays free to answer you and the peers.

## Turn it on

Add one line to the dev-team section of `CLAUDE.md`:

```
- **Runtime: Orca.** Roles run as top-level Orca peers per the dev-team `workflow/orca.md`; never spawn subagents. Team model: opus. Fallback model: sonnet. Advisor: none. Peer size limit: 400k. Worktree cards: off.
```

and deny the subagent tool in `.claude/settings.json`, because peers are full sessions and would otherwise have it:

```json
{ "permissions": { "deny": ["Agent"] } }
```

`/dev-team:orca` writes both for you. It also offers the [recommended setup](/dev-team/orca-recommended/), which sets the models, homes, git and PR flow, and test and safety rules in one step.

Without the line the default runtime applies, even inside Orca. Every setting on the line is listed in the [settings reference](/dev-team/reference/settings/#the-runtime-line).

## Homes, worktrees and the Run

Peers live in named **homes**: `dt-product`, `dt-designer`, `dt-architect`, `dt-reviewer`, and `dt-dev-1`, `dt-dev-2` and so on for developers. A home holds one peer, started on its first dispatch, and the spec of each dispatch gives it its role.

Each home also gets a first name, picked at random the first time it's used, so the team reads like one: Bob the developer, Sandra the reviewer. The name shows beside the role on the home's terminal tab, on its worktree in Orca's sidebar, in `peer list` and on the [Owner board](/dev-team/board/), and the coordinator uses it when it tells you who did what. `peer team --rename dt-dev-1 Sandra` changes one.

By default a home is made on its first task. To see the whole team in Orca's sidebar from the start, `peer team --create` makes every home the [recommended setup](/dev-team/orca-recommended/) names at once. It makes the worktrees only, so nothing runs, and no usage is spent, until each home's first task. Setup asks which you want.

Worktrees are chosen per dispatch. Roles that work one after another share the feature worktree; each parallel stream gets its own child worktree. Only one peer edits a worktree at a time. (The [recommended setup](/dev-team/orca-recommended/) gives each home its own worktree instead.) The whole team shares one Orca Run, created by the first dispatch. Homes, their names and the Run are kept on the machine, in the git directory, never in the workspace.

## A fresh session per task

A peer is cheap to start next to a subagent (about 35k tokens in one measurement, most of it the project's own context: see [what your project costs](/dev-team/costs/)), and old context and old messages mislead the next task. So every task starts in a new session, in a new terminal, with the model pinned. New MCP servers, settings and plugin updates load too. Specs are self-contained and the work lives in the workspace, so nothing is lost.

A session is kept (`--keep`) only for a follow-up on the change it just built: fixing its review findings, or the reviewer that wrote a review checking the fixes.

## Launch settings

Every launch names its model and effort, so a `/model` typed in some other session never reaches a peer. `peer dispatch` reads them from the Runtime line each time:

- `Team model` is an alias such as `opus` or an exact id, optionally with an effort (`opus/high`). Peers don't launch without it.
- Effort is each role's default unless the Team model names one. The [Role models](/dev-team/roles/#models-and-effort) line overrides either, per role.
- `Fallback model` is used when the peer's model is busy or out of usage. When the watcher sees a peer stop on a usage limit, it records that model as out until it resets, and launches use the fallback until then.
- `Advisor` gives the product-manager and principal-engineer (or the roles you name) an advisor model for hard questions and the hard calls in their own plans. Other roles bring their hard questions to those two.

`peer dispatch … --model <model> --effort <effort>` runs one task on something else without touching the line. To change the line itself, edit it and run `peer switch` in the same turn. That types `/model` and `/effort` into every live peer and reads each screen back.

To add flags of your own to every peer's `claude` command, a permission mode for instance, set `DEV_TEAM_CLAUDE` in your environment.

## The coordinator's loop

The coordinator uses `peer`, a helper that wraps Orca's commands so no dev-team step gets skipped.

1. **Dispatch.** `peer dispatch <home> <role> <spec>` launches the peer and records the home. The spec points to the task file, never pastes it. Independent tasks go to different homes at once.
2. **Tell.** An idle peer doesn't read its mailbox, so `peer tell` sends the message and types a nudge into the peer's terminal until it starts a turn.
3. **Wait.** `peer watch` runs in the background and costs no tokens while it waits. It returns on any peer message except heartbeats, on a peer in trouble, or on a PR change, with one line per reason:

   | Line | Means |
   |---|---|
   | `STUCK` | stopped for two minutes on an API error or overload: tell it to continue |
   | `LIMIT` | stopped on a usage limit: `peer switch` moves it to the fallback |
   | `SIZE` | past the project's size limit: have it finish with a hand-over note |
   | `STALL` | working, but its screen hasn't changed for 20 minutes |
   | `CI` / `CONFLICT` | a failing check or merge conflict on a PR whose owner is idle |
   | `PR` | with the Owner board on, a team PR merged, closed, or changed draft state |
   | `BOARD` | with the Owner board on, rows that have drifted from their PRs |

4. **Handle the whole batch, then acknowledge it.** A peer asking for a go is answered first. A finished task is checked against its gate, `status.md` (and the board) are updated, and the home's next dispatch is chosen. Until the batch is acknowledged, `peer watch` returns it again straight away and `peer pending` lists it.
5. **Questions** stay question docs. A blocked peer writes one and asks; the coordinator dispatches it to the owning role and replies once it's answered.

## Guard hooks

Two plugin hooks act in the coordinator's session only. On every prompt they list peer questions still unanswered, reports not yet handled, and whether `status.md` has changed since the last board update. The Stop hook sends the turn back once while any of those is open, or while peers have work in flight and no `peer watch` is running. You'll never find the coordinator idle while a peer waits on it.

## PRs and their owners

`peer` keeps a record of which home owns which PR. A PR link in a peer's report records it automatically, and `peer pr <home> <PR>` records one by hand. When a check fails or a conflict appears on a PR whose owner isn't working, the watcher wakes the coordinator and names the owner to send it to. `peer prs --sweep` lists every open team PR with a failing check or a conflict, including your own open PRs in the repo.

## Peer lifetime

A fresh dispatch refuses while the peer is busy: its dispatch still running, its working line on screen, or a background shell or monitor that closing would kill. A session that has already exited isn't busy, whatever its last screen shows.

Closing a session stops the MCP server processes it left running and names anything else it left, such as a dev server, for you to close. It counts only processes started from the peer's worktree, so a machine-wide service the session happened to start, such as Docker Desktop, is left running for everyone. Add `Session caches:` to the Runtime line to clear per-session caches inside the peer's worktree as well.

`peer sleep <home>` (or `--idle` for all idle peers) closes a session and keeps its worktree; the next dispatch wakes it. A sleeping peer gets no messages, so anything for it goes in its next spec. A session that ended outside `peer`, after an `/exit` or a crash, keeps its terminal on record, so the next dispatch closes the shell left behind. `peer adopt` makes a home of a terminal you started by hand.

The size limit is the safety net inside a single task. `peer sizes` shows each peer's context against it. Use about 120k for a peer on a 200k-window model.

## Sharing the machine

Several peers on one machine run out of memory long before they run out of work. Put idle peers to sleep when their role has nothing coming; that's the coordinator's call, not yours.

Heavy jobs take turns through `slot`: test runs, builds, UI stacks, browser runs and fresh clones run as `slot run <label> -- <command>`. There are two slots machine-wide by default, and the critical path goes first with `--prio 1`. Long-lived containers take a slot from a separate pool so they never block test runs: `slot run db --pool containers -- docker compose up db`, run in the background. `slot status` shows who holds a slot and who's waiting.

## Parallel streams

When the task list has independent chains, each stream goes to its own developer home in its own child worktree. Each stream merges its own work as its last step, one at a time, testing only where code from different streams met. A real conflict with another stream's code means the plan's split was wrong, and goes to the principal-engineer as a question. The last merge completes the review manifest, and then the reviewer is dispatched.

## Remote peers

A home can run on a connected Orca server: `peer dispatch <home> <role> <spec> --on <environment> --worktree <selector>`. The Run, its messages and the coordinator stay on your machine, and the home remembers its server. Messages, the watcher and the guard hooks work the same. A remote launch takes only the model and effort, so the fallback model, the advisor and `DEV_TEAM_CLAUDE` don't apply there, and every remote task starts fresh.

## Worktree cards and the browser

`Worktree cards: on` mirrors `status.md` onto Orca's worktree cards, with an unread flag when you're needed. It's a lighter view than the [Owner board](/dev-team/board/) and the two can run together. Under this runtime, UI checks and mockup snapshots use Orca's built-in browser in place of Playwright.

[Check-ins](/dev-team/checkins/) are the other Orca extra: scheduled runs that keep work moving.

Full rules: [workflow/orca.md](https://github.com/J-T-McC/dev-team/blob/main/workflow/orca.md).
