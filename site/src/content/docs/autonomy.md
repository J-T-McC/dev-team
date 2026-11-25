---
title: Autonomy
description: Choose how involved you are, from signing every gate to keeping only the floor.
---

One line in the project's `CLAUDE.md` sets how much the team decides without you:

```
- **Autonomy:** standard
```

No line means `standard`. You can change it whenever you like. A change applies from the next gate and never reopens one already approved.

| Gate | supervised | standard | autonomous |
|---|---|---|---|
| PRD, or a brief that changes scope | ✋ you | ✋ you | ✅ product-manager, listing the gaps it filled under Assumptions |
| Design spec | ✋ you | ✅ product-manager | ✅ product-manager |
| Plan and task breakdown | ✋ you | ✅ principal-engineer | ✅ principal-engineer |
| Major decision | ✋ you | ✋ you | ✅ the role that owns it, except the floor |
| Each finished task | ✋ you, before the next starts | | |
| Requirement question | ✋ you (the product-manager drafts the answer) | ✅ product-manager | ✅ product-manager |
| Release | ✋ you | ✋ you | ✅ orchestrator, on an approving review |

## The floor

Some decisions stay with you at every level:

- Irreversible or destructive changes, including data-model changes that affect existing data.
- Security-sensitive surfaces: auth, permissions, secrets, personal data.
- Spending money.
- Whatever leaves the repository, such as a deploy, a publish, or a message to someone.
- Recording you or your surroundings through a microphone, camera or screen. Roles use fake devices by default, and a real recording needs your go for that one recording (what, where, and for how long).

A release means Done in `status.md`. It never means a deploy. Writes to a ticket system that your config allows, and writes to the Owner board, were approved when you turned those on, so they don't count as floor actions.

## Holding or handing over gates

Add the gates you want to keep: `Autonomy: autonomous; Owner keeps: PRD, release`. Handing over the floor too takes `Owner waives: floor`, written out in full. Nothing else implies it.

## Auditing what was decided

An approval made because of the level is recorded as `Approved by: <role> (autonomy: <level>)` in the artifact and in `status.md`. When a feature reaches Done at any level below `supervised`, the orchestrator's report lists every decision you didn't sign for that feature: the assumptions a brief or PRD filled in, major decisions a role made, and the gates the level delegated.

Autonomy never removes a gate, the independent review or a role boundary. It only changes who signs, and with fewer checkpoints the roles check their own work harder ([Team rules](/dev-team/team-rules/#assume-mistakes)).
