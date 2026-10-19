> **Example artifact** — fictional; in a real project this lives at the same path under the workspace.

# T03 — Registration endpoint

- **Plan section:** §API, §Validation
- **Dependencies:** T01, T02
- **Files:** `src/auth/routes.*`, `tests/auth/test_register.*`

## Acceptance Criteria
201 on success; 409 on duplicate email (case-insensitive); 422 on invalid email or short password; password never logged.

## Testing
Endpoint tests for all four response cases.

## Completion notes
Done 2026-07-30 — all response cases covered; 8 tests pass.
