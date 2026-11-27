# Orca Runtime (optional)

An alternative to the default runtime in `workflow/overview.md` ("Where work runs"), for projects driven from Orca. Roles, artifacts, gates, and question docs are unchanged — only *where a role runs* changes: each role runs as a top-level **peer session** launched and supervised by Orca orchestration. The plugin's `agents/` are not used. **No subagents, ever.**

## Opt in (per project)

Add to the project `CLAUDE.md` rules:

```
- **Runtime: Orca.** Roles run as top-level Orca peers per the dev-team `workflow/orca.md`; never spawn subagents. Team model: opus. Fallback model: sonnet. Advisor: none. Peer size limit: 400k. Worktree cards: off.
```

and deny the subagent tool in `.claude/settings.json` (`"permissions": { "deny": ["Agent"] }`) — peers are full sessions and would otherwise carry it. `/dev-team:orca` does both, and offers the **recommended setup** (`workflow/orca-recommended.md`): tested models, team shape, git and PR flow, test and safety rules, in one choice. Without the rule line the default runtime applies, even inside Orca. The settings are the project's to tune: models in § Launch settings, the size limit in § Peer lifetime (omitted, it is 400k — use about 120k for a peer on a 200k-window model).

## Topology

- **Coordinator** — the Project Owner's own session: orchestrator skill plus this file. Routes, verifies gates, keeps `<ws>/status.md`, takes the Owner's ✋ approvals. It does no role work — not even inline fast-path fixes — and no hands-on work: test runs, preview syncs, investigations, CI digging, and long waits go to a peer (usually as part of its task, or a `--keep` follow-up), so the coordinator stays free to answer the Owner and the peers.
- **Homes** — named peer slots: `dt-product`, `dt-designer`, `dt-architect`, `dt-reviewer`, and `dt-dev-1`, `dt-dev-2`, … for senior developers. Each holds one plain `claude` peer, started on the home's first dispatch. A peer has everything the project gives a normal session: all MCP servers, project skills, claude-mem, Bash. Its role comes from the spec's role line.
- **Names** — each home gets a first name, at random, the first time it is used: Bob the developer, Sandra the reviewer. The name shows beside the role on its terminal tab, on its own worktree in Orca's sidebar, in `peer list` and `peer team`, and on the Owner board, and the peer is told it. Talking to the Owner, call each peer by name and role ("Sandra, the reviewer, approved PR 12"). `peer team --rename <home> <name>` changes one.
- **Making the homes** — on its first dispatch by default. `peer team --create` makes every home Team setup names at once instead (`workflow/orca-recommended.md`), so the whole team is in Orca's sidebar from the start: worktrees only, since each task starts a fresh session (§ Peer lifetime) and a session started early would only be replaced. The first dispatch to a home made that way uses its worktree.
- **Worktrees** — chosen per dispatch, not per home: sequential roles work in the feature worktree, each parallel stream in its own child worktree. Only one peer edits a worktree at a time.
- **One Run for the team.** The first dispatch creates it. Homes, their names, and the Run are machine-local state in the git dir (`peer list`), never in the workspace.

## Launch settings

Every peer launch names its model and effort, so a `/model`, `/effort`, or `/advisor` in any other session — each also rewrites the default for new sessions — never reaches a peer. `peer dispatch` reads these from the Runtime line on every launch:

- **Team model** — `<model>[/<effort>]`: an alias (`opus`) or an exact id (`claude-opus-5-5`). Peers do not launch without it.
- **Effort** — each role's default (`workflow/overview.md` § Models per role), unless the Team model names one for everyone. The project's Role models line overrides the model, the effort, or both, per role.
- **Fallback model** — passed as `--fallback-model`, for when the peer's model is busy or unavailable. When `peer watch` finds a peer stopped on a usage limit, it records that model as out until its reset (`peer limits`), and launches use the fallback in its place until then.
- **Advisor** — `<model>`, or `<model> for <roles>`; the roles default to the product-manager and principal-engineer. Those peers launch with `--settings '{"advisorModel":"<model>"}'` and use it for hard questions another role brings them and hard calls in their own plans, not routine work. Every other role takes a hard question to those two as a question doc (`workflow/communication.md`) instead of guessing. The flag is left off while that model is out.
- **One task on another model:** `peer dispatch … --model <model> [--effort <effort>]` launches that task's session with them, without touching the line. `peer switch` leaves that peer alone, and its next dispatch is back on the line's settings.
- **Changing them:** edit the line, then run `peer switch` in the same turn — never "from the next task". It types `/model` and `/effort` into every live peer and reads each screen back; look at any peer it could not confirm. The fallback and advisor apply from each peer's next launch.
- The peer command is `claude` plus these flags; set `DEV_TEAM_CLAUDE` in your own environment to add flags of your own, such as a permission mode.

