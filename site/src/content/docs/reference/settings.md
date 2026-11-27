---
title: Settings
description: Every line, file and environment variable a project uses to configure dev-team.
---

## Lines in CLAUDE.md

All of these go in the project's dev-team section: `CLAUDE.md`, or `CLAUDE.local.md` for "just me" and guest mode. Setup writes the first four.

| Line | Example | Sets |
|---|---|---|
| [`**Workspace:**`](/dev-team/workspace/#the-workspace-line) | `` `dev-team` · features `dev-team/features` · folders `slug` · committed `` | where documents go and how folders are named |
| [`**Autonomy:**`](/dev-team/autonomy/) | `standard`, or `autonomous; Owner keeps: PRD, release` | who signs each gate |
| [`**Next work:**`](/dev-team/autonomy/#what-the-team-works-on) | `owner`, `product`, `tickets` or `steered` | whether the team starts new work without being asked, and where it comes from |
| [`**Hours:**`](/dev-team/autonomy/#working-hours) | `Mon–Fri 09:00–17:00`, or `any` (the default) | when the team starts work on its own |
| [`**Role models:**`](/dev-team/roles/#models-and-effort) | `designer: opus/high; senior-developer: sonnet` | the model and effort per role |
| [`**Runtime: Orca.**`](/dev-team/orca/) | see below | the Orca runtime and its launch settings |
| [`**Owner board:**`](/dev-team/board/) | `<artifact url>` | turns the Owner board on |
| [`**Ticket system**`](/dev-team/tickets/) | added by `/dev-team:tickets` | who may write to the tracker |
| [`## Team setup`](/dev-team/orca-recommended/) | a section added by `/dev-team:orca` | the recommended Orca setup's rules |

## The Runtime line

The settings come after the line's first sentence, each ending with a full stop:

```
- **Runtime: Orca.** Roles run as top-level Orca peers per the dev-team `workflow/orca.md`; never spawn subagents. Team model: opus. Fallback model: sonnet. Advisor: none. Peer size limit: 400k. Worktree cards: off.
```

| Setting | Values | Default |
|---|---|---|
| `Team model:` | an alias or exact id, optionally with an effort: `opus`, `opus/high`, `claude-opus-5-5` | none, and peers won't launch without it |
| `Fallback model:` | a model, or `none` | none |
| `Advisor:` | `none`, a model, or `<model> for <roles>` | none; the roles default to the product-manager and principal-engineer |
| `Peer size limit:` | a token count such as `400k` | `400k` (about `120k` suits a 200k-window model) |
| `Worktree cards:` | `on`, `off` (formerly `Board:`, still read) | `off` |
| `Session caches:` | paths inside the peer's worktree, globs allowed: `` `.cache/mcp-*` `` | none |

`/dev-team:sync` reports a setting that was renamed or added since the line was written.

## Files in the workspace

| File | Holds | Set up with |
|---|---|---|
| `standards/planning.md` | the Agent limits list and backlog rules | bootstrap |
| `standards/design.md` | the design tool, if any | bootstrap |
| `standards/coding.md` | coding conventions, including stacked PRs when `gh-stack` is installed | bootstrap |
| `standards/documentation.md` | how documents are written, and the size limit for live ones (§ Size and reading, 25 KB by default) | bootstrap |
| `standards/tickets.md` | the ticket-system config | `/dev-team:tickets` |
| `standards/checkins.md` | the check-in schedule | `/dev-team:checkins` |
| `stack/stack.md` | the project's stack | bootstrap, then you |

## .claude/settings.json

Under the Orca runtime, deny the subagent tool: `{ "permissions": { "deny": ["Agent"] } }`. To give collaborators the plugin, register the marketplace there too ([Get started](/dev-team/getting-started/#give-your-team-the-plugin)).

## Environment variables

Set these in your own environment. Most are timers you'll rarely need to touch.

| Variable | Default | What it does |
|---|---|---|
| `DEV_TEAM_CLAUDE` | `claude` | the command peers launch with; add flags of your own here |
| `DEV_TEAM_SLOTS` | `2` | machine-wide slots for heavy jobs |
| `DEV_TEAM_SLOTS_<POOL>` | `2` | the size of a named pool, such as `DEV_TEAM_SLOTS_CONTAINERS` |
| `DEV_TEAM_SLOT_WAIT` | `60` | the longest wait for a slot, in minutes; past it, `slot` exits with 75 |
| `DEV_TEAM_SLOT_POLL` | `2` | seconds between checks for a free slot |
| `DEV_TEAM_SLOT_GRACE` | `5` | seconds a stopped `slot run` gives its command and that command's children to exit before killing them |
| `DEV_TEAM_SLOT_DIR` | `~/.cache/dev-team/slots` | where slots are kept |
| `DEV_TEAM_LOCK_TTL_MIN` | `30` | minutes before a forgotten coordinator lock expires |
| `DEV_TEAM_STUCK_MIN` | `2` | minutes a peer sits on an error before `STUCK` |
| `DEV_TEAM_STATUS_CELL_MAX` | `300` | characters a `status.md` cell may hold before `board-drift --status` and `peer watch` flag it |
| `DEV_TEAM_STALL_MIN` | `20` | minutes a working peer's screen stays the same before `STALL` |
| `DEV_TEAM_WATCH_POLL` | `30` | seconds between the watcher's checks |
| `DEV_TEAM_PR_POLL` | `5` | minutes between the watcher's PR checks |
| `DEV_TEAM_RECHECK_SEC` | `5` | seconds before `peer dispatch` reads a new dispatch back |
| `DEV_TEAM_STEP_SEC` | `2` | seconds `peer` waits before reading a screen back or looking for a closed session's leftovers |
| `DEV_TEAM_CLOSE_SEC` | `10` | seconds `peer` waits for a session's terminal to close before giving up |
| `DEV_TEAM_CLOSE_RESEND_SEC` | `3` | seconds between the closes `peer` sends while it waits, since one sent as the session exits can be lost |
