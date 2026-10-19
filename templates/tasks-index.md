# Tasks: <Feature Name>

- **Status:** Draft | Approved
- **Author:** Principal Engineer
- **Source:** `<feature>/plan.md`, or `<feature>/brief.md` when there is no plan
- **Approved by / date:** <Principal Engineer (self-certified) / date>

<!-- One row per task; task detail lives in the task's own file. The Senior Developer flips Status here and writes completion notes in the task file. -->

| ID | Task | Depends on | Status |
|---|---|---|---|
| T1 | <name> — `T1-<slug>.md` | — | pending \| done |

## Review manifest
<!-- Tier set by the Principal Engineer at certification; the rest filled by the Senior Developer (base commit at first task, head + test command at completion). Defines the Reviewer's scope. -->
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
