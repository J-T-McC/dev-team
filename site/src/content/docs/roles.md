---
title: Roles
description: The six roles, what each one owns, and how to choose their models.
---

A role is a set of rules, not a separate program. Each has a skill, `dev-team:<role>`, and the five working roles also have an agent that loads the same skill. No role does another role's job, and every role works with your full toolset: agents pin no tools, and each role checks your project's own skills (a `laravel` skill, say) before deciding or building.

## orchestrator

Routes work between phases, checks gates, and keeps `status.md`. It owns no document of its own. Ask it "what's next?". Under the [Orca runtime](/dev-team/orca/) the orchestrator is your own session, called the coordinator, and it does no hands-on work at all.

## product-manager

Owns requirements. It writes briefs and PRDs with testable acceptance criteria, decides whether a feature has UI (the PRD's UX Direction section), answers requirement questions on your behalf, approves design specs, and keeps the backlog in order.

## designer

Runs for UI work only. It turns the UX Direction into a design with one committed concept, mockups of the key screens, and a spec of the flows, states, components, interactions and accessibility. With a design tool connected through MCP (Figma, Penpot or similar, named in `standards/design.md`) it builds the mockups there, on your existing components. Otherwise mockups are self-contained HTML in the feature folder.

## principal-engineer

Owns technical design: the plan, ADRs for significant decisions, and the task breakdown. Tasks live in a `tasks/` folder with a small index and one file per task, so a developer session loads only the task it's on, never the whole plan. It certifies its own plans and brings you only the major decision inside one, not the plan.

## senior-developer

Builds one task at a time, with tests, and writes completion notes in the task file. It also takes fast-path bugs and chores.

## reviewer

The independent check. It compares the change with the acceptance criteria, the plan, the design spec and the standards, classifies each finding by severity, and recommends a decision. Reviews at the light tier check the criteria and tests; standard and deep go further. A review always runs in a fresh context.

## Models and effort

The plugin pins no model. Roles run on whatever you run: the conversation's model when inline, your default subagent model for agents, and the project's Team model under Orca. Each role has a default effort:

| Role | Effort |
|---|---|
| product-manager, designer, principal-engineer, reviewer | `xhigh` |
| senior-developer | `high` |
| orchestrator (your session) | start it with `claude --effort xhigh` |

Override any role with one line in `CLAUDE.md`:

```
- **Role models:** designer: opus/high; senior-developer: sonnet; reviewer: high
```

Each entry is `<role>: <model>[/<effort>]` or `<role>: <effort>`, and roles left out keep their defaults. A model is an alias (`opus`, `sonnet`, `haiku`), or under Orca an exact id such as `claude-opus-5-5`. The line applies whenever a role's agent or Orca peer starts. A role run inline uses the conversation's model, so when the project pins a different one for a role, a full phase of that role is a reason to run it as an agent. Quick questions stay inline.
