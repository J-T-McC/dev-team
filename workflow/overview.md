# Workflow Overview

```
Product Owner
   ↓  feature request
Product Manager        — writes PRD                     → docs/product/
   ↓  ✋ Owner approves PRD
Designer (UI only)     — writes Design Spec             → docs/design/
   ↓  ✋ Owner approves design   (features without UI skip this phase)
Principal Engineer     — writes Technical Plan + ADRs   → docs/plans/, docs/architecture/
   ↓  ✋ Owner approves plan
Task Planner           — writes Task Plan               → docs/tasks/
   ↓  ✋ Owner approves tasks
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
7. **Approval** — The Project Owner makes the final call at every ✋ gate and at release.

## Rules

- Phases never auto-advance: every ✋ is an explicit Project Owner approval, recorded in the artifact and in `docs/status.md`.
- The Orchestrator routes work between phases and maintains `docs/status.md`, but owns no phase artifact.
- Any phase may send a question upstream (`${CLAUDE_PLUGIN_ROOT}/workflow/communication.md`); affected work pauses until answered.
- Rework flows backward through the same gates: a review Blocker returns work to the Senior Developer; a plan defect returns to the Principal Engineer and re-triggers plan approval; a design-spec defect returns to the Designer and re-triggers design approval.
- Whether a feature has user-facing UI is the Product Manager's call, recorded in the PRD's Handoff **Next Agent** (Designer or Principal Engineer).
