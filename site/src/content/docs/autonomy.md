---
title: Autonomy
description: Choose how involved you are, from signing every gate to keeping only the floor.
---

One line in the project's `CLAUDE.md` sets how much the team decides without you:

```
- **Autonomy:** standard
```

No line means `standard`. A change applies from the next gate and never reopens one already approved.

| Gate | supervised | standard | autonomous |
|---|---|---|---|
| PRD, or a brief that changes scope | ✋ you | ✋ you | ✅ product-manager, listing what it assumed |
| Design spec | ✋ you | ✅ product-manager | ✅ product-manager |
| Plan and tasks | ✋ you | ✅ principal-engineer | ✅ principal-engineer |
| Major decision | ✋ you | ✋ you | ✅ the role that owns it, except the floor |
| Each finished task | ✋ you, before the next starts | | |
| Requirement question | ✋ you, on the product-manager's draft | ✅ product-manager | ✅ product-manager |
| A standard or stack choice in a plan or design | ✋ you | ✋ you | ✅ whoever signs that plan or design |
| Release | ✋ you | ✋ you | ✅ orchestrator, after an approving review |

To keep some gates anyway, name them: `Autonomy: autonomous; Owner keeps: PRD, release`.

## The floor

Some decisions stay with you at every level:

- irreversible or destructive changes, including data-model changes that affect existing data
- security-sensitive surfaces: auth, permissions, secrets, personal data
- spending money
- anything that leaves the repository, such as a deploy, a publish, or a message to someone
- recording you or your surroundings by microphone, camera or screen (roles use fake devices, and each real recording needs your go)

A release means Done in `status.md`, not a deploy. Ticket and Owner board writes you've turned on aren't floor actions. Handing over the floor itself takes `Owner waives: floor`, written out in full. Nothing else implies it.

## Auditing what was decided

An approval the level hands to a role is recorded as `Approved by: <role> (autonomy: <level>)`. When a feature is done, the orchestrator's report lists every decision in it you didn't sign.

Autonomy only changes who signs. Every gate, the independent review and the role boundaries stay, and with fewer checkpoints the roles [check their own work](/dev-team/team-rules/#assume-mistakes) harder.

## What the team works on

A second line, `Next work`, decides whether the team starts new work without being asked. Setup asks it.

| Setting | The team starts next | It stops |
|---|---|---|
| `owner` (the default) | only what you hand it | after each piece of work |
| `product` ("build it for me") | the next feature of the product you described | when all are done, and tells you what it built and would do next |
| `tickets` | the next ticket your ticket search returns | when nothing is new; a new ticket starts it again |
| `steered` | the product manager's pick from your tickets and backlog: features, cleanup and bugs | when nothing above low priority is left, or you say stop |

The team never takes a ticket your search doesn't return, so the search sets how much it may choose: tickets assigned to the team, a label, or a whole team's queue. "Build it for me" builds only what you described; ideas on the way go to the backlog. The `steered` mix is yours to tune in `standards/planning.md` under Steering: by default, bugs that hurt users first, then about one cleanup item for every two features.

Each item still passes every gate your level keeps, and the [floor](#the-floor) stays yours. Under Orca, [check-ins](/dev-team/checkins/) pick up new tickets on their own; otherwise the team keeps going while its conversation runs. To stop, say so or set `Next work: owner`: work in flight finishes and nothing new starts.

Full rules: [workflow/handoffs.md](https://github.com/J-T-McC/dev-team/blob/main/workflow/handoffs.md#next-work).
