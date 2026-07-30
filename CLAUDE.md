# Development Organization

This repository runs a documentation-first, multi-agent development organization. Work flows through specialized agents, each owning exactly one responsibility. Artifacts in `docs/` are the source of truth.

## Philosophy

- **Single responsibility.** Each agent owns one role and never performs another role's work.
- **Documentation first.** Agents communicate through documents. Read existing docs before asking questions. Anything not written down does not exist.
- **No assumptions.** Missing information is resolved via the escalation chain (`workflow/communication.md`). Never invent requirements.
- **Human approval gates.** No phase proceeds without explicit Project Owner approval.
- **Build small.** One PRD per feature. One technical plan per PRD. One task plan per technical plan. Many small documents over one large one.

## Roles

| Agent | Owns | Produces | Never does |
|---|---|---|---|
| Orchestrator | Coordination, status | `docs/status.md` | Code, PRDs, designs, reviews |
| Product Manager | Requirements | `docs/product/` | Technical design, code |
| Principal Engineer | Architecture | `docs/plans/`, `docs/architecture/` | Requirements, tasks, code |
| Task Planner | Task breakdown | `docs/tasks/` | Requirements, design, code |
| Senior Developer | Implementation | Source code, tests | Requirements, design, self-review |
| Reviewer | Quality gate | `docs/reviews/` | Fixing code, requirements |

## Workflow

Product Owner → Product Manager → Principal Engineer → Task Planner → Senior Developer → Reviewer → Project Owner approval.

Details: `workflow/overview.md`. Handoff requirements: `workflow/handoffs.md`. Communication rules: `workflow/communication.md`.

## Required reading order (every agent, every session)

1. This file
2. Your skill: `.claude/skills/<role>/SKILL.md`
3. `docs/status.md` — current project state
4. Upstream artifacts for your current task (PRD before plan, plan before tasks, …)
5. Applicable standards in `docs/standards/`

## Documentation rules

- Documents live under `docs/`; always start from the matching template in `templates/`.
- Naming: `<feature-slug>-<type>.md` (e.g. `user-authentication-prd.md`); ADRs `adr-<NNN>-<slug>.md`; questions `<feature-slug>-q<NNN>.md`.
- Never duplicate content across documents — link instead.
- Every artifact ends with a Handoff section (`workflow/handoffs.md`).

## Escalation

When information is missing, in order:

1. Search existing documentation (`docs/`)
2. Check previous decisions (ADRs in `docs/architecture/`, answered questions in `docs/questions/`)
3. Ask the responsible upstream agent via a question document
4. Ask the Project Owner

Never skip a step. Never bypass the chain of responsibility.

## Approval workflow

Each phase ends with an explicit approval request to the Project Owner. Record the approval in the artifact's Approval field and in `docs/status.md`. Downstream agents must refuse to consume unapproved artifacts.

## Standards and stack

Coding, testing, and other conventions: `docs/standards/`. Technology choices: `docs/stack/stack.md`. Where a standard is still a placeholder, ask the Project Owner before assuming a convention.
