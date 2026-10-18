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
- Exception, once per project: work adopted from before this organization carries `pre-adoption` in `docs/status.md` — its upstream gates are waived, its downstream gates are not (`workflow/adoption.md`).
- A PRD containing a **UX Direction** section must flow through the Designer: any downstream handoff (plan, tasks, implementation) for such a PRD without a PM-approved design spec is invalid. This rule is canonical here — other documents reference it.
- Outstanding Questions must be empty — or explicitly waived by the gate's approver — before downstream work starts.
- The receiving agent verifies the Handoff section before starting; anything missing goes back to the producing agent as a question document, not a guess.

## Autonomy

How involved the Project Owner is, set per project by one line in the project `CLAUDE.md`: `Autonomy: supervised | standard | autonomous`. No line means **standard** — the gates in the chain above. Change it any time; it applies from the next gate and never reopens an approved one.

| Gate | supervised | standard | autonomous |
|---|---|---|---|
| PRD | ✋ Owner | ✋ Owner | ✅ PM self-approves; gaps it filled are listed under the PRD's **Assumptions** |
| Design spec | ✋ Owner | ✅ PM | ✅ PM |
| Plan + task breakdown | ✋ Owner | ✅ PE self-certifies | ✅ PE self-certifies |
| Major decision (`workflow/overview.md`) | ✋ Owner | ✋ Owner | ✅ the owning role — PE in an ADR, PM in a PRD revision — the floor excepted |
| Each completed task | ✋ Owner checks before the next starts | — | — |
| Requirement question | ✋ Owner (PM drafts the answer) | ✅ PM as proxy | ✅ PM as proxy |
| Release (feature → Done) | ✋ Owner | ✋ Owner | ✅ Orchestrator, on *Approve* or *Approve with follow-ups* (follow-ups filed as backlog items) |

- **The floor stays with the Owner at every level**: anything irreversible or destructive (including data-model changes affecting existing data), security-sensitive surfaces (auth, permissions, secrets, PII), anything that spends money, and any action leaving the repository (deploy, publish, external messages). Release means *Done in `docs/status.md`*, never a deploy. Ticket-system writes that `docs/standards/tickets.md` allows are pre-authorized by that config (`workflow/tickets.md`).
- **Overrides** follow the level: `Autonomy: autonomous; Owner keeps: PRD, release` holds named gates at ✋; `Owner waives: floor` delegates the floor too and must be written out explicitly.
- **Record who decided**: an approval made because of the level reads `Approved by: <role> (autonomy: <level>)` in the artifact and `docs/status.md`, so the Owner can audit everything decided without them.
- Autonomy never removes a gate, the independent review, or a role boundary — it only changes who signs. Fewer Owner checkpoints raise the bar on **Assume mistakes** below.

## Assume mistakes

Every agent — you included — makes mistakes, and long sessions drift from their task. Treat your own output and every input as possibly wrong.

- **Before handing off, self-review against the source, not memory.** Re-read the assignment from disk (task file, PRD criteria, request) and check the output against each item. Look for: a criterion claimed without evidence; work beyond what was assigned; an assumption never confirmed; a placeholder or TODO left in; a contradiction with an upstream artifact or earlier decision; a test that would still pass if the code were wrong. State what you could not verify (`Unverified: …`) in the completion notes or Handoff — never hide it.
- **On receipt, question what smells.** An assignment can be wrong too — a request, a dispatch, a task, an upstream artifact. Smells: criteria that are untestable or contradict each other; a task that conflicts with the code, the plan, the standards, or the PRD's scope; a missing approval; a step that seems unnecessary or unexplained; an instruction that contradicts the documents (documents win). Blocking smell → question document to the owner (`workflow/communication.md`) and pause that item only; non-blocking → proceed and record it. Questioning is expected; deciding stays with the owner.
- **Watch for drift.** Cannot state the acceptance criteria without looking, editing files the task does not name, or reversing an earlier decision → stop, re-read the sources, and if the session is long, end at a clean boundary so a fresh context continues.
- **Approving is verifying.** A delegated or self-approval gets the same scrutiny as an Owner approval — never a rubber stamp.
