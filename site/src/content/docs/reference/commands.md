---
title: Commands and scripts
description: The slash commands, the skills, and the scripts the roles and the coordinator run.
---

## Slash commands and skills

| Command | What it does |
|---|---|
| `dev-team:bootstrap` | sets up a project; ask Claude to run the skill ([Get started](/dev-team/getting-started/)) |
| `dev-team:<role>` | runs a role in your conversation: `orchestrator`, `product-manager`, `designer`, `principal-engineer`, `senior-developer`, `reviewer` |
| `/dev-team:sync` | moves an old layout, copies missing seed files, reports drift ([Update and sync](/dev-team/updating/)) |
| `/dev-team:tickets ["change"]` | sets up, tunes or turns off the ticket system ([Ticket systems](/dev-team/tickets/)) |
| `/dev-team:checkins ["change"]` | sets up or changes the scheduled check-ins ([Check-ins](/dev-team/checkins/)) |
| `/dev-team:board` | sets up or refreshes the Owner board ([Owner board](/dev-team/board/)) |
| `/dev-team:orca [recommended \| "change"]` | sets up or changes the Orca runtime; `recommended` applies the [recommended setup](/dev-team/orca-recommended/) |
| `/dev-team:audit [days]` | measures what the team's sessions pay to read files and load at start, then trims the bloat you approve ([Get started](/dev-team/getting-started/#check-what-your-project-costs)) |

## Scripts

The roles and the coordinator run these, from the plugin's `bin/` folder. You'll rarely need them by hand.

### peer

The coordinator's helper under the [Orca runtime](/dev-team/orca/). It keeps the homes, the Run and the PR owners in `<git common dir>/dev-team/peers.json`.

| Command | What it does |
|---|---|
| `peer dispatch [--keep] <home> <role> <spec>` | starts a task in a fresh session (or the same one, with `--keep`). Options: `--model` and `--effort` for this task only; `--worktree <selector>` with `--name` and `--base-branch` for a new worktree; `--on <environment>` (and `--repo`) for a remote server; `--title` |
| `peer tell <home> <subject> <body> [--reply <id>]` | sends a message and nudges an idle peer to read it |
| `peer switch [<home>...]` | gives live peers the Runtime line's current model and effort now |
| `peer sleep <home>... \| --idle` | closes idle peers' sessions and keeps their worktrees (`peer release` is the old name) |
| `peer adopt <home> <role> <terminal> [--on <environment>]` | makes a home of a terminal started outside `peer` |
| `peer watch [minutes]` | waits, at no token cost, for a peer message or trouble (default 15 minutes) |
| `peer pending` | the peer reports not handled yet (exit 1 if any) |
| `peer pr <home> <PR>... \| peer pr --drop <PR>...` | records or drops which home owns a PR |
| `peer prs [--sweep]` | the team's PRs and owners; `--sweep` lists open ones with a failing check or a conflict |
| `peer sizes` | each peer's context size against the Peer size limit |
| `peer limits [--clear [<model>]]` | models out of usage, as the watcher saw them |
| `peer list [--board-json <dir>]` | homes, roles, models, worktrees and tasks; or the board's peers rows as files |
| `peer board-stamp [--rows <dir>]` | records that the Owner board matches `status.md` now |
| `peer hook prompt\|stop` | the guard hooks, run by the plugin |

### slot

Makes heavy jobs take turns on the machine.

| Command | What it does |
|---|---|
| `slot run <label> [--prio N] [--pool <name>] -- <command>` | waits for a free slot, runs the command, frees the slot when it ends. Lower `--prio` goes first (default 5; the critical path takes 1) |
| `slot status` | who holds a slot and who waits, in every pool |

### Board, sync and audit

| Command | What it does |
|---|---|
| `board-drift <dir> [owner/repo] [--config <file>]` | lists Owner-board rows whose PR has moved on (exit 1 if any) |
| `board-drift --status <ws>/status.md [--config <file>]` | lists `status.md` rows whose PRs (`#123`, `repo#123`, `repo #123`) have all merged or closed. Repo names go through the board config's `repos` map; a row naming a repo it can't place is left alone |
| `seed-drift [project-dir]` | what the plugin's seeds have that the project's copies lack (used by `/dev-team:sync`) |
| `migrate-layout [--apply]` | moves a type-first workspace into feature folders; a dry run without `--apply` |
| `token-audit [--days N] [--top N] [project-dir]` | what the project's sessions spent reading files in the last N days (default 7), by file and by reader, plus what every session loads and the documents over the size limit (used by `/dev-team:audit`) |

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
