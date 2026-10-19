> **Example artifact** — fictional; in a real project this lives at the same path under the workspace.

# Tasks: User Authentication

- **Status:** Approved
- **Author:** Principal Engineer
- **Technical Plan:** `plan.md`
- **Approved by / date:** Principal Engineer (self-certified) / 2026-07-29

| ID | Task | Depends on | Status |
|---|---|---|---|
| T01 | Users table and model — `T01-users-table.md` | — | done |
| T02 | Password hashing service — `T02-password-hashing.md` | — | done |
| T03 | Registration endpoint — `T03-register-endpoint.md` | T01, T02 | done |
| T04 | Sessions table and login endpoint — `T04-login-sessions.md` | T01, T02 | done |
| T05 | Logout, current-user, auth middleware — `T05-logout-middleware.md` | T04 | done |

## Review manifest
- **Review tier:** deep — ADR-001 (session storage) and the auth surface are major decisions
- **Base commit:** `3f1c9aa`
- **Head commit:** `8d2e714`
- **Test command:** suite in summary mode — runner per `<ws>/stack/stack.md` (stack-neutral example)

## Handoff
- **Inputs:** certified technical plan, PRD acceptance criteria
- **Outputs:** this task directory
- **Dependencies:** none
- **Outstanding Questions:** none
- **Next Agent:** Senior Developer