## Coordinator loop

`peer` is `${CLAUDE_PLUGIN_ROOT}/bin/peer`. It wraps the dev-team steps around Orca's commands so none can be skipped; Orca's version-matched guide (`orca skills get orchestration`) governs everything else, including recovery.

1. **Dispatch** — `peer dispatch [--keep] <home> <role> <spec> [--worktree <selector> [--name <name> --base-branch <ref>]] [--on <environment>]`. It prepends the role line and the pointer to § Peers, launches the peer per § Launch settings, and records the home. A start Orca reports ready can still fail a moment later — a terminal that already holds a dispatch, for one — so it reads the dispatch back a few seconds on and says so. The spec **points, never pastes**: the artifact or task file to work from (`<feature>/tasks/T03-….md`), its acceptance source, and the role's write boundary, which always includes the task's own file (its completion notes) and `<ws>/friction-log.md`. The peer reads the docs itself. Independent tasks go to different homes at once; add a `dt-dev-N` home when every developer home is busy.
2. **Tell, never just send.** An idle peer does not read its mailbox, so a bare `orca orchestration send` can sit unread while the peer waits on you. `peer tell <home> "<subject>" "<body>"` sends to the peer's dispatch and types a nudge into its terminal until a turn starts; to answer an `ask`, add `--reply <message-id>`. When it reports the nudge unconfirmed, look at the terminal. A peer whose dispatch has settled gets follow-up work as a dispatch (`--keep`), not a message, and a sleeping peer gets nothing until its next dispatch.
3. **Wait** — `peer watch [minutes]`, run in the background: it costs no tokens while it waits, and finds the work in flight itself, from the homes' dispatches. It returns on any peer message except heartbeats — peers do not reliably pick the right message type, and a go asked in a `status` must wake you as surely as `worker_done` — and on a peer in trouble: stopped for two minutes on an API error or overload (`STUCK`: tell it to continue) or a usage limit (`LIMIT`: `peer switch <home>` moves it to the fallback), past the size limit (`SIZE`), or a working peer whose screen has not changed for 20 minutes (`STALL`). It checks the team's PRs every 5 minutes (§ PRs). Otherwise it returns at the time limit. With the Owner board on, every return ends with the board's drift (`BOARD` lines, `workflow/board.md`).
4. **Handle the whole batch, then acknowledge.** A request for a go is answered first, in the same turn. `worker_done` is the handoff signal; the artifact is the handoff: verify the gate per `workflow/handoffs.md` (headers only), update `<ws>/status.md` (and the Owner board, when on), and choose the home's next dispatch (below). Once every message has its next step recorded — a question relayed to the Owner counts once it is on your Waiting on you list — `orca orchestration check --run <run> --ack <delivery>`. **The unacknowledged batch is the list of unhandled reports**: `peer watch` returns it at once until it is acknowledged, and `peer pending` shows it — run it before any status answer to the Owner.
5. **Questions** stay question docs (`workflow/communication.md`). A blocked peer writes the doc, then uses its preamble's `ask` naming the path; the coordinator dispatches it to the owning role's home and answers with `peer tell --reply` once it is `Answered`. Questions for the Owner are answered in the coordinator session.

## Guard hooks

The plugin's `UserPromptSubmit` and `Stop` hooks act only in the coordinator's session — the one that last ran `peer dispatch`, `tell`, `watch`, or `pending` — and only in a project with peer homes or an Owner board. On every prompt they list the peer questions not answered yet, then the reports not handled, and whether `<ws>/status.md` has changed since the last board write (`workflow/board.md` § Rules). The Stop hook sends the turn back once while any of these is open, or while peers have work in flight — on this machine or a remote one — and no `peer watch` is running, and says what to do.

## PRs

`peer` keeps a record of which home owns which PR, so an alert reaches the peer that can fix it. A PR link in a peer's report records it; `peer pr <home> <number or URL>…` records one by hand, `peer prs` lists them.

- **Alerts** — `peer watch` wakes on a newly failing check (`CI`) or a merge conflict (`CONFLICT`) on a recorded PR whose owner is not working — a working owner sees its own CI — and names the owner to route it to.
- **PR changes** — with the Owner board on, it also wakes when a recorded PR merges, closes, or moves between draft and ready (`PR`), so the board follows.
- **Sweep** — `peer prs --sweep` lists every open PR of the team — the recorded ones, and the Owner's own open PRs in the repo — with a failing check or a conflict, and its owner. Run it before a status answer, or as a check-in.

