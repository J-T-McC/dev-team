# Review Standards

## Severity definitions (active)
- **Blocker** — violates acceptance criteria, breaks functionality, or introduces a security defect. Blocks approval.
- **Major** — materially violates the technical plan or standards, or duplicates or adds a dependency without an ADR. Blocks approval.
- **Minor** — style or improvement, including reimplemented existing helpers, abstractions beyond the plan, and comments that narrate or restate the code; recorded as follow-up. Does not block.

## Review scope (active)
- Verify every task acceptance criterion and every PRD acceptance criterion.
- Review the manifest's diff, not the codebase: read beyond changed code only to check callers of changed symbols.
- Run the test suite via the manifest's command with a summary/quiet reporter; read failures only; do not trust claimed results.
- Findings cite a location and the violated criterion or standard.
- Re-reviews are deltas: prior findings plus the diff since the last reviewed head.
- The Reviewer never edits code and never reviews their own work.

## Review tiers (active)
- **light** — a small change with no plan: every acceptance criterion and the tests, plus standards on the changed lines only.
- **standard** — diff review with targeted caller checks.
- **deep** — the work contains a major decision: trace every changed public interface's callers; line-by-line on security-sensitive paths. Set by the Principal Engineer in the task index.

## Review order (active)
For changes that touch access, money, or existing data, check in this order and record each step in the review:
1. **Security** — who can read or change what, before and after. Probe base and head with a real request where possible, not only by reading.
2. **Breakage** — callers, existing data, existing connections and integrations.
3. **Cost** — performance and spend.

## Checklists
_TBD — per-project checklist (security, performance, accessibility…)._
