> **Example artifact** — fictional feature demonstrating the workflow. Ships with the dev-team plugin for reference; in a real project this artifact lives in the project workspace at the `docs/` path its naming conventions show.

# Review: User Authentication

- **Reviewer / date:** Reviewer / 2026-07-30
- **Scope:** T1–T5 of `docs/tasks/user-authentication-tasks.md`
- **Inputs verified:** PRD, technical plan, task plan with completion notes, full test run

## Summary
All five tasks are implemented with passing tests (42/42, run independently). Every task acceptance criterion and every PRD acceptance criterion verified, including immediate logout invalidation and absence of plaintext passwords in code and logs. Two minor findings; no blockers.

## Findings
| # | Severity | Location | Finding |
|---|---|---|---|
| 1 | Minor | `src/auth/session_service.*` | Expired sessions are deleted only on read. The plan's §Risks calls for a cleanup job as a follow-up, but no follow-up task exists yet. |
| 2 | Minor | `tests/auth/test_login.*` | Test names describe implementation ("test_token_row_insert") rather than behavior (`docs/standards/testing.md` §Naming). |

## Recommendations
- Ask the Task Planner to create a follow-up task for the session cleanup job before the table grows.
- Rename login tests to behavior style in the next change touching that file.
- Neither finding blocks approval.

## Approval
- **Recommendation:** Approve with follow-ups
- **Project Owner decision / date:** _pending_

## Handoff
- **Inputs:** task plan with completion notes, technical plan, PRD, independent test run
- **Outputs:** this review
- **Dependencies:** none
- **Outstanding Questions:** none
- **Next Agent:** Project Owner (approval decision)