## Peers

Every peer follows these on top of Orca's worker contract; the role line points here.

- **A request for a decision or a go is an `ask`** — it blocks until answered. Never put one in a `status` message: nobody may act on it, and the Owner finds out from you that you were waiting.
- **One task per dispatch.** After `worker_done`, idle; the next task arrives as a new dispatch.
- **Every report ends with one line:** `Friction: none`, or what you logged (`workflow/friction.md`).
- **Heavy jobs take turns** (§ Machine resources), and you close what you start as soon as the step that needed it is done (`workflow/handoffs.md` § Assume mistakes).
- **Told you are over the size limit:** finish at the next clean point with a hand-over note (`workflow/handoffs.md` § Assume mistakes), then send `worker_done`.

## Peer lifetime — a fresh session per task

A peer starts cheaply next to a subagent (~35k measured), and old context and old inbox messages mislead the next task. So every new task starts clean; specs are self-contained and the work lives in the workspace, so nothing is lost.

- **Fresh (default)** — `peer dispatch` closes the peer's session and launches a new one in a new terminal, with the settings pinned (§ Launch settings), so new MCP servers, settings, and plugin updates load too. It refuses while the peer is busy: its dispatch still running, its working line on screen, or a background shell, monitor, or other job that closing would kill. The status bar's `← 1 agent` shows at an idle prompt too, so it does not count, and a session that has already exited is not busy, whatever its last screen says.
- **Clean up** — closing a session, on a fresh dispatch or `peer sleep`, stops the MCP server processes it left running and names anything else it left (a dev server, say) for you to close. Only processes started from the peer's worktree count: a machine-wide service the session happened to start, such as Docker Desktop, runs from its own folder and is left alone. Add `Session caches: <path>[, <path>]` to the Runtime line — paths inside the peer's worktree, globs allowed — to clear per-session caches too.
- **Keep (`--keep`)** — only for a follow-up on the change this session built: fixing its review findings, or a delta re-review by the reviewer session that wrote the review. It refuses a shell that started under an older Orca: its hook port is stale, and the dispatch would time out at agent readiness. Dispatch fresh.
- **Size limit** — the safety net inside one task. `peer watch` reports `SIZE` once per session past the project's limit; `peer sizes` lists every peer. Tell that peer to finish with a hand-over note, then dispatch the rest fresh from the note.
- **Sleep** — `peer sleep <home>`, or `peer sleep --idle` for every idle peer, closes the session and keeps the worktree; the next dispatch wakes it. Never message a sleeping peer: `peer tell` refuses, and the message goes in its next spec.
- **Sessions that end outside `peer`** — an `/exit`, a crash — keep their terminal in the registry, so the next dispatch or `peer sleep` closes the shell left behind; `peer list` shows them as `exited`. A terminal Orca reports as orphaned counts as closed. `peer adopt <home> <role> <terminal>` makes a home of a terminal started outside `peer`, so its next dispatch closes that terminal and launches fresh.

The Reviewer never reviews a change it implemented. The coordinator stays lean the same way as its peers: it reads only `worker_done` summaries and artifact headers, never peer transcripts, and between features may `/clear` and resume from `<ws>/status.md` plus `peer list`.

## Machine resources

Several peers share one machine, so it runs out of memory and slows down long before it runs out of work.

- **Sleep idle peers** whose role has no work coming (§ Peer lifetime). Waking and sleeping is the coordinator's call, never a question for the Owner.
- **Heavy jobs take turns.** Multi-file test runs, builds, UI stacks, browser runs, and fresh clones run through `${CLAUDE_PLUGIN_ROOT}/bin/slot run <label> [--prio N] -- <command>`: two machine-wide slots (`DEV_TEAM_SLOTS`), lower `--prio` first. The coordinator's spec names the critical path, which runs with `--prio 1`. `slot status` shows who holds and who waits.
- **Long-lived containers take a slot of their own**, in a separate pool so they never block test runs: `slot run <label> --pool containers -- docker compose up <service>` in the background holds it while the container runs, and `-- docker wait <container>` does the same for one already started detached. `DEV_TEAM_SLOTS_CONTAINERS` sets the pool's size (default 2).
- **Close what you start** — emulators, dev servers, containers, browser windows — as soon as the step that needed it is done (`workflow/handoffs.md` § Assume mistakes).

## Parallel streams

