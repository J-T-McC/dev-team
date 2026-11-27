# Project Status

Maintained by the **Orchestrator**. One row per feature **in flight**; update on every phase transition, approval, or blocker change. At Done the row moves to `status-done.md`.

<!-- With a ticket system enabled, the Feature cell carries the ticket ID: `user-auth (ENG-123)` -->

| Feature | Phase | Current Role | Next | Blockers | Approvals | Path |
|---|---|---|---|---|---|---|

One line per cell. Every role re-reads this file, so the detail stays in the feature's own files.

- **Phase:** one of `Requirements → [Discovery] → [UX Design] → [Technical Design] → Implementation → Review → Done`. Implementation adds the count: `Implementation: 24 of 47 tasks`.
- **Next:** the next step and who takes it (`merge #20 once main is green: Bruno`). Each task's and PR's state is in the task index and on the Owner board.
- **Approvals:** the gates passed, briefly: `PRD ✅ PM · design ✅ PM · plan ✅ PE`. Each approval's record is the `Approved by:` line in its artifact, and review verdicts stay in `review.md`. No history here.
- **Path:** the plan the team set for this feature, e.g. `brief → tasks → build → review`; bracketed phases appear only when on it.

Work that predates this organization records `pre-adoption` in **Approvals**: upstream gates waived, downstream gates apply in full. Never back-fill its missing artifacts (plugin `workflow/adoption.md`).
