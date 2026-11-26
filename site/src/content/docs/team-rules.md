---
title: Team rules
description: How the roles ask questions, check their work, back up their claims, talk to you, and learn from what goes wrong.
---

These rules apply to every role, at every autonomy level.

## Questions go to the owner

A role missing some information looks in a fixed order. It searches the workspace, then past decisions (ADRs and answered questions), then asks the role that owns the answer, and only then asks you. It never invents an answer.

A question is a document: `questions/q001-session-lifetime.md` in the feature folder, listed under Outstanding Questions in the artifact that's waiting on it. The owner writes the answer into the same file. Only the item that needs the answer pauses.

| Topic | Who answers |
|---|---|
| requirements, scope, priorities, UX direction | product-manager |
| screens, states, components, interactions | designer |
| architecture, technology, task scope and order | principal-engineer |
| implementation detail | senior-developer |
| process, routing, status | orchestrator |
| new business decisions, major decisions, releases, anything unowned | you |

Nobody skips the chain. A developer with a requirement question asks the product-manager, who comes to you if it has to.

## Assume mistakes

Every agent makes mistakes, and long sessions drift from their task. So each role treats its own output and every input as possibly wrong.

Before handing off, a role re-reads the assignment from disk and checks its output against each item: criteria claimed without evidence, work beyond what was asked, a leftover TODO, a contradiction with an upstream document, a test that would still pass if the code were wrong. What it couldn't verify, it says. When work arrives, a role questions anything that smells: untestable criteria, a task that conflicts with the code or the plan, a missing approval. Questioning is expected. Deciding stays with the owner.

A role that ends mid-task commits what's done and leaves a short hand-over note (done, state, what's left) for the next session. It closes what it starts (emulators, dev servers, containers, browser windows, test data) as soon as the step that needed it is done, not at the end of the task. And it stops at what it can't do. Missing access or a step that needs a person marks the work blocked on you, with the exact ask. It never fakes the step.

## Evidence

A claim about how existing code behaves names the file and line it came from. A test helper or factory is named only after someone opened it, and a claim nobody checked is written as an assumption for the next role to verify.

Nothing goes into scope without proof that it happens: a reproduction, a log, or a code path a real user action reaches. Planning roles propose the smallest thing that does the job. An extra (a dashboard, a kill switch, a new system) appears as one optional line with its cost.

Paid services and other third parties get the same care. A task that doesn't need one runs with outbound calls blocked, and proves the block works first. A task that does need one carries a request cap, enforced by a counter. Both report how many requests they actually made, and paid jobs run once or twice, on your go.

## Talking to you

Whoever reports to you answers you first, before any other work. Real decisions (product, money, real accounts or people, production) come to you; gaps in tooling are reported as what's missing; agent work is done, not asked about.

Questions stand alone. They say what a person sees today, what the choice changes, and what the team recommends, in plain words, with internal numbers as references only. Questions come in the chat, never in a pop-up dialog. A reply that leaves anything open ends with a numbered **Waiting on you** list, asked again until each item is answered.

Your words travel verbatim. When the orchestrator passes your answer to a role, it quotes you exactly and marks its own interpretation separately. When a check needs your hands (a device, an account, a physical step), you get exact steps: what to do, for how long, and what to send back.

## Plain language

Every document, note and commit message uses short, plain English: say what was done or what's needed, then stop. Code comments explain only what the code can't, such as the reason for a non-obvious choice. No narration, no history comments, no commented-out code.

## The friction log

Any role that's slowed down or sent the wrong way logs it in `friction-log.md`, in the same turn. That covers wrong or stale instructions, slow or broken tooling, token burns, a mistake that keeps coming back, and any time you have to stop work to correct it. Every report ends with one line: `Friction: none`, or what was logged.

Between features the orchestrator picks the entry that stands out (the one that keeps repeating, or costs the most) and changes the workflow so it stops: a project rule, a template, a helper script. Changes to files everyone's agents load, such as `CLAUDE.md`, come to you first. Token burns are measured with `/dev-team:audit`, which records each run in the log ([what it checks](/dev-team/costs/#the-audit)).

Full rules: [handoffs](https://github.com/J-T-McC/dev-team/blob/main/workflow/handoffs.md), [communication](https://github.com/J-T-McC/dev-team/blob/main/workflow/communication.md), [friction](https://github.com/J-T-McC/dev-team/blob/main/workflow/friction.md).
