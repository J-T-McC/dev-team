# Development Organization

This project uses the **dev-team** Claude Code plugin: a documentation-first pipeline of specialized agents. Artifacts under `docs/` are the source of truth; anything not written down does not exist.

## Rules

- **Single responsibility.** Delegate feature work to the matching dev-team agent; no agent performs another role's work.
- **No assumptions.** Missing information follows the escalation chain: search `docs/` → prior decisions (ADRs, answered questions) → responsible upstream agent (via a question doc) → Project Owner. Never invent requirements.
- **Human approval gates.** No phase proceeds without explicit Project Owner approval, recorded in the artifact and in `docs/status.md`. Agents refuse unapproved upstream artifacts.
- **Build small.** One PRD per feature; one technical plan per PRD; one task plan per plan.

## Pipeline

Product Owner → **product-manager** (PRD → `docs/product/`) → **principal-engineer** (plan + ADRs → `docs/plans/`, `docs/architecture/`) → **task-planner** (`docs/tasks/`) → **senior-developer** (code + tests) → **reviewer** (`docs/reviews/`) → Project Owner approval.

The **orchestrator** routes work, verifies gates, and maintains `docs/status.md` — ask it "what's next?".

## Conventions

- Naming: `<feature-slug>-<type>.md`; ADRs `adr-<NNN>-<slug>.md`; questions `<feature-slug>-q<NNN>.md`
- Every artifact starts from a plugin template and ends with a Handoff section
- Standards live in `docs/standards/`; the stack in `docs/stack/stack.md`. Where placeholders remain, ask the Project Owner rather than assuming.

Framework reference (templates, workflow rules, handoff requirements, worked example) ships inside the plugin; the agents know their paths.
