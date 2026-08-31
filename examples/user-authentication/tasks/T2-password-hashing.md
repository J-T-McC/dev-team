> **Example artifact** — fictional; in a real project this lives at the `docs/` path its naming implies.

# T2 — Password hashing service

- **Plan section:** §Services
- **Dependencies:** none
- **Files:** `src/auth/password_hasher.*`

## Acceptance Criteria
Hash/verify round-trip works; verification is constant-time; passwords under 10 chars rejected before hashing.

## Testing
Unit tests for round-trip, wrong-password rejection, and length rejection.

## Completion notes
Done 2026-07-30 — implemented per plan; 6 unit tests pass.
