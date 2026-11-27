# Tasks: <Feature Name>

- **Status:** Draft | Approved
- **Author:** Principal Engineer
- **Source:** `<feature>/plan.md`, or `<feature>/brief.md` when there is no plan
- **Approved by / date:** <Principal Engineer (self-certified) / date>

One row per task; its detail lives in the task's own file. The Senior Developer sets Status here and writes completion notes in the task file.

| ID | Task | Depends on | Status |
|---|---|---|---|
| T01 | <name> — `T01-<slug>.md` | — | pending \| in progress (draft PR #N) \| done |

## Review manifest
The Reviewer's scope. The Principal Engineer sets the tier at certification; the Senior Developer fills in the rest (the base commit at the first task, the head and test command at completion).

- **Review tier:** light | standard | deep *(deep when the work contains a major decision; light for a small change with no plan)*
- **Base commit:** <commit before the first task>
- **Head commit:** <commit containing the final task>
- **Test command:** <suite invocation, summary/quiet reporter>

## Handoff
- **Inputs:**
- **Outputs:** this task directory
- **Dependencies:**
- **Related:** *(other features by folder name, and ADRs made or followed — `<ws>/architecture/adr-NNN-…`)*
- **Outstanding Questions:**
- **Next Agent:** Senior Developer
