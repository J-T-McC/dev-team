> **Example artifact** — fictional; in a real project this lives at the `docs/` path its naming implies.

# Tasks: User Authentication

- **Status:** Approved
- **Author:** Principal Engineer
- **Technical Plan:** `docs/plans/user-authentication-plan.md`
- **Approved by / date:** Principal Engineer (self-certified) / 2026-07-29

| ID | Task | Depends on | Status |
|---|---|---|---|
| T1 | Users table and model — `T1-users-table.md` | — | done |
| T2 | Password hashing service — `T2-password-hashing.md` | — | done |
| T3 | Registration endpoint — `T3-register-endpoint.md` | T1, T2 | done |
| T4 | Sessions table and login endpoint — `T4-login-sessions.md` | T1, T2 | done |
| T5 | Logout, current-user, auth middleware — `T5-logout-middleware.md` | T4 | done |

## Handoff
- **Inputs:** certified technical plan, PRD acceptance criteria
- **Outputs:** this task directory
- **Dependencies:** none
- **Outstanding Questions:** none
- **Next Agent:** Senior Developer
