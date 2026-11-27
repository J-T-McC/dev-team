---
title: Commands and scripts
description: The slash commands, the skills, and the scripts the roles and the coordinator run.
---

## Slash commands and skills

| Command | What it does |
|---|---|
| `dev-team:bootstrap` | sets up a project, or changes its setup; ask Claude to set up dev-team ([Get started](/dev-team/getting-started/)) |
| `dev-team:<role>` | runs a role in your conversation: `orchestrator`, `product-manager`, `designer`, `principal-engineer`, `senior-developer`, `reviewer` |
| `/dev-team:sync` | moves an old layout, copies missing seed files, reports drift ([Update and sync](/dev-team/updating/)) |
| `/dev-team:tickets ["change"]` | sets up, tunes or turns off the ticket system ([Ticket systems](/dev-team/tickets/)) |
| `/dev-team:checkins ["change"]` | sets up or changes the scheduled check-ins ([Check-ins](/dev-team/checkins/)) |
| `/dev-team:board` | sets up or refreshes the Owner board ([Owner board](/dev-team/board/)) |
| `/dev-team:orca [recommended \| "change"]` | sets up or changes the Orca runtime; `recommended` applies the [recommended setup](/dev-team/orca-recommended/) |
| `/dev-team:audit [days]` | looks back over the team's sessions from the last N days (default 7) to measure what each role's calls, reading files, and loading them at start cost, then trims the bloat you approve ([What it costs](/dev-team/costs/#the-audit)) |

## Scripts

The roles and the coordinator run these, from the plugin's `bin/` folder. You'll rarely need them by hand.

### peer

The coordinator's helper under the [Orca runtime](/dev-team/orca/). It keeps the homes, the Run and the PR owners in `<git common dir>/dev-team/peers.json`.

| Command | What it does |
|---|---|
| `peer dispatch [--keep] <home> <role> <spec>` | starts a task in a fresh session (or the same one, with `--keep`). Options: `--model` and `--effort` for this task only; `--worktree <selector>` with `--name` and `--base-branch` for a new worktree; `--on <environment>` (and `--repo`) for a remote server; `--title`; `--owner` for a task you asked for, which runs outside working hours too |
| `peer tell <home> <subject> <body> [--reply <id>] [--wait]` | sends a message and nudges the peer in the background to read it; `--wait` nudges in the foreground |
| `peer nudge <home> <subject>` | the background nudge `peer tell` starts; not run by hand |
| `peer switch [<home>...]` | gives live peers the Runtime line's current model and effort now |
| `peer sleep <home>... \| --idle` | closes idle peers' sessions and keeps their worktrees (`peer release` is the old name) |
| `peer adopt <home> <role> <terminal> [--on <environment>]` | makes a home of a terminal started outside `peer` |
| `peer watch [minutes]` | waits, at no token cost, for a peer message, trouble, a nudge that didn't land, or working hours ending or starting (default 15 minutes; outside working hours it waits for opening) |
| `peer wrap-up` | at closing time, tells every working peer to finish at its next clean point with a hand-over note |
| `peer pending [--full]` | the peer reports not handled yet (exit 1 if any); `--full` shows long ones uncut |
| `peer ack <delivery>` | marks a batch of reports handled, unless messages joined it after it was read: then it shows them instead |
| `peer pr <home> <PR>... \| peer pr --drop <PR>...` | records or drops which home owns a PR |
| `peer prs [--sweep]` | the team's PRs and owners; `--sweep` lists open ones with a failing check or a conflict |
| `peer sizes` | each peer's context size against the Peer size limit, with a note when Claude Code compacts before the limit |
| `peer limits [--clear [<model>]]` | models out of usage, as the watcher saw them |
| `peer list [--board-json <dir>]` | homes, names, roles, models, worktrees and tasks; or the board's peers rows as files |
| `peer team [--create \| --rename <home> <name>]` | who is who in the team; `--create` makes every home's worktree now, with no session until its first task; `--rename` gives a home a new name |
| `peer board-stamp [--rows <dir>]` | records that the Owner board matches `status.md` now |
| `peer hook prompt\|stop` | the guard hooks, run by the plugin |

### slot

Makes heavy jobs take turns on the machine.

| Command | What it does |
|---|---|
| `slot run <label> [--prio N] [--pool <name>] -- <command>` | waits for a free slot, runs the command, frees the slot when it ends. Lower `--prio` goes first (default 5; the critical path takes 1) |
| `slot status` | who holds a slot and who waits, in every pool |

### Board, setup, sync and audit

| Command | What it does |
|---|---|
| `board-drift <dir> [owner/repo] [--config <file>]` | lists Owner-board rows whose PR has moved on (exit 1 if any) |
| `board-drift --status <ws>/status.md [--config <file>] [--features <dir>] [--no-prs]` | lists `status.md` rows whose PRs (`#123`, `repo#123`, `repo #123`) have all merged or closed, whose task count disagrees with the feature's task index, or whose cells have grown into a log; `--no-prs` skips the PR lookups. Repo names go through the board config's `repos` map; a row naming a repo it can't place is left alone |
| `hours [--spec]` | whether the team is inside its working hours now, and until when (exit 1 when closed); `--spec` prints the Hours line's value |
| `setup-detect [--other-projects <dir>] [project-dir]` | what setup can tell before asking anything, as JSON: the project's state, remote and your access to it, its commit style and ticket prefix, what its code runs and what is configured but never run, the tools on the machine, the Claude plan and whether it's running inside Orca, your open PRs, and a suggestion with a reason for each setup question. `--other-projects` also summarizes what the git repos in that folder are built with, for stack suggestions; setup asks before using it |
| `seed-drift [project-dir]` | what the plugin's seeds have that the project's copies lack (used by `/dev-team:sync`) |
| `migrate-layout [--apply]` | moves a type-first workspace into feature folders; a dry run without `--apply` |
| `token-audit [--days N] [--top N] [project-dir]` | what the project's sessions spent in the last N days (default 7): calls, context, and compactions by reader; the tool schemas and MCP servers every call carries; reading files, by file and by reader; plus what every session loads and the documents over the size limit (used by `/dev-team:audit`) |

### Check-in triggers

Each exits non-zero when there's nothing to do, so Orca starts no session.

| Command | Runs the check-in when |
|---|---|
| `has-work <check-in>` | documents changed since the check-in last ran (`--mark` records the current state) |
| `stalled <check-in> [hours]` | a worker failed or exited early, or nothing has moved for some hours (default 4) |
| `new-tickets <check-in> [source]` | there are tickets it hasn't seen: `linear <team-key>`, `github`, or `github-project <owner> <n>` |
| `dev-team-lock acquire\|refresh\|release\|status` | (not a trigger) the lock that keeps one coordinator acting at a time |

## Hooks

The plugin installs these; there's nothing to set up.

| Hook | What it does |
|---|---|
| SessionStart | tells Claude the plugin is active and where the workspace is, warns when a role's memory grows large, flags an old layout, and keeps the check-in scripts where Orca can find them |
| UserPromptSubmit, Stop | the coordinator's guard: unanswered peer questions, unhandled reports, unwatched work, and an Owner board behind `status.md` |
| PostToolUse (Write, Edit) | tells the agent, once per session, when its edit takes a feature document past the size limit |
| Stop | commits an uncommitted workspace's own repository whenever it changed |
