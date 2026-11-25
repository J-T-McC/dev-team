---
title: Check-ins
description: Scheduled Orca runs that keep work moving without you prompting, and cost nothing when there's nothing to do.
---

Check-ins are Orca automations that run a role on a schedule. They need the [Orca runtime](/dev-team/orca/). The seed config starts with three:

| Check-in | When | Role | Job |
|---|---|---|---|
| advance | every 30 minutes | orchestrator | for each feature in flight, answer "what's next?" and dispatch what's ready |
| stalled | hourly | orchestrator | find failed or stuck work, re-dispatch failed tasks, report sessions that aren't responding |
| groom | weekdays at 09:00 (off at first) | product-manager | triage new tickets assigned to you |

## Set them up

```
/dev-team:checkins
```

The command copies the seed config to `standards/checkins.md` and walks you through each check-in: keep it, change it, or turn it off. Then it makes Orca's automations match the file. Ask for changes in plain words: `/dev-team:checkins "add a nightly review check-in"`.

## What they cost

Each check-in has a trigger check that runs first. When nothing has changed it exits without starting a session, so an idle project costs nothing. The plugin ships three trigger checks, `has-work`, `stalled` and `new-tickets`, and any shell command works as one.

A check-in reuses its session, so it keeps its bearings instead of re-reading the project. That isn't free: each run sends the whole session again, and runs spaced further apart than the prompt cache lasts pay for it uncached. Keep check-in sessions small.

## Limits

Only one coordinator acts at a time. A check-in takes a lock at the start of its run, and an interactive coordinator takes the same lock before dispatching. A forgotten lock expires after 30 minutes.

A check-in never goes beyond the project's [autonomy level](/dev-team/autonomy/). Below `autonomous` it acts only where a gate is delegated, and flags anything that needs you (on the Owner board, if you use one). It never restarts a session that isn't responding. It reports it, and restarting is your call.
