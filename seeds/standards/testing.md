# Testing Standards

> Owned by the Principal Engineer (proposes) and the approver dev-team `workflow/handoffs.md` § Autonomy names (the Owner, below autonomous). Setup fills what it can from the code; a section marked _open_ is set by the first plan that needs it, which proposes it.

## Requirements (active)
- Every task defines its tests before implementation starts (in its task file).
- The Senior Developer runs the full suite before marking any task complete.
- The Reviewer independently runs the suite during review.

## Behaviour changes (active)
Changes whose effect is statistical — prompts, model or tool choice, ranking, search relevance, performance — are accepted on a before/after run, never on reading the code: a fixed set of real cases, run several times on the base and on the branch; success checked against the system's real outcome (the database, not the reply); the cost (calls, failures, tokens, time); and an explicit list of what got worse.

## Test types and coverage
_Open — unit/integration/e2e expectations, coverage thresholds._

## Naming and structure
- Test names describe behaviour, not implementation.
- _Open — where tests live, file naming._

## Test data and fixtures
- Tests make their own data and never use real people's data or production.
- _Open — fixture and factory conventions._

## CI integration
- The full suite runs in CI on every pull request (`<ws>/stack/stack.md` § CI/CD).
