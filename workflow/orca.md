# Orca Runtime (optional)

An alternative to the default runtime in `workflow/overview.md` ("Where work runs"), for projects driven from Orca. Roles, artifacts, gates, and question docs are unchanged — only *where a role runs* changes: each role is a long-lived, top-level **peer session** launched and supervised by Orca orchestration. The plugin's `agents/` are not used. **No subagents, ever.**

## Opt in (per project)

Add to the project `CLAUDE.md` rules:

```
- **Runtime: Orca.** Roles run as top-level Orca peers per the dev-team `workflow/orca.md`; never spawn subagents. Peer clear threshold: 25% of the peer's context window. Board: off.
```

and deny the subagent tool in `.claude/settings.json` (`"permissions": { "deny": ["Agent"] }`) — peers are full sessions and would otherwise carry it. Without the rule line the default runtime applies, even inside Orca. The threshold is the project's to tune (below); omitted, it defaults to 25%.

## Topology

- **Coordinator** — the Project Owner's own session: orchestrator skill plus this file. Routes, verifies gates, keeps `<ws>/status.md`, takes the Owner's ✋ approvals. It does no role work — not even inline fast-path fixes.
- **Peers** — one plain `claude` session per active role, started by `worker-start --agent claude`. A peer has everything the project gives a normal session: all MCP servers, project skills, claude-mem, Bash. Its role comes from the dispatch spec, which always opens with the role line (below).
- **Parallel siblings** — independent streams (no dependency between them in the task index, disjoint files) each get their own senior-developer peer in their own Orca worktree. Only one peer edits a worktree at a time.

## Coordinator loop

Exact commands and settlement rules come from Orca's version-matched guide (`orca skills get orchestration`); the dev-team specifics:

1. **One Run per feature**: `orca orchestration run-create --objective "<feature-slug>"`.
2. **First dispatch to a role** launches its peer: `orca orchestration worker-start --spec "<spec>" --agent claude --worktree <selector> [--model <id> --effort <level>]`, with the role's model and effort per `workflow/overview.md` § Models per role (Orca accepts `--effort` only alongside `--model`; a role with no model launches on the Owner's default). Record the peer's terminal handle against its role.
3. **Later dispatches reuse it**: `orca orchestration task-create --spec "<spec>" [--deps …]`, then `worker-start --task <id> --terminal <handle> --worktree <selector>`. Task dependencies mirror the task index; independent tasks dispatch as one parallel wave.
4. **Every spec opens with the role line** — `You are the dev-team <role> peer. If the dev-team:<role> skill is not loaded in this conversation, invoke it first.` — so a fresh or cleared peer re-orients itself and a warm one does not reload. Then **point, never paste**: the artifact or task file to work from (`<feature>/tasks/T03-….md`), its acceptance source, and the role's write boundary. The peer reads the docs itself.
5. **`worker_done` is the handoff signal; the artifact is the handoff.** On settlement verify the gate per `workflow/handoffs.md` (headers only), update `<ws>/status.md`, decide the peer's next state (below), then acknowledge.
6. **Questions** stay question docs (`workflow/communication.md`). A blocked peer writes the doc, then uses its preamble's `ask` naming the path; the coordinator dispatches it to the owning role's peer and replies once it is `Answered`. Questions for the Owner are answered in the coordinator session.

## Peer lifetime — warm by default, cleared on purpose

Startup is a session's fixed cost (~35k measured: system prompt, skills, claude-mem context); a warm peer pays it once and keeps its orientation across dispatches. Between settled dispatches the coordinator chooses one:

