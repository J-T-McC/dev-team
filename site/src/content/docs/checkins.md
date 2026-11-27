---
title: Check-ins
description: Scheduled Orca runs that keep work moving without you prompting, and cost nothing when there's nothing to do.
---

Check-ins are Orca automations that run a role on a schedule, so work keeps moving while you're away. They need the [Orca runtime](/dev-team/orca/). Three come set up:

| Check-in | When | Role | Job |
|---|---|---|---|
| advance | every 30 minutes | orchestrator | dispatches whatever is ready in each feature in flight |
| stalled | hourly | orchestrator | re-dispatches failed tasks, reports sessions that aren't responding |
| groom | weekdays at 09:00 (off at first; hourly when the team [works through tickets](/dev-team/autonomy/#what-the-team-works-on)) | product-manager | triages new tickets assigned to you |

## Set them up

```
/dev-team:checkins
```

It copies the seed config to `standards/checkins.md`, lets you keep, change or turn off each check-in, and makes Orca's automations match. Ask for changes in plain words: `/dev-team:checkins "add a nightly review check-in"`.

## Cost and limits

A trigger check runs first and exits without starting a session when nothing has changed, so an idle project costs nothing. Any shell command can be a trigger. Each check-in reuses its session, though, and each run sends that whole session again, uncached when runs are further apart than the prompt cache lasts. Keep check-in sessions small.

Check-ins and your own session share a lock, so only one coordinator acts at a time. While your coordinator's `peer watch` runs it holds the lock, so check-ins wait until that session ends. A forgotten lock expires after 30 minutes. A check-in never goes beyond your [autonomy level](/dev-team/autonomy/): below `autonomous` it acts only where a gate is delegated, and flags the rest for you. It reports a session that isn't responding but never restarts it.

Full rules: [workflow/orca.md](https://github.com/J-T-McC/dev-team/blob/main/workflow/orca.md#check-ins-optional).
