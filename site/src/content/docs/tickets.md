---
title: Ticket systems
description: Take work from Linear, Jira, GitHub or another tracker, and write back only what you allow.
---

The team can take its work from Linear, Jira, GitHub Issues and Projects, or any tracker with an MCP server. Orca's built-in Linear client and the `gh` CLI work without one. It's off until you turn it on.

## Set it up

```
/dev-team:tickets
```

It finds the connections in your session, then asks about the tracker, the query that finds your work, and what may be written back. It runs the query once, read-only, to show you what it matches, and saves the config to `standards/tickets.md` once you approve. To change it later, say what you want: `/dev-team:tickets "stop posting release comments"`.

## How the team uses it

A ticket is read once, when work starts, and from then on the team works from its own documents. A ticket change that alters requirements goes back to the product manager. Commits carry the ticket ID: `feat(auth): ENG-123 add login timeout`.

Only the orchestrator and the product manager write to the tracker, and only what the config's Elevation section allows: a release comment, say, or tickets for high-priority bugs. Findings, questions and task notes never go out. If the tracker is down, work carries on and the write is retried later. A ticket never blocks a gate.

## Keep projects apart

One connection, such as `gh`'s active account or a user-scope MCP server, often serves every project on the machine. The config's Scope (workspace and team, or repo and Project) fences it in: every query names it, and the team refuses tickets outside it, even ones you hand over.

If projects must never reach each other's tracker, give each one an MCP server added at local or project scope, logged in to that project's workspace only. Then the credential is the fence, not a rule.

Full rules: [workflow/tickets.md](https://github.com/J-T-McC/dev-team/blob/main/workflow/tickets.md).
