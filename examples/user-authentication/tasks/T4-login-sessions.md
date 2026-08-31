> **Example artifact** — fictional; in a real project this lives at the `docs/` path its naming implies.

# T4 — Sessions table and login endpoint

- **Plan section:** §Data Model, §Services, §API; expiry semantics per Q001
- **Dependencies:** T1, T2
- **Files:** `src/auth/session_service.*`, `src/auth/routes.*`, `migrations/*_create_sessions.*`, `tests/auth/test_login.*`

## Acceptance Criteria
Valid credentials yield an HttpOnly/Secure/SameSite=Lax cookie; 24h sliding expiry, 30d absolute with remember; 401 with generic message otherwise.

## Testing
Endpoint tests for success, failure, and both expiry modes.

## Completion notes
Done 2026-07-30 — SessionService + login implemented; 12 tests pass.
