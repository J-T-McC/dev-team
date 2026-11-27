---
title: Team rules
description: How the roles ask questions, check their work, back up their claims, talk to you, and learn from what goes wrong.
---

These rules apply to every role, at every autonomy level. Everything the team writes, from documents to commit messages, is short and plain, and code comments explain only what the code can't, such as the reason for a non-obvious choice.

## Questions go to the owner

A role missing information checks the workspace and past decisions, then asks the role that owns the answer, and only then asks you. It never invents an answer. Each question is its own file in the feature folder, and only the work waiting on it pauses.

| Topic | Who answers |
|---|---|
| requirements, scope, priorities, UX direction | product-manager |
| screens, states, components, interactions | designer |
| architecture, technology, task scope and order | principal-engineer |
| implementation detail | senior-developer |
| process, routing, status | orchestrator |
| new business decisions, major decisions, releases, anything unowned | you |

## Assume mistakes

Every agent makes mistakes, and long sessions drift, so each role treats its own output and every input as possibly wrong. Before handing off, it checks its work against the assignment and says what it couldn't verify. It questions incoming work that looks off, though deciding stays with the owner. And it never fakes a step it can't do: missing access, or a step that needs a person, marks the work blocked on you with the exact ask.

## Evidence

A claim about existing code names the file and line it came from, and an unchecked claim is written as an assumption. Nothing goes into scope without proof that it happens, such as a reproduction or a log. Plans propose the smallest thing that does the job, with any extra as one optional line and its cost.

A task that doesn't need an outside service runs with outbound calls blocked, and one that does carries a request cap. Paid jobs run once or twice, on your go.

## Talking to you

Whoever reports to you answers you first. Real decisions (product, money, real accounts or people, production) come to you, and work agents can do is done, not asked about. Questions come in the chat, never a pop-up, and stand alone: what a person sees today, what the choice changes, and what the team recommends.

A reply that leaves anything open ends with a numbered **Waiting on you** list, asked again until each item is answered. Your answers reach other roles word for word. When a check needs your hands, you get exact steps.

## The friction log

Any role that's slowed down or sent the wrong way logs it in `friction-log.md`, and every report ends with `Friction: none` or what was logged. Between features the orchestrator changes the workflow to stop the entry that stands out, and brings you any change to files every agent loads, such as `CLAUDE.md`, first. Token burns are measured with `/dev-team:audit` ([what it checks](/dev-team/costs/#the-audit)).

Full rules: [handoffs](https://github.com/J-T-McC/dev-team/blob/main/workflow/handoffs.md), [communication](https://github.com/J-T-McC/dev-team/blob/main/workflow/communication.md), [friction](https://github.com/J-T-McC/dev-team/blob/main/workflow/friction.md).
