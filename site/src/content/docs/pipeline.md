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

✋ marks a gate only you sign. ✅ marks one a named role signs for you. Your [autonomy level](/dev-team/autonomy/) moves gates from one kind to the other.

## Three paths

Most work needs less than that. The team decides how much, one piece of work at a time:

| Path | Typical work | Phases |
|---|---|---|
| Full | a new product surface, several stakeholders, unclear scope | PRD → design (UI) → plan and ADRs → tasks → build → review |
| Brief | most ticket work | brief → [discovery] → [design] → [plan] → tasks → build → review |
| Fast | bugs and chores | the fix, with a record |

The product-manager triages each request. When the request (usually a ticket) already says what's wanted, it writes a **brief**: a link to the request, testable acceptance criteria, what's out of scope, and the planned path. When it doesn't, it writes a **PRD**. The acceptance criteria are never optional, since review needs something to check against.

When the work reaches the next role, that role decides whether its phase is needed. The designer runs only if the brief or PRD has a UX Direction section. The principal-engineer picks a full plan, tasks straight from the brief, or a single task, and writes an ADR only for a significant decision. Any role can call a time-boxed **discovery** when unknowns block a decision, and its findings update the path.

Paths grow. They never shrink quietly. A brief that turns out to be feature-sized becomes a PRD and picks up the phases it skipped, and dropping a phase already on the path needs the owning role's stated reason.

## Can agents do it at all?

Before sizing anything, the product-manager checks the request against the project's **Agent limits** (a list in `standards/planning.md`). Work agents can do goes ahead. Work that's partly theirs is split: agents do their part, and the steps that need a person become Owner tasks the path waits on. Work only a person can do gets no feature folder, just one row in `triage.md` with the reason, so nobody triages it again, and you're told.

## The fast path

Small work goes straight to one role, with no gates. Bugs and chores (broken behavior, typos, config, dependency bumps) go to the senior-developer: the fix, its tests, and a record in `fixes/<date>-<slug>.md`. A doc correction goes to the role that owns the doc.

That's safe because fast-path work only puts things back the way they were meant to be. It restores intended behavior or makes a document match reality. It never changes an approved decision, requirement, public interface, data model or ADR, and a fix that turns out to be feature-shaped is handed to the product-manager.

## What needs you

At the default level you're asked for three things. You approve PRDs (and briefs that change scope), you approve releases, and you decide **major decisions** wherever they come up:

- new dependencies, and any change to the stack
- data-model changes that affect existing data, and anything irreversible
- security-sensitive surfaces such as auth, permissions, secrets or personal data
- changes to the scope of an approved PRD
- whatever a role proposes as an ADR

Everything else is delegated. Each approval is recorded, as `Approved by: <role>`, in the artifact and in `status.md`, so you can audit it later.

## Gates and rework

A role refuses work whose gate hasn't passed. An approval covers one commit, not a branch: anything pushed after a review gets a review of that diff before release.

When something turns out wrong, the team fixes the document that was wrong first (the brief, then the design, then the plan) and then the same PRs. It never stacks patch PRs on top. A review Blocker returns the work to the senior-developer. A plan defect sends it to the principal-engineer, and the plan is certified again. A design defect sends it to the designer, and the product-manager approves the design again.

## Later is not lost

Deferred work (scope cuts, tech debt, known bugs nobody is fixing yet) becomes a backlog item: a row in `backlog/index.md` and one file per item. Any role can file one. The product-manager sets the order and promotes items, a feature into a path, a bug or debt item into the fast path. Nothing sits in the backlog and `status.md` at once.

## Where the work runs

By default every role runs in your conversation. Claude invokes the role's skill, and the role's boundaries and gates apply exactly as if a separate agent had done the work, without the startup cost. A role's agent is started only when it pays for itself: for independent streams of work running at once, for pipeline reviews (always in the reviewer agent, so code is never reviewed by the conversation that wrote it), or to hand a big phase to a fresh context when the conversation has grown long.

The [Orca runtime](/dev-team/orca/) is the alternative, with every role as its own long-lived session.

Full rules: [workflow/overview.md](https://github.com/J-T-McC/dev-team/blob/main/workflow/overview.md) and [workflow/handoffs.md](https://github.com/J-T-McC/dev-team/blob/main/workflow/handoffs.md).
