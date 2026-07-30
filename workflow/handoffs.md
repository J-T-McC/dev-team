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
| Product Manager → Principal Engineer | PRD | Goals, user stories, testable acceptance criteria, out of scope | ✋ Owner approves PRD |
| Principal Engineer → Task Planner | Technical Plan (+ ADRs) | Architecture, data model, API, validation, risks | ✋ Owner approves plan |
| Task Planner → Senior Developer | Task Plan | Ordered tasks with dependencies, files, acceptance criteria, testing | ✋ Owner approves tasks |
| Senior Developer → Reviewer | Implementation | Code + tests per task; task plan updated with completion notes | All tasks complete |
| Reviewer → Project Owner | Review | Summary, severity-classified findings, recommendation | ✋ Owner approves release |

## Rules

- A handoff is **invalid** if its approval gate has not passed. The receiving agent must refuse it.
- Outstanding Questions must be empty — or explicitly waived by the Project Owner — before downstream work starts.
- The receiving agent verifies the Handoff section before starting; anything missing goes back to the producing agent as a question document, not a guess.
