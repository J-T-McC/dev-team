> **Example artifact** — fictional feature demonstrating the workflow. Delete when starting a real project.

# Q001: Session lifetime and "remember me" behavior

- **Feature:** user-authentication
- **Requested By:** Principal Engineer
- **Directed To:** Product Manager
- **Required By:** 2026-07-29 — blocks technical plan §Data Model and §Services
- **Priority:** High
- **Status:** Answered

## Question
What is the session lifetime, and how does "remember me" change it?

## Context
The PRD requires persistent sessions but states no durations. Session storage design (`docs/architecture/adr-001-session-storage.md`) depends on expiry semantics.

## Answer
- **Answered By:** Product Manager / 2026-07-28

Default session: 24 hours, sliding from last activity. "Remember me": 30 days, absolute (non-sliding). PRD acceptance criteria updated to match; PRD re-approved 2026-07-28.
