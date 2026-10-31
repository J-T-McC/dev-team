# Testing Standards

> **Placeholder** — customize per project. Owned by the Principal Engineer (proposes) and Project Owner (approves).

## Requirements (active)
- Every task defines its tests before implementation starts (in its task file).
- The Senior Developer runs the full suite before marking any task complete.
- The Reviewer independently runs the suite during review.

## Behaviour changes (active)
Changes whose effect is statistical — prompts, model or tool choice, ranking, search relevance, performance — are accepted on a before/after run, never on reading the code: a fixed set of real cases, run several times on the base and on the branch; success checked against the system's real outcome (the database, not the reply); the cost (calls, failures, tokens, time); and an explicit list of what got worse.

## Test types and coverage
_TBD — unit/integration/e2e expectations, coverage thresholds._

## Naming and structure
_TBD — default guidance: test names describe behavior, not implementation._

## Test data and fixtures
_TBD._

## CI integration
_TBD — see <ws>/stack/stack.md CI/CD._
