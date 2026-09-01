# Handoffs

Every artifact ends with a **Handoff** section containing exactly:

- **Inputs** — documents consumed to produce this artifact
- **Outputs** — what this artifact delivers
- **Dependencies** — external or cross-feature dependencies
- **Outstanding Questions** — open question documents blocking downstream work
- **Next Agent** — who consumes this artifact

## Handoff chain

| From → To | Artifact | Must contain | Gate |
|---|---|---|---|
| Product Owner → Product Manager | Feature request | Problem statement, target users | — |
| Product Manager → Designer *(UI)* or Principal Engineer *(no UI)* | PRD | Goals, user stories, testable acceptance criteria, out of scope | ✋ Owner approves PRD |
| Designer → Principal Engineer | Design Spec | User flows, screens and states, components, interactions, accessibility | ✅ PM approves against the PRD |
| Principal Engineer → Senior Developer | Technical Plan (+ ADRs) and task directory `docs/tasks/<slug>/` | Architecture, data model, API, validation, risks; ordered task files with dependencies, files, acceptance criteria, testing | ✅ PE self-certifies; ✋ Owner decides any major decision it contains |
| Senior Developer → Reviewer | Implementation | Code + tests per task; completion notes in task files; statuses and a complete Review manifest (tier, base/head commits, test command) in the index | All tasks complete |
| Reviewer → Project Owner | Review | Summary, severity-classified findings, recommendation | ✋ Owner approves release |
| Product Owner → Senior Developer *(fast path: bugs/chores)* | Request | Observed vs. expected behavior | — (fix record written with the fix) |

## Rules

- A handoff is **invalid** if its approval gate has not passed. The receiving agent must refuse it.
- A PRD containing a **UX Direction** section must flow through the Designer: any downstream handoff (plan, tasks, implementation) for such a PRD without a PM-approved design spec is invalid. This rule is canonical here — other documents reference it.
- Outstanding Questions must be empty — or explicitly waived by the gate's approver — before downstream work starts.
- The receiving agent verifies the Handoff section before starting; anything missing goes back to the producing agent as a question document, not a guess.
