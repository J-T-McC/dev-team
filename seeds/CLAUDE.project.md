# Development Organization

This project uses the **dev-team** Claude Code plugin: a pipeline of roles that work through documents. The workspace is the source of truth; if it isn't written down, it doesn't exist.

- **Workspace:** `docs` · features `docs/features` · folders `slug` · committed

Below, `<ws>` is the workspace root and `<feature>` a feature's folder (dev-team `workflow/workspace.md`).

## Rules

- **One role per piece of work.** No role does another role's job.
- **Run roles in this conversation.** Invoke the owning role's `dev-team:<role>` skill — same boundaries and gates as its agent, without the startup cost. One role at a time; at handoff, invoke the next. Spawn a role's agent only for parallel work, independent review (pipeline reviews always run in the reviewer agent), or when this conversation is too long for a big phase. The orchestrator skill routes work and keeps `<ws>/status.md`.
- **No assumptions.** Missing information: search the workspace → past decisions (ADRs, answered questions) → the owning role, via a question doc → the Project Owner. Never invent requirements.
- **Owner attention only where it matters.** The Owner approves PRDs, releases, and **major decisions** (new dependencies, stack changes, changes to existing data, security-sensitive or irreversible choices, ADRs). The product-manager approves design specs and answers requirement questions for the Owner; the principal-engineer certifies its own plans. Every approval is recorded in the artifact and `<ws>/status.md`; roles refuse unapproved inputs.
- **Autonomy: standard.** How involved the Owner is: `supervised` (Owner signs every gate), `standard`, or `autonomous` (roles sign; the Owner keeps only the floor). Hold gates with `; Owner keeps: <gates>`. Rules: dev-team `workflow/handoffs.md` § Autonomy.
- **Assume mistakes.** Every role checks its work against the source before handing off, and questions anything that looks wrong when it arrives — its own work and everyone else's.
- **Write plainly.** Docs, notes, and messages use short, plain English: say what was done or what is needed, then stop. Comment code only where the *why* is not obvious from the code.
- **Documents go forward.** Never write a PRD, plan, or ADR for work already shipped; existing architecture gets an ADR the first time it changes. Work adopted mid-flight is marked `pre-adoption` in `<ws>/status.md`.
- **Build small.** One PRD per feature; one design spec per UI feature; one plan and one task directory per PRD.
- **Not now is not lost.** Any role files deferred work as a backlog item; the product-manager owns the backlog (`<ws>/standards/planning.md`).

## Pipeline

Product Owner → **product-manager** (`<feature>/prd.md`) → **designer** (`<feature>/design.md` + `mockups/`, UI features only) → **principal-engineer** (`<feature>/plan.md` + `tasks/`; ADRs in `<ws>/architecture/`) → **senior-developer** (code + tests) → **reviewer** (`docs/reviews/`) → Owner approval.

Ask the **orchestrator** skill "what's next?".

**Fast path:** small work skips the pipeline. Bugs and chores → **senior-developer** (fix + tests + a record in `<ws>/fixes/`). Doc fixes → the role that owns the doc. No gates — as long as nothing approved changes (decision, requirement, interface, data model, ADR); if it does, it's pipeline work.

## Conventions

- Naming: one folder per feature in the features folder, holding `prd.md`, `design.md`, `mockups/`, `plan.md`, `tasks/` (`index.md` + `T01-<slug>.md`), `questions/` (`q001-<slug>.md`), `review.md`. Shared: ADRs `<ws>/architecture/adr-001-<slug>.md`; backlog `<ws>/backlog/` (`index.md`, `archive.md`, `B001-<slug>.md`); fixes `<ws>/fixes/<date>-<slug>.md`; finished features `<ws>/status-done.md`
- Commits: `<type>(<scope>): <task IDs> <what changed>`, short body if any (`<ws>/standards/coding.md`)
- Every artifact starts from a plugin template and ends with a Handoff section
- Standards: `<ws>/standards/`; stack: `<ws>/stack/stack.md`. Where placeholders remain, ask the Owner.

The plugin ships the templates, workflow rules, and a worked example; the roles know where they are.
