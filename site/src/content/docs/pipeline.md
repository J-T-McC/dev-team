---
title: Paths and gates
description: The full pipeline, the shorter paths through it, and the gates that keep work honest.
---

The full pipeline is the longest path a piece of work can take:

```
You (Product Owner)
  ↓  request
product-manager      PRD                       ✋ you approve
  ↓
designer (UI only)   design spec, mockups      ✅ the product-manager approves
  ↓
principal-engineer   plan, ADRs, task list     ✅ self-certified (✋ you, for a major decision)
  ↓
senior-developer     code and tests, per task
  ↓
reviewer             review                    ✋ you approve the release
  ↓
Done
```

✋ marks a gate only you sign. ✅ marks one a named role signs for you. Your [autonomy level](/dev-team/autonomy/) moves gates between the two.

## Three paths

Most work takes a shorter path, picked for each piece of work:

| Path | Typical work | Phases |
|---|---|---|
| Full | a new product surface, several stakeholders, unclear scope | PRD → design (UI) → plan and ADRs → tasks → build → review |
| Brief | most ticket work | brief → [discovery] → [design] → [plan] → tasks → build → review |
| Fast | bugs and chores | the fix, with a record |

When a request (usually a ticket) already says what's wanted, the product-manager writes a brief, with what's out of scope and the planned path. Otherwise it writes a PRD. Either way it sets testable acceptance criteria for review to check against.

Each later role decides whether its phase is needed, and any role can call a time-boxed discovery when unknowns block a decision. Paths grow but never shrink quietly. A brief that turns out feature-sized becomes a PRD, and dropping a phase needs the owning role's stated reason.

Deferred work (scope cuts, tech debt, known bugs) goes to the backlog, and the product-manager later promotes it into a path.

## Can agents do it at all?

The product-manager first checks each request against the Agent limits in `standards/planning.md`. Steps that need a person become Owner tasks the work waits on. Work only a person can do is logged in `triage.md`, and you're told.

## The fast path

Bugs and chores (broken behavior, typos, config, dependency bumps) go straight to the senior-developer: the fix, its tests, and a record in `fixes/`. Doc corrections go to the doc's owner.

No gate is needed, because the fix only restores what was intended. It never changes an approved decision, requirement, public interface, data model or ADR, and anything bigger goes to the product-manager.

## What needs you

At the default level you approve PRDs, briefs that change scope, and releases. You also make the major decisions:

- new dependencies, or any change to the stack
- data-model changes that affect existing data, and anything irreversible
- security-sensitive surfaces such as auth, permissions, secrets or personal data
- changes to the scope of an approved PRD
- whatever a role proposes as an ADR

Everything else is delegated. Each approval is recorded in the artifact and in `status.md`.

## Gates and rework

A role refuses work whose gate hasn't passed. An approval covers one commit, so anything pushed after a review gets its own review before release. When something turns out wrong, the team fixes the documents first, from the earliest one that was wrong, and that document's gate is signed again. Then it fixes the same PRs. It never stacks patch PRs on top.

Full rules: [workflow/overview.md](https://github.com/J-T-McC/dev-team/blob/main/workflow/overview.md) and [workflow/handoffs.md](https://github.com/J-T-McC/dev-team/blob/main/workflow/handoffs.md).