When the task index has independent chains, record the base commit in the Review manifest, then dispatch each stream to its own developer home in its own child worktree (`peer dispatch dt-dev-2 senior-developer <spec> --worktree new-child --name <slug>-<stream> --base-branch <feature-branch>`). Only streams branch; every other role works sequentially in the feature worktree.

**Each stream merges its own work** as its last dispatch (`--keep`):

- **Serialized** — the coordinator dispatches the next stream's merge only after the previous one settles. The peer brings its stream up to date with the feature branch, verifies, then advances the feature branch; it never overwrites another stream's merge.
- **Tests only where code combined** — docs-only changes, or a feature branch that has not moved since the stream last tested: none. Other streams' code came in: the targeted tests covering the code both touched (`<ws>/standards/testing.md`). The full suite runs once, on the last merge.
- **Trivial conflicts only** — its own lines and index/backlog rows. A real conflict with another stream's code means the plan's disjointness was wrong: question doc to the Principal Engineer, never a guessed resolution.
- **Last merge completes the Review manifest** (head commit, test command); the coordinator's spec says which merge is last. Then the Reviewer is dispatched, the stream homes are free, and each stream's child worktree is removed once its merge is in.

When an answered question lands in the feature worktree, the coordinator `peer tell`s the waiting stream to pull the feature branch.

## Remote peers

A home can run on a connected Orca server: `peer dispatch <home> <role> <spec> --on <environment> --worktree <selector>`. The Run, its messages, and the coordinator stay on this machine; the home remembers its server.

- **Where** — remote `current` and `new-child` are ambiguous, so the first dispatch names an exact remote selector (`id:<repo-id>::<path>`), or `new-top-level` with `--repo <selector> --name <name>`. Later dispatches reuse the worktree Orca reports.
- **Launch** — Orca starts the peer there with the model and effort (§ Launch settings); a remote launch takes nothing more, so no fallback model, advisor, or `DEV_TEAM_CLAUDE` flags. Every task is fresh: `--keep` is refused.
- **The rest works the same** — `peer tell` nudges through that server, `peer watch` reads its screen there, and its work counts as in flight for the guard hooks. Its size is not tracked: its transcript is on the other machine, and so are the processes a closed session leaves.

## Check-ins (optional)

Scheduled Orca automations that keep work moving without the Owner prompting: defined in `<ws>/standards/checkins.md`, applied with `/dev-team:checkins`. Each has a schedule, a role, a trigger check, a job, and limits.

- **Free when idle.** Orca runs the trigger check first; it exits non-zero — no session, no tokens — when nothing changed or another coordinator holds the lock. The plugin ships `has-work`, `stalled`, and `new-tickets` (`${CLAUDE_PLUGIN_ROOT}/bin/`); any shell command works.
- **Always reuse the session.** A run keeps its orientation instead of re-reading the project. It is not free: each run re-sends the whole session, and check-ins spaced further apart than the prompt cache lasts (minutes to an hour) pay it uncached — about the session's size. Keep check-in sessions small (§ Peer lifetime, size limit).
- **One coordinator at a time.** Whoever dispatches holds `${CLAUDE_PLUGIN_ROOT}/bin/dev-team-lock` — check-ins take it at the start of a run; an interactive coordinator takes it (`acquire owner`) before dispatching and releases it when its turn ends. A forgotten lock expires after 30 minutes.
- **Limits.** A check-in never exceeds the project's autonomy level: below *autonomous* it acts only where a gate is delegated, and flags anything that needs the Owner (on the board, when enabled).
- **Never restart sessions.** A check-in that finds a peer not responding reports it; restarting is the Owner's call.

## Worktree cards (optional)

The Owner board (`workflow/board.md`) is the fuller view and works with either runtime, switched on by its own `**Owner board:**` line; this is the lighter, Orca-native one, and the two can run together. Add `Worktree cards: on` to the project's Runtime line (formerly `Board: on`, which still works) to mirror `<ws>/status.md` onto Orca's worktree board — `<ws>/status.md` stays the truth. At each phase change the coordinator runs `orca worktree set --worktree <feature worktree> --workspace-status <status> --comment "<phase> · <role> · <blocker or none>"`, with status `todo` (Requirements), `in-progress` (UX Design, Technical Design, Implementation), `in-review` (Review), `completed` (Done). When the Owner is needed — an approval, an Owner question, a session not responding — it adds `--unread`. Features sharing a worktree share its card; the comment names each.

## Browser

Under this runtime, UI checks (senior-developer, reviewer) and mockup snapshots (designer) use Orca's built-in browser — `orca tab create --url …`, `orca snapshot`, `orca screenshot` — instead of a Playwright MCP server.
