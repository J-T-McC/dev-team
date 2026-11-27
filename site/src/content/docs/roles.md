---
title: Roles
description: The six roles, what each one owns, and how to choose their models.
---

A role is a set of rules, not a separate program: a skill, `dev-team:<role>`, and for the five working roles an agent that loads it. A role runs in your conversation unless its agent pays for itself, such as for parallel work. Every role has your full toolset and checks your project's own skills (a `laravel` skill, say) before deciding or building. No role does another's job.

| Role | What it does |
|---|---|
| orchestrator | routes work between phases, checks gates and keeps `status.md`; ask it "what's next?" |
| product-manager | owns requirements: briefs and PRDs, whether a feature has UI, answers to requirement questions, design approval, and the backlog's order |
| designer | UI work only: one committed concept, mockups of the key screens, and a spec of flows, states, components, interactions and accessibility |
| principal-engineer | owns technical design: the plan, ADRs for significant decisions, and the task list |
| senior-developer | builds one task at a time, with tests, and takes fast-path bugs and chores |
| reviewer | the independent check: compares the change with the acceptance criteria, plan, design spec and standards, rates each finding by severity, and recommends a decision |

A review always runs in a fresh context, never in the conversation that wrote the code. Under the [Orca runtime](/dev-team/orca/), the orchestrator is your own session, called the coordinator. With a design tool connected through MCP (Figma, Penpot or similar, named in `standards/design.md`), the designer builds mockups there, on your existing components. Otherwise they're HTML files.

## Models and effort

The plugin pins no model. Roles use the conversation's model inline, your default subagent model as agents, and the project's Team model under Orca. Default effort:

| Role | Effort |
|---|---|
| product-manager, designer, principal-engineer, reviewer | `xhigh` |
| senior-developer | `high` |
| orchestrator (your session) | start it with `claude --effort xhigh` |

Override any role with one line in `CLAUDE.md`:

```
- **Role models:** designer: opus/high; senior-developer: sonnet; reviewer: high
```

Each entry is `<role>: <model>[/<effort>]` or `<role>: <effort>`, and roles left out keep their defaults. A model is an alias (`opus`, `sonnet`, `haiku`), or under Orca an exact id such as `claude-opus-5-5`. The line applies when a role runs as an agent or Orca peer, not inline.
