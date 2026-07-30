> **Example artifact** — fictional feature demonstrating the workflow. Ships with the dev-team plugin for reference; in a real project this artifact lives in the project workspace at the `docs/` path its naming conventions show.

# ADR-001: Session storage — server-side tokens vs JWT

- **Status:** Accepted
- **Author:** Principal Engineer
- **Date:** 2026-07-29
- **Feature:** user-authentication

## Question
How are user sessions represented and validated?

## Decision
Opaque random tokens stored server-side in a `sessions` table, delivered via HttpOnly cookie.

## Alternatives
1. Stateless JWT in a cookie or header
2. Server-side session table with opaque tokens *(chosen)*

## Reasoning
The PRD requires logout to invalidate the session immediately. Stateless JWTs cannot be revoked without a denylist, which reintroduces server state anyway. A session table is simpler, revocable, and cleanly supports the 30-day remember-me expiry from Q001.

## Impact
- Every authenticated request performs one indexed session lookup
- Enables future features: active-session listing, remote logout
- Requires eventual expired-session cleanup (noted as a plan risk)
