# dev-team

A reusable, documentation-first development organization for [Claude Code](https://code.claude.com), packaged as a plugin. Six specialized roles move feature work from requirements to reviewed code:

**Product Owner → product-manager → designer** *(UI features only)* **→ principal-engineer** *(plan + ADRs + task breakdown)* **→ senior-developer → reviewer → Owner approval**, coordinated by an in-conversation **orchestrator**.

Owner attention is reserved for what matters — approving PRDs, releases, and **major decisions** (new dependencies, stack/data-model changes, security-sensitive or irreversible choices). All other gates are delegated: design specs → product-manager, plans and task breakdowns → principal-engineer self-certified; the product-manager answers requirement questions as the Owner's proxy.

**Choose how involved you are** with one line in the project `CLAUDE.md`: `Autonomy: supervised` (you sign every gate, down to each finished task), `standard` (the default above), or `autonomous` (roles sign everything; you keep only the floor — irreversible or destructive changes, security-sensitive surfaces, spending, and anything leaving the repo). Hold specific gates with `; Owner keeps: PRD, release`. Every decision made without you is recorded as `Approved by: <role> (autonomy: <level>)` for audit. Rules: [`workflow/handoffs.md`](workflow/handoffs.md) § Autonomy.

**Agents write plainly** — short, plain English in every doc and note, and code comments only where the *why* is not obvious ([`workflow/communication.md`](workflow/communication.md) § Plain language). No narrated code, no history comments, no commented-out code.

**Agents assume mistakes** — their own and each other's. Each self-reviews its output against the source documents (not its memory of them) before handing off, and questions an assignment or upstream artifact that smells wrong instead of silently complying or silently fixing it.

**Work is sized by the team.** The pipeline above is the longest path. For most ticket work the product-manager writes a short **brief** (what's wanted, testable acceptance criteria, the planned path) instead of a PRD, and each role decides whether its own phase is needed — design, a technical plan, an ADR, or time-boxed **discovery** when unknowns block a decision. Large features still get the full pipeline; a brief that outgrows itself becomes a PRD. Acceptance criteria and review are never skipped (review has a **light** tier for small changes).

Small work skips the pipeline entirely (**fast path**): bugs and chores go straight to the senior-developer (fix + tests + a record in the workspace's `fixes/`), doc corrections to the role owning the doc — no gates, as long as the work is truth-preserving.

**Roles run inline by default.** All work — questions, fast-path fixes, and full pipeline phases in linear sequence — runs in the main conversation by invoking the owning role's skill, at a fraction of a subagent spawn's token cost. Agents spawn only when it pays for itself: **concurrency**, **independent review** (pipeline reviews always run in the reviewer agent — fresh eyes), or **context relief** (handing a big phase to a fresh context).

Tasks are token-frugal by design: each feature's breakdown is a `tasks/` folder with a status index and one file per task, so an implementing session loads the tiny index plus only the task it is working on — never the whole plan. The **backlog** follows the same shape (`backlog/index.md` + one file per item): any role files deferred work — scope cuts, tech debt, known bugs — and the product-manager prioritizes and promotes it into the pipeline or the fast path.

## Workspace

One folder per feature holds everything it produces; shared material sits in the workspace root. Built for large projects, light for small ones ([`workflow/workspace.md`](workflow/workspace.md)):

```
docs/                    workspace root
  status.md              in flight
  status-done.md         finished, newest first
  architecture/          ADRs, shared: adr-001-session-storage.md
  backlog/               index.md (open), archive.md (closed), B001-….md
  fixes/                 2026-10-18-login-timeout.md
  standards/  stack/
  features/              (can live anywhere)
    user-auth/           prd.md  design.md  mockups/  plan.md  tasks/  questions/  review.md
```

Bootstrap asks for three settings, recorded in one `Workspace:` line: the **root** (`docs`), the **features folder** (anywhere — e.g. next to a team's own feature folders), and **folder naming** (`slug` for small projects, `F###-slug` or `<ticket>-slug` for large ones). Live indexes stay small — finished features and closed backlog items move to archives — so agents never pay for history. Projects on the older type-first layout are moved by `/dev-team:sync` (dry run first, `git mv`, links rewritten).

**Guest mode** is for someone else's project whose team does not use dev-team: the dev-team section goes in `CLAUDE.local.md`, the plugin is installed at local scope, the workspace is a hidden `.dev-team/` folder, their conventions win for code, commits, and PRs, and nothing outside the workspace mentions dev-team. The workspace can be **committed** (history with the code) or **not** (excluded locally; it becomes its own git repository, committed automatically by a Stop hook).

## Orca runtime (optional)

Projects driven from Orca can opt into a second runtime ([`workflow/orca.md`](workflow/orca.md)): every role runs as a long-lived **top-level peer session** launched and supervised by Orca orchestration — never a subagent. Peers are plain sessions with full project tools (MCP servers, skills, claude-mem); the dispatch spec gives each its role. Peers stay **warm** across dispatches to pay startup once, and the coordinator `/clear`s them at phase boundaries, past a context threshold, or after a failed attempt; the Reviewer is cleared before every review. Opt in with one line in the project `CLAUDE.md` plus a settings deny for the `Agent` tool — without it, nothing changes.

**Check-ins** (`/dev-team:checkins`) are scheduled Orca automations defined in the workspace's `standards/checkins.md` — e.g. keep work moving every 30 minutes, catch stalled or failed work hourly, have the product-manager groom tickets assigned to you each weekday. Each starts with a free trigger check, so an idle project costs nothing; each reuses its session so it keeps its bearings (a run still re-sends that session, so check-in sessions are kept small). Optional extras: mirror `status.md` onto Orca's worktree board (with an unread flag when you're needed), and Orca's built-in browser for UI checks in place of Playwright.

## Ticket systems (optional)

Work can come from Linear, Jira, GitHub Issues and Projects, or any tracker enabled through MCP — or through Orca's built-in Linear client or the `gh` CLI, which need no MCP server — configured per project in the workspace's `standards/tickets.md` (off by default; rules in [`workflow/tickets.md`](workflow/tickets.md)). The tracker is the **source of work and the record of outcomes**; agents still work and talk through the workspace, which is cheaper than MCP round-trips. A ticket is read once at intake and its ID carried in the PRD, fix record, and status row; phase changes sync its status; and only what the config's **Elevation** allowlist names goes back out — a release comment, high-priority bugs — never findings, questions, or task notes. Only the orchestrator and product-manager write to the tracker.

Bootstrap asks whether to connect one. Set up or fine-tune any time with `/dev-team:tickets "<change>"` (e.g. "also open tickets for review follow-ups") — it edits only the affected section, verifies the work query read-only, logs the change in the config's Tuning log, and writes on your approval.

## Install (per project)

```
/plugin marketplace add J-T-McC/dev-team     # private repo: SSH auth is used automatically
/plugin install dev-team@dev-team
```

Then scaffold the project workspace (asks own project or guest and the workspace settings, seeds standards/stack, writes the dev-team section; asks your autonomy level and whether to connect a ticket system):

```
run the dev-team:bootstrap skill
```

Fill in `stack/stack.md` and customize `standards/*.md` in the workspace — agents stop and ask rather than guess while placeholders remain. Commit the scaffolded files to your project repo. Nothing from your project ever flows back into this repo.

**Adopting into an existing project?** Bootstrap takes a second path ([`workflow/adoption.md`](workflow/adoption.md)): it surveys for collisions with your existing folders and `CLAUDE.md` first, then has the principal-engineer **harvest** the standards and stack from your codebase — manifests, CI, lint config, test layout, commit history — citing the file behind every line and leaving anything unevidenced as `_TBD_`; you approve. In-flight features enter at their true phase marked `pre-adoption` (upstream gates waived, downstream gates apply). Shipped work is **never** documented backwards — no retro PRDs, no retro ADRs. Documents are written forward, for the next change.

Keep the project `CLAUDE.md` lean — it is loaded every session, while skills and the workspace load on demand. The seed [`seeds/CLAUDE.project.md`](seeds/CLAUDE.project.md) is the recommended shape.

**Models per role:** the plugin pins no model — every role runs on your own default (the session's model, or your default subagent model for agents). Override per project with one `CLAUDE.md` line — `Role models: designer: opus/high; senior-developer: sonnet` — applied whenever a role's agent or Orca peer is started ([`workflow/overview.md`](workflow/overview.md) § Models per role).

**Design tools:** if the project designs in Figma, Penpot, or another tool with an MCP server, name it in the workspace's `standards/design.md` § Design tool — the designer builds its mockups there on your existing components, links the frames, and keeps a snapshot in the workspace for the roles that check UI against it. Otherwise mockups are self-contained HTML in `docs/design/`.

Project-level skills (`.claude/skills/`) work out of the box: every role has your full toolset (agents pin no tools) and its skill tells it to consult relevant domain skills (e.g. a `laravel` skill) before deciding or implementing — no plugin changes needed.

## Update (per project)

```
/plugin marketplace update dev-team    # refresh marketplace metadata from GitHub
/plugin update dev-team@dev-team       # then update the plugin itself
```

Every commit to this repo is a new version (no version pinning). Seeded files (workspace `standards/` and `stack/`, the dev-team section) are project-owned and are **not** touched by updates — use the sync command below to catch up.

## Sync seeds (per project)

```
/dev-team:sync
```

Plugin updates never touch project-owned files, so a project bootstrapped before a seed was added (or extended) silently lacks it — and agents have no fallback to the plugin's copies. Run sync after updating; it is safe to run any time:

- **Moves** an older type-first workspace to feature folders (dry run first, then `git mv` with links rewritten)
- **Copies** any seed file the project is missing (standards, `stack/stack.md`, `status.md`, `status-done.md`, the backlog index and archive) and creates any missing folders
- **Reports drift** in existing standards: lists seed sections (`##` headings) absent from your project's copy, ignoring your customizations
- **Appends only what you approve** — never overwrites, rewrites, or deletes project content

After a sync, fill placeholders in newly copied files and commit them to your project repo.

## Develop the framework locally

```
/plugin marketplace add /path/to/dev-team    # local checkout as a second marketplace
# after edits:
/plugin marketplace update dev-team
/reload-plugins
```

Validate with `claude plugin validate .`

## Layout

| Path | What | Updatable |
|---|---|---|
| `agents/`, `skills/` | The six roles (orchestrator is skill-only) + bootstrap skill | ✅ via plugin update |
| `commands/` | `/dev-team:sync` — pull missing/updated seeds into a project; `/dev-team:tickets` — ticket-system setup/tuning; `/dev-team:checkins` — Orca check-ins | ✅ via plugin update |
| `templates/`, `workflow/` | Document templates, pipeline/handoff/communication rules | ✅ via plugin update |
| `bin/` | Check-in trigger scripts and the coordinator lock (Orca runtime) | ✅ via plugin update |
| `hooks/` | Session-start announcement + agent-memory size sentinel | ✅ via plugin update |
| `seeds/` | Copied into projects by bootstrap/sync | ❌ project-owned after copy |
| `examples/workspace/` | Worked example of the full pipeline, in the workspace layout | ✅ via plugin update |
