> **Example artifact** — fictional feature demonstrating the workflow. Ships with the dev-team plugin for reference; in a real project this artifact lives in the project workspace at the `docs/` path its naming conventions show.

# Technical Plan: User Authentication

- **Status:** Approved
- **Author:** Principal Engineer
- **PRD:** `docs/product/user-authentication-prd.md`
- **Approved by / date:** Project Owner / 2026-07-29

## Overview
Add an `auth` module providing registration, login/logout, and session validation behind four REST endpoints. Sessions are opaque server-side tokens (ADR-001).

## Architecture
- `auth` module isolated from feature code; other modules depend only on its `current_user(request)` interface
- Middleware resolves the session token from an HttpOnly cookie on every request

## Data Model
- `users`: id, email (unique, stored lowercased), password_hash, created_at
- `sessions`: token (random 256-bit, primary key), user_id, expires_at, remember (bool), created_at

## API
- `POST /auth/register` — {email, password} → 201 | 409 duplicate email | 422 invalid input
- `POST /auth/login` — {email, password, remember?} → 200 + session cookie | 401
- `POST /auth/logout` — → 204; deletes the session row
- `GET /auth/me` — → 200 current user | 401

## Services
- `PasswordHasher` — hash/verify with a bcrypt-class KDF (final library per `docs/stack/stack.md`)
- `SessionService` — create (24h sliding / 30d absolute per Q001), validate, revoke

## Validation
- Email: basic RFC format check; lowercased before uniqueness comparison
- Password: minimum 10 characters (PRD)
- All auth failures return generic messages — no user enumeration

## Risks
- Session table growth → expired-session cleanup job needed as a follow-up (out of this feature's scope)
- Timing attacks on login → constant-time hash verification

## Dependencies
- Web framework and database per `docs/stack/stack.md` (currently TBD; this design is stack-neutral)

## Implementation Notes
- Never log passwords or raw session tokens
- Session cookie: HttpOnly, Secure, SameSite=Lax

## Handoff
- **Inputs:** approved PRD, Q001 answer, ADR-001
- **Outputs:** this plan
- **Dependencies:** stack selections in `docs/stack/stack.md`
- **Outstanding Questions:** none
- **Next Agent:** Task Planner
