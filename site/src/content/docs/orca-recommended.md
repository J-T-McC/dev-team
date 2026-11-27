---
title: Recommended setup
description: One choice that sets up an Orca team the way it ran through weeks of daily use, covering models, homes, git and PR flow, tests and safety rules.
---

The recommended setup is the [Orca](/dev-team/orca/) configuration that held up through weeks of daily use on a Claude Max plan, taken in one step.

## Turn it on

Setup offers it when it finds Orca. In a project that's already set up, ask for it, or run:

```
/dev-team:orca recommended [small | medium | large]
```

Every home draws on your usage limits, so the team's size follows your plan:

| Size | Plan | Homes |
|---|---|---|
| small | Pro | one each: product, designer, architect, reviewer, developer |
| medium | Max 5x | small, plus a second developer |
| large | Max 20x | two reviewers and four developers |

Setup suggests a size from your plan. On Pro it suggests running the team in the conversation instead, because every Orca task starts a fresh session and Pro's limits run out fast.

It shows each change as a diff and writes only what you approve: the Runtime line, a `## Team setup` section of rules in `CLAUDE.md`, and your testing standard's full-suite rule, changed to match. Then it asks for what only you know: the full test command, the outside services the team may use, a spending cap, test accounts and a workspace remote. Anything you skip stays as `⟨…⟩`, and the team asks you before relying on it.

## Models

Every role runs on `claude-opus-5-5`, the strongest model without a weekly cap of its own on the plan this was tuned on, so the team can run all week. The product-manager and principal-engineer get `claude-fable-5-2` as an [advisor](/dev-team/orca/#launch-settings) for hard questions and hard calls, where a wrong answer costs most. Effort stays at the plugin's [defaults](/dev-team/roles/#models-and-effort).

There's no fallback model, since on that plan the only capped model is the advisor's. If your team model is the capped one, swap them: `claude-fable-5-2` as the team model and `claude-opus-5-5` as the fallback. Plans change, so check yours.

Peers never drop to a smaller model to save usage. The team saves it by keeping fewer peers awake, reading less and running only the tests that matter.

## What changes from the defaults

Only these parts differ from how the plugin works by default:

- Each home has its own worktree, and a new home needs your yes.
- Developers start each task on a new branch from the default branch, one PR per ticket to start. The product manager, designer and lead engineer never branch, and their worktrees move to the latest default branch before each task.
- The reviewer is read-only and tests the reviewed commit in its own worktree.
- PRs stay drafts until the reviewer approves. Peers never merge.
- While working, peers test only what changed, then the related suites. The full suite runs when the coordinator says.
- Tests never call paid services, new services and installs need your yes unless the stack names them, and production is read only when an action depends on it.
- The workspace is its own repository, pushed so other machines get the specs, unless yours is already committed with the code.

## Changing it

Edit the Runtime line or a rule in Team setup, or ask: `/dev-team:orca advisor off` makes one change at a time. After a model change, `peer switch` moves the live peers over. When the plugin adds a rule later, [`/dev-team:sync`](/dev-team/updating/) reports it and you choose whether to take it.

The reasons are in [`workflow/orca-recommended.md`](https://github.com/J-T-McC/dev-team/blob/main/workflow/orca-recommended.md), and the exact text the command writes is in [`seeds/orca-recommended.md`](https://github.com/J-T-McC/dev-team/blob/main/seeds/orca-recommended.md).
