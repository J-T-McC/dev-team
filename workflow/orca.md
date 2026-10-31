# Orca Runtime (optional)

An alternative to the default runtime in `workflow/overview.md` ("Where work runs"), for projects driven from Orca. Roles, artifacts, gates, and question docs are unchanged — only *where a role runs* changes: each role runs as a top-level **peer session** launched and supervised by Orca orchestration. The plugin's `agents/` are not used. **No subagents, ever.**

## Opt in (per project)

Add to the project `CLAUDE.md` rules:

```
- **Runtime: Orca.** Roles run as top-level Orca peers per the dev-team `workflow/orca.md`; never spawn subagents. Peer size limit: 400k. Board: off.
```

and deny the subagent tool in `.claude/settings.json` (`"permissions": { "deny": ["Agent"] }`) — peers are full sessions and would otherwise carry it. Without the rule line the default runtime applies, even inside Orca. The size limit is the project's to tune (§ Peer lifetime); omitted, it is 400k — use about 120k for a peer on a 200k-window model.

## Topology

- **Coordinator** — the Project Owner's own session: orchestrator skill plus this file. Routes, verifies gates, keeps `<ws>/status.md`, takes the Owner's ✋ approvals. It does no role work — not even inline fast-path fixes.
- **Homes** — named peer slots: `dt-product`, `dt-designer`, `dt-architect`, `dt-reviewer`, and `dt-dev-1`, `dt-dev-2`, … for senior developers. Each holds one plain `claude` peer, started on the home's first dispatch. A peer has everything the project gives a normal session: all MCP servers, project skills, claude-mem, Bash. Its role comes from the spec's role line.
- **Worktrees** — chosen per dispatch, not per home: sequential roles work in the feature worktree, each parallel stream in its own child worktree. Only one peer edits a worktree at a time.
- **One Run for the team.** The first dispatch creates it. Homes and the Run are machine-local state in the git dir (`peer list`), never in the workspace.

## Coordinator loop

`peer` is `${CLAUDE_PLUGIN_ROOT}/bin/peer`. It wraps the dev-team steps around Orca's commands so none can be skipped; Orca's version-matched guide (`orca skills get orchestration`) governs everything else, including recovery.

1. **Dispatch** — `peer dispatch [--keep | --restart] <home> <role> <spec> [--worktree <selector> [--name <name> --base-branch <ref>]]`. It prepends the role line and the pointer to § Peers, launches a new home's peer with the role's model and effort (`workflow/overview.md` § Models per role), and records the home. The spec **points, never pastes**: the artifact or task file to work from (`<feature>/tasks/T03-….md`), its acceptance source, and the role's write boundary. The peer reads the docs itself. Independent tasks go to different homes at once; add a `dt-dev-N` home when every developer home is busy.
2. **Tell, never just send.** An idle peer does not read its mailbox, so a bare `orca orchestration send` can sit unread while the peer waits on you. `peer tell <home> "<subject>" "<body>"` sends to the peer's dispatch and types a nudge into its terminal until a turn starts; to answer an `ask`, add `--reply <message-id>`. When it reports the nudge unconfirmed, look at the terminal. A peer whose dispatch has settled gets follow-up work as a dispatch (`--keep`), not a message.
3. **Wait** — `peer watch [minutes]`, run in the background: it costs no tokens while it waits. It returns on any peer message except heartbeats — peers do not reliably pick the right message type, and a go asked in a `status` must wake you as surely as `worker_done` — when a peer passes the size limit (`SIZE`), when a working peer's terminal has been quiet for 20 minutes (`STALL`), or at the time limit.
4. **Handle the whole batch, then acknowledge.** A request for a go is answered first, in the same turn. `worker_done` is the handoff signal; the artifact is the handoff: verify the gate per `workflow/handoffs.md` (headers only), update `<ws>/status.md`, and choose the home's next dispatch (below). Once every message has its next step recorded, `orca orchestration check --run <run> --ack <delivery>`. **The unacknowledged batch is the list of unhandled reports**: `peer watch` returns it at once until it is acknowledged, and `peer pending` shows it — run it before any status answer to the Owner.
5. **Questions** stay question docs (`workflow/communication.md`). A blocked peer writes the doc, then uses its preamble's `ask` naming the path; the coordinator dispatches it to the owning role's home and answers with `peer tell --reply` once it is `Answered`. Questions for the Owner are answered in the coordinator session.

## Peers

Every peer follows these on top of Orca's worker contract; the role line points here.

- **A request for a decision or a go is an `ask`** — it blocks until answered. Never put one in a `status` message: nobody may act on it, and the Owner finds out from you that you were waiting.
- **One task per dispatch.** After `worker_done`, idle; the next task arrives as a new dispatch.
- **Told you are over the size limit:** finish at the next clean point with a hand-over note (`workflow/handoffs.md` § Assume mistakes), then send `worker_done`.

