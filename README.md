# dev-team

A reusable, documentation-first development organization for [Claude Code](https://code.claude.com), packaged as a plugin. Six specialized roles move feature work from requirements to reviewed code:

**Product Owner → product-manager → designer** *(UI features only)* **→ principal-engineer** *(plan + ADRs + task breakdown)* **→ senior-developer → reviewer → Owner approval**, coordinated by an in-conversation **orchestrator**.

Owner attention is reserved for what matters — approving PRDs, releases, and **major decisions** (new dependencies, stack/data-model changes, security-sensitive or irreversible choices). All other gates are delegated: design specs → product-manager, plans and task breakdowns → principal-engineer self-certified; the product-manager answers requirement questions as the Owner's proxy.

Small work skips the pipeline entirely (**fast path**): bugs and chores go straight to the senior-developer (fix + tests + a record in `docs/fixes/`), doc corrections to the role owning the doc — no gates, as long as the work is truth-preserving.

**Roles run inline by default.** All work — questions, fast-path fixes, and full pipeline phases in linear sequence — runs in the main conversation by invoking the owning role's skill, at a fraction of a subagent spawn's token cost. Agents spawn only when it pays for itself: **concurrency**, **independent review** (pipeline reviews always run in the reviewer agent — fresh eyes), or **context relief** (handing a big phase to a fresh context).

Tasks are token-frugal by design: each feature's breakdown is a directory (`docs/tasks/<slug>/`) with a status index and one file per task, so an implementing session loads the tiny index plus only the task it is working on — never the whole plan.

## Install (per project)

```
/plugin marketplace add J-T-McC/dev-team     # private repo: SSH auth is used automatically
/plugin install dev-team@dev-team
```

Then scaffold the project workspace (creates `docs/`, seeds standards/stack, project CLAUDE.md section):

```
run the dev-team:bootstrap skill
```

Fill in `docs/stack/stack.md` and customize `docs/standards/*.md` — agents stop and ask rather than guess while placeholders remain. Commit the scaffolded files to your project repo. Nothing from your project ever flows back into this repo.

Keep the project `CLAUDE.md` lean — it is loaded every session, while skills and `docs/` load on demand. The seed [`seeds/CLAUDE.project.md`](seeds/CLAUDE.project.md) is the recommended shape.

Project-level skills (`.claude/skills/`) work out of the box: every dev-team agent carries the `Skill` tool and is instructed to consult relevant domain skills (e.g. a `laravel` skill) before deciding or implementing — no plugin changes needed.

## Update (per project)

```
/plugin marketplace update dev-team    # refresh marketplace metadata from GitHub
/plugin update dev-team@dev-team       # then update the plugin itself
```

Every commit to this repo is a new version (no version pinning). Seeded files (`docs/standards/`, `docs/stack/`, `CLAUDE.md` section) are project-owned and are **not** touched by updates — use the sync command below to catch up.

## Sync seeds (per project)

```
/dev-team:sync
```

Plugin updates never touch project-owned files, so a project bootstrapped before a seed was added (or extended) silently lacks it — and agents have no fallback to the plugin's copies. Run sync after updating; it is safe to run any time:

- **Copies** any seed file the project is missing (standards, `docs/stack/stack.md`, `docs/status.md`) and creates any missing `docs/` directories
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
| `commands/` | `/dev-team:sync` — pull missing/updated seeds into a project | ✅ via plugin update |
| `templates/`, `workflow/` | Document templates, pipeline/handoff/communication rules | ✅ via plugin update |
| `hooks/` | Session-start announcement + agent-memory size sentinel | ✅ via plugin update |
| `seeds/` | Copied into projects by bootstrap/sync | ❌ project-owned after copy |
| `examples/user-authentication/` | Worked example of the full pipeline | ✅ via plugin update |
