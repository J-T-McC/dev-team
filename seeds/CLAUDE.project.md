# Development Organization

This project uses the **dev-team** Claude Code plugin: a documentation-first pipeline of specialized roles. Artifacts under `docs/` are the source of truth; anything not written down does not exist.

## Rules

- **Single responsibility.** Every piece of work belongs to exactly one dev-team role; no role performs another role's work.
- **Default to the main conversation.** All work — questions, discussion, fast-path fixes, and full pipeline phases in linear sequence — runs in the main conversation by invoking the owning role's `dev-team:<role>` skill: same boundaries, artifacts, records, and gates as the role's agent, without agent startup cost. One role at a time: invoke the skill for the current phase; at handoff, invoke the next role's skill. Spawn a role's agent only when it pays for itself: **concurrency** (several work streams at once), **independent review** (pipeline reviews always run in the reviewer agent — fresh eyes), or **context relief** (the conversation is too long to take a big phase cleanly). Routing and `docs/status.md` upkeep run via the orchestrator skill.
- **No assumptions.** Missing information follows the escalation chain: search `docs/` → prior decisions (ADRs, answered questions) → responsible upstream role (via a question doc) → Project Owner. Never invent requirements.
- **Owner attention only where it matters.** The Project Owner approves PRDs, releases, and **major decisions** (new dependencies, stack changes, data-model changes to existing data, security-sensitive or irreversible choices, ADRs). All other gates are delegated: design specs → **product-manager** (verified against the PRD); technical plans and task breakdowns → **principal-engineer** self-certified. The product-manager answers requirement questions as the Owner's proxy from the vision, PRDs, and prior decisions. Every approval — Owner or delegate — is recorded in the artifact and `docs/status.md`; roles refuse unapproved upstream artifacts.
- **Build small.** One PRD per feature; one design spec per UI-bearing PRD; one technical plan and one task directory per PRD.
- **Not now is not lost.** Deferred work — scope cuts, tech debt, known bugs — is filed as a backlog item by any role; the product-manager owns the index and promotes items into the pipeline or the fast path (`docs/standards/planning.md`).

## Pipeline

Product Owner → **product-manager** (PRD → `docs/product/`) → **designer** (design spec → `docs/design/`, UI features only) → **principal-engineer** (plan + ADRs → `docs/plans/`, `docs/architecture/`; task breakdown → `docs/tasks/<slug>/`) → **senior-developer** (code + tests) → **reviewer** (`docs/reviews/`) → Project Owner approval.

The **orchestrator** skill routes work, verifies gates, and maintains `docs/status.md` — ask it "what's next?".

**Fast path (flat):** small work skips the pipeline. Bugs/chores → **senior-developer** (fix + tests + record in `docs/fixes/`). Small changes and doc corrections → whichever role owns the affected doc, updated in place. No gates and no other roles — as long as the work is truth-preserving; anything changing an approved decision, requirement, interface, data model, or ADR is pipeline work.

## Conventions

- Naming: `<feature-slug>-<type>.md`; tasks `docs/tasks/<feature-slug>/` (`index.md` + `T<NN>-<slug>.md`); ADRs `adr-<NNN>-<slug>.md`; questions `<feature-slug>-q<NNN>.md`; backlog `docs/backlog/` (`index.md` + `B<NN>-<slug>.md`)
- Commits are semantic — `<type>(<scope>): <task IDs> <what changed>`, terse body if any (`docs/standards/coding.md`)
- Every artifact starts from a plugin template and ends with a Handoff section
- Standards live in `docs/standards/`; the stack in `docs/stack/stack.md`. Where placeholders remain, ask the Project Owner rather than assuming.

Framework reference (templates, workflow rules, handoff requirements, worked example) ships inside the plugin; the roles know their paths.