- **Reuse warm** — next dispatch to the same terminal. The default within a phase or a stream.
- **Clear, then reuse** — `orca terminal send --terminal <handle> --text "/clear" --enter`, wait `--for tui-idle`, dispatch. **Content is the primary trigger** — poison is stale or wrong context, not a large one. Clear when any holds:
  - the last dispatch failed, was rejected, or hit a dead end — that context is poison, not orientation
  - the phase ended (plan certified, spec approved, the stream's tasks done) — what follows works from documents
  - the senior-developer batch limit hit (its skill's ~4 tasks)
  - **size fallback** — the peer's context passes the project's threshold (default 25% of its window: ~250k on a 1M model, ~50k on 200k). Size costs on every turn — each turn re-sends the whole context, cached or not — so this is a cost bound: clear once carried orientation is worth less than re-sending it. Check with `/context` (a local command, no model turn): grep the terminal output for `Messages:` and the window size.

  Until the threshold is tuned, check `/context` after every settlement and report the sizes to the Owner with the feature's outcome, so the project's number comes from real runs.
- **Release** — feature done, or the role is idle for the foreseeable future: `orca orchestration worker-release --dispatch <id>` closes the peer's terminal.

`/clear` needs terminal-mode agent tabs (Orca's Chat UI setting); with chat-mode workers, clearing means release plus a fresh `worker-start`.

**The Reviewer is never warm**: clear before every review, including delta re-reviews (prior findings live in the review doc), and never dispatch a review to a peer that implemented the change.

The coordinator stays lean the same way: it reads only `worker_done` summaries and artifact headers, never peer transcripts, and between features may `/clear` and resume from `<ws>/status.md` plus `orca orchestration task-list --ready --brief`.

## Parallel streams

When the task index has independent chains, record the base commit in the Review manifest, then start each stream's senior-developer peer in its own worktree (`worker-start … --worktree new-child --name <slug>-<stream> --base-branch <feature-branch>`). Only streams branch; every other role works sequentially in the feature worktree.

**Each stream merges its own work**, warm, as its last dispatch:

- **Serialized** — the coordinator chains the merge dispatches as Orca task dependencies, one at a time. The peer brings its stream up to date with the feature branch, verifies, then advances the feature branch; it never overwrites another stream's merge.
- **Tests only where code combined** — docs-only changes, or a feature branch that has not moved since the stream last tested: none. Other streams' code came in: the targeted tests covering the code both touched (`<ws>/standards/testing.md`). The full suite runs once, on the last merge.
- **Trivial conflicts only** — its own lines and index/backlog rows. A real conflict with another stream's code means the plan's disjointness was wrong: question doc to the Principal Engineer, never a guessed resolution.
- **Last merge completes the Review manifest** (head commit, test command); the coordinator's spec says which merge is last. Then the Reviewer is dispatched and stream peers are released.

When an answered question lands in the feature worktree, the coordinator's reply tells the waiting stream to pull the feature branch.

## Check-ins (optional)

Scheduled Orca automations that keep work moving without the Owner prompting: defined in `<ws>/standards/checkins.md`, applied with `/dev-team:checkins`. Each has a schedule, a role, a trigger check, a job, and limits.

- **Free when idle.** Orca runs the trigger check first; it exits non-zero — no session, no tokens — when nothing changed or another coordinator holds the lock. The plugin ships `has-work`, `stalled`, and `new-tickets` (`${CLAUDE_PLUGIN_ROOT}/bin/`); any shell command works.
- **Always reuse the session.** A run keeps its orientation instead of re-reading the project. It is not free: each run re-sends the whole session, and check-ins spaced further apart than the prompt cache lasts (minutes to an hour) pay it uncached — about the session's size. Keep check-in sessions small: the size rule for warm peers applies.
- **One coordinator at a time.** Whoever dispatches holds `${CLAUDE_PLUGIN_ROOT}/bin/dev-team-lock` — check-ins take it at the start of a run; an interactive coordinator takes it (`acquire owner`) before dispatching and releases it when its turn ends. A forgotten lock expires after 30 minutes.
- **Limits.** A check-in never exceeds the project's autonomy level: below *autonomous* it acts only where a gate is delegated, and flags anything that needs the Owner (on the board, when enabled).
- **Never restart sessions.** A check-in that finds a peer not responding reports it; restarting is the Owner's call.

## Board (optional)

Add `Board: on` to the project's Runtime line to mirror `<ws>/status.md` onto Orca's worktree board — `<ws>/status.md` stays the truth. At each phase change the coordinator runs `orca worktree set --worktree <feature worktree> --workspace-status <status> --comment "<phase> · <role> · <blocker or none>"`, with status `todo` (Requirements), `in-progress` (UX Design, Technical Design, Implementation), `in-review` (Review), `completed` (Done). When the Owner is needed — an approval, an Owner question, a session not responding — it adds `--unread`. Features sharing a worktree share its card; the comment names each.

## Browser

Under this runtime, UI checks (senior-developer, reviewer) and mockup snapshots (designer) use Orca's built-in browser — `orca tab create --url …`, `orca snapshot`, `orca screenshot` — instead of a Playwright MCP server.
