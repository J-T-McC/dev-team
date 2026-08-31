> **Example artifact** — fictional; in a real project this lives at the `docs/` path its naming implies.

# PRD: User Authentication

- **Status:** Approved
- **Author:** Product Manager
- **Approved by / date:** Project Owner / 2026-07-28

## Feature
Email-and-password authentication with persistent sessions. API-first: endpoints only — any login/registration UI ships as its own PRD (with UX Direction), so this feature skips the Designer phase.

## Problem
The product has no concept of identity. Users cannot save work or access personalized data, and the API cannot restrict access.

## Goals
- Users can create an account and sign in with email and password
- Sessions persist so users are not asked to sign in on every visit
- Signed-out users cannot access protected resources

## Users
- **Visitor** — no account; wants to register
- **Member** — has an account; wants to sign in and out securely

## User Stories
- As a visitor, I want to register with email and password so that I can create an account.
- As a member, I want to log in so that I can access my data.
- As a member, I want to stay signed in ("remember me") so that I don't re-authenticate daily.
- As a member, I want to log out so that my session ends on shared devices.

## Acceptance Criteria
- Registration rejects duplicate emails and passwords under 10 characters
- A registered user can log in and receives a session valid for 24 hours, or 30 days with "remember me" (per Q001)
- Logout immediately invalidates the session
- Protected endpoints return 401 without a valid session
- Passwords are never stored or logged in plain text

## Out of Scope
- OAuth / social login
- Multi-factor authentication
- Password reset (will be its own PRD)
- Login/registration UI (its own PRD, with UX Direction)

## Open Questions
- ~~Q001: session lifetime and remember-me behavior~~ — answered; see `docs/questions/user-authentication-q001.md`

## Handoff
- **Inputs:** Product Owner feature request (2026-07-27)
- **Outputs:** this PRD
- **Dependencies:** none
- **Outstanding Questions:** none
- **Next Agent:** Principal Engineer
