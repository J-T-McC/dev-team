> **Example artifact** — fictional; in a real project this lives at the `docs/` path its naming implies.

# T1 — Users table and model

- **Plan section:** §Data Model
- **Dependencies:** none
- **Files:** `src/auth/models.*`, `migrations/*_create_users.*`

## Acceptance Criteria
Migration applies cleanly; email uniqueness enforced at the database level on the lowercased value.

## Testing
Model unit test for the lowercase-unique email constraint.

## Completion notes
Done 2026-07-30 — migration and model added; constraint test passes.
