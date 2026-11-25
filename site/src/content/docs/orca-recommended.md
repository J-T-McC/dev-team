---
title: Recommended setup
description: One choice that sets up an Orca team the way it ran through weeks of daily use, covering models, homes, git and PR flow, tests and safety rules.
---

The [Orca runtime](/dev-team/orca/) has plenty of settings, and much of what makes a team run smoothly is habits nobody writes down until something goes wrong. The recommended setup writes those habits down. It's the configuration that held up through weeks of daily use on a Claude Max plan, and you can take all of it in one step.

## Turn it on

Bootstrap offers it when you say you run Claude from Orca. In a project that's already set up, run:

```
/dev-team:orca recommended
```

Plain `/dev-team:orca` in a project without the Orca runtime asks whether you want this setup or just the runtime.

It shows every change as a diff and writes only what you approve:

- the Runtime line, with the models below;
- a `## Team setup` section at the end of the dev-team section in `CLAUDE.md`, which holds the rules;
- the line in your testing standard that runs the full suite for every task, changed to match.

Then it asks for the values only you know, one at a time: the full test command, the outside services the team may use, a spending cap, test accounts and numbers, and a remote for the workspace. A value you skip stays as `⟨…⟩`, and the team asks you before relying on it. If you don't have an [Owner board](/dev-team/board/) yet, it offers one too.

## Models

Every role runs on `claude-opus-5-5`. On the plan this was tuned on, it's the strongest model without a weekly cap of its own, so the whole team can run all week. The product-manager and principal-engineer get `claude-fable-5-2` as an [advisor](/dev-team/orca/#launch-settings) for hard questions and hard calls in their plans. The capped model goes where a wrong answer costs the most.

The roles that think and plan run at `xhigh` effort: the product-manager, designer, principal-engineer and reviewer, and your own coordinator session (start it with `claude --effort xhigh`). Developers run at `high`. These are the plugin's defaults, so the setup keeps them as they are; a [Role models](/dev-team/roles/#models-and-effort) line changes them for one role.

There's no fallback model. A fallback only helps if it still has capacity when the team model runs out, and on that plan the only capped model is the advisor's. If your team model is the capped one, turn it round: `claude-fable-5-2` as the team model and `claude-opus-5-5` as the fallback. Plans change, so check yours.

Peers never move to a smaller model to save usage. The team saves it by keeping fewer peers awake, reading less and running only the tests that matter.

## What changes from the defaults

Most of the setup is how the plugin already works: a fresh session for every task, the friction log, the way questions reach you. These parts differ:

| Area | Default | Recommended setup |
|---|---|---|
| Homes | product, designer, architect, a reviewer, and developers the coordinator adds as needed | a second reviewer and four developers; a new home needs your yes |
| Worktrees | one per feature, and one per parallel stream | one per home, named after it |
| Branches | parallel streams merge into a feature branch | a new branch from the default branch for every task, one PR per ticket to start |
| Reviews | in the feature's worktree | read-only: the reviewer fetches and diffs, and tests the reviewed commit in its own worktree |
| PRs | no rule | drafts while building, ready only after the reviewer approves, and peers never merge |
| Tests | the full suite for every task | only what changed while working, related suites at the end, the full suite when the coordinator says |
| Outside services | blocked or capped for each task | tests never call paid services, new services and installs need your yes, and production is read only when an action depends on it |
| Workspace | committed with the code | its own repository, pushed so other machines get the specs |

The test rules are rules, not a lock. Nothing blocks a full run; the coordinator's spec says when one happens.

If your workspace is committed with the code, the setup leaves the workspace rule out and keeps your choice.

## Changing it

Every value is yours to change afterwards: edit the Runtime line or the rule in Team setup. After a model change, `peer switch` moves the live peers over in the same turn. `/dev-team:orca advisor off` and similar requests make one change at a time.

When the plugin adds a rule to the setup later, [`/dev-team:sync`](/dev-team/updating/) reports it, and you choose whether to take it.

The reason for each value is in [`workflow/orca-recommended.md`](https://github.com/J-T-McC/dev-team/blob/main/workflow/orca-recommended.md), and the exact text the command writes is [`seeds/orca-recommended.md`](https://github.com/J-T-McC/dev-team/blob/main/seeds/orca-recommended.md).
