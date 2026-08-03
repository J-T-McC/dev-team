# Workflow Overview

```
Product Owner
   ↓  feature request
Product Manager        — writes PRD                     → docs/product/
   ↓  ✋ Owner approves PRD
Designer (UI only)     — writes Design Spec             → docs/design/
   ↓  ✅ PM approves design against the PRD   (features without UI skip this phase)
Principal Engineer     — writes Technical Plan + ADRs   → docs/plans/, docs/architecture/
   ↓  ✅ PE self-certifies — ✋ Owner only for major decisions
Task Planner           — writes Task Plan               → docs/tasks/
   ↓  ✅ proceeds directly
Senior Developer       — implements tasks + tests       → source code
   ↓  all tasks complete with notes
Reviewer               — reviews against criteria       → docs/reviews/
   ↓  ✋ Owner approves release
Done
```

## Phases

1. **Requirements** — The Product Manager turns Product Owner intent into a PRD with testable acceptance criteria and explicit out-of-scope items.
2. **UX Design** *(UI features only)* — The Designer turns the approved PRD into a design spec: user flows, screens and states, components, interactions, accessibility. Features with no user-facing UI skip this phase.
3. **Technical Design** — The Principal Engineer turns the approved PRD (and design spec, if any) into a technical plan; significant decisions become ADRs.
4. **Task Planning** — The Task Planner breaks the approved plan into small, ordered, independently verifiable tasks.
5. **Implementation** — The Senior Developer implements tasks one at a time, with tests, recording completion notes.
6. **Review** — The Reviewer verifies the implementation against acceptance criteria, the plan, the design spec (if any), and standards, then recommends a decision.
7. **Approval** — The Project Owner decides at the ✋ gates: PRD, release, and major decisions surfaced mid-pipeline.

## Owner attention (major decisions only)

The Owner is involved exactly three ways: approving PRDs, approving releases, and deciding **major decisions** wherever they surface:

- New dependency, or any stack change
- Data-model change affecting existing data; anything irreversible or destructive
- Security-sensitive surface (auth, permissions, secrets, PII)
- Scope or requirement change to an approved PRD
- Anything an agent proposes as an ADR

Everything else is delegated: the **PM approves design specs** against the PRD; the **PE self-certifies plans** (bringing only the major decision — not the whole plan — to the Owner when one appears); **task plans proceed directly** to the Senior Developer, with the Reviewer catching drift. Delegated approvals are recorded like any other: `Approved by: <role>` in the artifact and `docs/status.md`. The Owner can always demand review of anything; a project's `CLAUDE.md` may tighten or loosen the majors list.

## Fast path (small work — the team goes flat)

Not everything needs the pipeline or the whole team. Small work is delegated **directly to one role**, documented, and done — no gates, no other roles:

- **Bugs and chores** (broken behavior, typos, config, dependency bumps) → **Senior Developer**: fix + tests + a fix record (`${CLAUDE_PLUGIN_ROOT}/templates/fix.md`) in `docs/fixes/<slug>.md`. Reviewer only when the Owner asks or the developer flags risk.
- **Small changes and doc corrections** → the role that **owns the affected artifact** (stale PRD line → Product Manager; outdated spec detail → Designer; plan drift → Principal Engineer), which updates the doc in place and notes the change.

The one rule that keeps this safe: fast-path work is **truth-preserving** — it restores intended behavior or makes documents match reality. It never changes an approved decision, requirement, public interface, data model, or ADR; truth-preserving edits need no re-approval, decision-changing edits do. If work turns out feature-shaped mid-flight, stop and enter the pipeline at the appropriate phase.

## Rules

- Phases never advance without their gate: ✋ gates need explicit Project Owner approval, ✅ gates the named delegate's — both recorded in the artifact and in `docs/status.md`.
- The Orchestrator routes work between phases and maintains `docs/status.md`, but owns no phase artifact.
- Any phase may send a question upstream (`${CLAUDE_PLUGIN_ROOT}/workflow/communication.md`); affected work pauses until answered.
- Rework flows backward through the same gates: a review Blocker returns work to the Senior Developer; a plan defect returns to the Principal Engineer and re-triggers plan certification; a design-spec defect returns to the Designer and re-triggers PM approval.
- Whether a feature has user-facing UI is the Product Manager's call, recorded in the PRD's Handoff **Next Agent** (Designer or Principal Engineer).
