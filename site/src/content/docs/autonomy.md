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
| A standard or stack choice a plan or design proposes | ✋ you | ✋ you | ✅ whoever signs that plan or design |
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

## What the team works on

Autonomy decides who signs. A second line, `Next work`, decides whether the team starts something new without being asked, and where it comes from. Setup asks it.

| Setting | The team starts next | It stops |
|---|---|---|
| `owner` (the default) | only what you hand it | after each piece of work |
| `product` ("build it for me") | the next feature of the product you described, in the order the product manager set when it split your description | when every one of those features is done; then you get what was built and what the team would do next |
| `tickets` | the next ticket your ticket search returns, in your ticket system's order | when there's nothing new; a new ticket starts it again |
| `steered` | what the product manager picks from your tickets and the backlog, mixing new features with cleanup and bugs | when nothing above low priority is left, or you say stop |

The team never takes a ticket your search doesn't return, so the search is how much it may choose: assigned to the team, a label, or a whole team's queue. "Build it for me" builds only what you described: ideas the team has on the way go to the backlog and don't make the run longer. The product manager's mix for `steered` is in `standards/planning.md` under Steering, yours to tune: bugs that hurt users first, then about one cleanup item for every two features.

Each item still passes every approval your autonomy level keeps, and the [floor](#the-floor) stays yours. With [check-ins](/dev-team/checkins/) under Orca, new tickets are picked up on their own; without them, the team keeps going while its conversation runs. To stop, say so, or set `Next work: owner`: what's in flight finishes, and nothing new starts. The rules are in [`workflow/handoffs.md`](https://github.com/J-T-McC/dev-team/blob/main/workflow/handoffs.md#next-work).
