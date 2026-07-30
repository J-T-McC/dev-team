> **Example artifact** — fictional feature demonstrating the workflow. Delete when starting a real project.

# Task Plan: User Authentication

- **Status:** Approved
- **Author:** Task Planner
- **Technical Plan:** `docs/plans/user-authentication-plan.md`
- **Approved by / date:** Project Owner / 2026-07-29

## T1 — Users table and model
- **Description:** Create the `users` migration and model per plan §Data Model.
- **Dependencies:** none
- **Files:** `src/auth/models.*`, `migrations/*_create_users.*`
- **Acceptance Criteria:** migration applies cleanly; email uniqueness enforced at the database level on the lowercased value
- **Testing:** model unit test for the lowercase-unique email constraint
- **Completion notes:** Done 2026-07-30 — migration and model added; constraint test passes.

## T2 — Password hashing service
- **Description:** Implement `PasswordHasher` per plan §Services.
- **Dependencies:** none
- **Files:** `src/auth/password_hasher.*`
- **Acceptance Criteria:** hash/verify round-trip works; verification is constant-time; passwords under 10 chars rejected before hashing
- **Testing:** unit tests for round-trip, wrong-password rejection, and length rejection
- **Completion notes:** Done 2026-07-30 — implemented per plan; 6 unit tests pass.

## T3 — Registration endpoint
- **Description:** `POST /auth/register` per plan §API and §Validation.
- **Dependencies:** T1, T2
- **Files:** `src/auth/routes.*`, `tests/auth/test_register.*`
- **Acceptance Criteria:** 201 on success; 409 on duplicate email (case-insensitive); 422 on invalid email or short password; password never logged
- **Testing:** endpoint tests for all four response cases
- **Completion notes:** Done 2026-07-30 — all response cases covered; 8 tests pass.

## T4 — Sessions table and login endpoint
- **Description:** `sessions` migration, `SessionService`, and `POST /auth/login` per plan §Data Model, §Services, §API; expiry semantics per Q001.
- **Dependencies:** T1, T2
- **Files:** `src/auth/session_service.*`, `src/auth/routes.*`, `migrations/*_create_sessions.*`, `tests/auth/test_login.*`
- **Acceptance Criteria:** valid credentials yield an HttpOnly/Secure/SameSite=Lax cookie; 24h sliding expiry, 30d absolute with remember; 401 with generic message otherwise
- **Testing:** endpoint tests for success, failure, and both expiry modes
- **Completion notes:** Done 2026-07-30 — SessionService + login implemented; 12 tests pass.

## T5 — Logout, current-user endpoint, and auth middleware
- **Description:** `POST /auth/logout`, `GET /auth/me`, and request middleware exposing `current_user(request)` per plan §Architecture and §API.
- **Dependencies:** T4
- **Files:** `src/auth/middleware.*`, `src/auth/routes.*`, `tests/auth/test_session_flow.*`
- **Acceptance Criteria:** logout deletes the session row and immediately invalidates it; `/auth/me` returns 401 without a valid session; protected routes use only `current_user(request)`
- **Testing:** integration test covering login → me → logout → me(401)
- **Completion notes:** Done 2026-07-30 — full flow integration test passes; 42/42 suite green.

## Handoff
- **Inputs:** approved technical plan, PRD
- **Outputs:** this task plan
- **Dependencies:** none
- **Outstanding Questions:** none
- **Next Agent:** Senior Developer
