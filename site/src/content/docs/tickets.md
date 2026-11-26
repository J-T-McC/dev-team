---
title: Ticket systems
description: Take work from Linear, Jira, GitHub or another tracker, and write back only what you allow.
---

The team can take its work from a ticket system: Linear, Jira, GitHub Issues and Projects, or any tracker with an MCP server. It can also go through Orca's built-in Linear client or the `gh` CLI, which need no MCP server. It's off until you turn it on.

The tracker is where work comes from and where outcomes are recorded. The team still works and talks through the workspace, because documents are cheaper than round trips to a tracker.

## Set it up

```
/dev-team:tickets
```

The command finds the connections available in your session and asks, one topic at a time, about the system, the workspace and team (or repo and Project), the query that finds your work, how ticket types route, the status changes to sync, and what may be written back. It runs the query once, read-only, so you can see what it matches, and writes the config to `standards/tickets.md` once you approve. Change it later the same way, in plain words: `/dev-team:tickets "stop posting release comments"`. Each change is logged in the config's Tuning log.

## How the team uses it

A ticket is read once, when work starts. The role that takes it copies what it needs into its own document and records the ticket ID there and in the `status.md` row. Commits carry it too (`feat(auth): ENG-123 add login timeout`), so anyone reading the history can find the ticket; dev-team's own task IDs go in a commit only when there's no ticket. From then on the documents are the truth. A ticket change that alters requirements is a requirement change, and goes back to the product-manager.

Only the orchestrator and the product-manager write to the tracker, and only what the config's Elevation section allows: a release comment, say, or tickets for high-priority bugs. Findings, questions and task notes never go out. Every other role turns a finding worth a ticket into a backlog item.

If the tracker is down or a write fails, work carries on from the documents, the row notes `ticket sync pending`, and the write is retried at the next step. A ticket never blocks a gate.

## Keep projects apart

One connection often serves every project on the machine: Orca's Linear client, `gh`'s active account, a user-scope MCP server, a claude.ai connector. So the config's **Scope** (workspace and team, or repo and Project) is the fence. Every query names it, and the team refuses any ticket outside it, even one you hand over.

If several projects on one machine must never reach each other's tracker, use an MCP server added at local or project scope and logged in to that project's workspace only. Then the fence is the credential, not a rule.

Full rules: [workflow/tickets.md](https://github.com/J-T-McC/dev-team/blob/main/workflow/tickets.md).