## Peer lifetime — a fresh session per task

A peer starts cheaply next to a subagent (~35k measured), and old context and old inbox messages mislead the next task. So every new task starts clean; specs are self-contained and the work lives in the workspace, so nothing is lost.

- **Fresh (default)** — `peer dispatch` runs `/clear` in the home's terminal and dispatches into it. It starts a new terminal instead (releasing the old one) with `--restart`, for a different worktree, or for a chat-mode worker. Restart on purpose when the peer needs new MCP servers, settings, or a plugin update, which `/clear` does not load — and after an Orca update, when a dispatch into an old shell times out at agent readiness.
- **Keep (`--keep`)** — only for a follow-up on the change this session built: fixing its review findings, or a delta re-review by the reviewer session that wrote the review.
- **Size limit** — the safety net inside one task. `peer watch` reports `SIZE` once per session past the project's limit; `peer sizes` lists every peer. Tell that peer to finish with a hand-over note, then dispatch the rest fresh from the note.
- **Release** — `peer release <home>` when a role will be idle for the foreseeable future. Otherwise a settled home waits for its next dispatch.

The Reviewer never reviews a change it implemented. The coordinator stays lean the same way as its peers: it reads only `worker_done` summaries and artifact headers, never peer transcripts, and between features may `/clear` and resume from `<ws>/status.md` plus `peer list`.

## Parallel streams

When the task index has independent chains, record the base commit in the Review manifest, then dispatch each stream to its own developer home in its own child worktree (`peer dispatch dt-dev-2 senior-developer <spec> --worktree new-child --name <slug>-<stream> --base-branch <feature-branch>`). Only streams branch; every other role works sequentially in the feature worktree.

**Each stream merges its own work** as its last dispatch (`--keep`):

- **Serialized** — the coordinator dispatches the next stream's merge only after the previous one settles. The peer brings its stream up to date with the feature branch, verifies, then advances the feature branch; it never overwrites another stream's merge.
- **Tests only where code combined** — docs-only changes, or a feature branch that has not moved since the stream last tested: none. Other streams' code came in: the targeted tests covering the code both touched (`<ws>/standards/testing.md`). The full suite runs once, on the last merge.
- **Trivial conflicts only** — its own lines and index/backlog rows. A real conflict with another stream's code means the plan's disjointness was wrong: question doc to the Principal Engineer, never a guessed resolution.
- **Last merge completes the Review manifest** (head commit, test command); the coordinator's spec says which merge is last. Then the Reviewer is dispatched and the stream homes are free.

When an answered question lands in the feature worktree, the coordinator `peer tell`s the waiting stream to pull the feature branch.

## Check-ins (optional)

Scheduled Orca automations that keep work moving without the Owner prompting: defined in `<ws>/standards/checkins.md`, applied with `/dev-team:checkins`. Each has a schedule, a role, a trigger check, a job, and limits.

- **Free when idle.** Orca runs the trigger check first; it exits non-zero — no session, no tokens — when nothing changed or another coordinator holds the lock. The plugin ships `has-work`, `stalled`, and `new-tickets` (`${CLAUDE_PLUGIN_ROOT}/bin/`); any shell command works.
- **Always reuse the session.** A run keeps its orientation instead of re-reading the project. It is not free: each run re-sends the whole session, and check-ins spaced further apart than the prompt cache lasts (minutes to an hour) pay it uncached — about the session's size. Keep check-in sessions small (§ Peer lifetime, size limit).
- **One coordinator at a time.** Whoever dispatches holds `${CLAUDE_PLUGIN_ROOT}/bin/dev-team-lock` — check-ins take it at the start of a run; an interactive coordinator takes it (`acquire owner`) before dispatching and releases it when its turn ends. A forgotten lock expires after 30 minutes.
- **Limits.** A check-in never exceeds the project's autonomy level: below *autonomous* it acts only where a gate is delegated, and flags anything that needs the Owner (on the board, when enabled).
- **Never restart sessions.** A check-in that finds a peer not responding reports it; restarting is the Owner's call.

## Board (optional)

Add `Board: on` to the project's Runtime line to mirror `<ws>/status.md` onto Orca's worktree board — `<ws>/status.md` stays the truth. At each phase change the coordinator runs `orca worktree set --worktree <feature worktree> --workspace-status <status> --comment "<phase> · <role> · <blocker or none>"`, with status `todo` (Requirements), `in-progress` (UX Design, Technical Design, Implementation), `in-review` (Review), `completed` (Done). When the Owner is needed — an approval, an Owner question, a session not responding — it adds `--unread`. Features sharing a worktree share its card; the comment names each.

## Browser

Under this runtime, UI checks (senior-developer, reviewer) and mockup snapshots (designer) use Orca's built-in browser — `orca tab create --url …`, `orca snapshot`, `orca screenshot` — instead of a Playwright MCP server.
