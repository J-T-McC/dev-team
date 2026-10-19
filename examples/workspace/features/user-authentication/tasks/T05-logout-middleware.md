> **Example artifact** — fictional; in a real project this lives at the same path under the workspace.

# T05 — Logout, current-user endpoint, and auth middleware

- **Plan section:** §Architecture, §API
- **Dependencies:** T04
- **Files:** `src/auth/middleware.*`, `src/auth/routes.*`, `tests/auth/test_session_flow.*`

## Acceptance Criteria
Logout deletes the session row and immediately invalidates it; `/auth/me` returns 401 without a valid session; protected routes use only `current_user(request)`.

## Testing
Integration test covering login → me → logout → me(401).

## Completion notes
Done 2026-07-30 — full flow integration test passes; 42/42 suite green.
