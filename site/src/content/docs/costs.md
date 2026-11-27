---
title: What it costs
description: Your project's setup decides most of what each session costs; the audit shows what's still expensive.
---

Every role runs on what your project already gives a Claude session. So a team is as lean, or as heavy, as the project it runs in.

## What every session starts with

Each agent, and under the [Orca runtime](/dev-team/orca/) each peer, starts with the project's whole context:

- every `CLAUDE.md` it reads, and the files those import
- the description of every installed skill and plugin
- each MCP server's instructions and tool list (under Orca, each peer runs its own copy of every server)
- whatever SessionStart hooks add, such as a memory plugin's recap

One measured peer started at about 35k tokens, most of it a memory plugin's recap. Under Orca every task starts a fresh session, so you pay that again for every task.

To see yours, run `/context` in a new session. Then trim what the roles don't use: keep `CLAUDE.md` to what every session needs, remove unused skills and plugins, and turn off MCP servers no role needs (`/mcp`, or for Orca peers only, the [`Peer MCP:` setting](/dev-team/reference/settings/)).

The plugin itself adds little, and waiting on peers or CI costs nothing. Install it [per project](/dev-team/getting-started/#install) so it stays out of your other projects' sessions.

## Long sessions

Every call re-sends the whole session so far, so a session at 300k tokens pays about ten times what it paid at 30k for each step. When a session gets too long, Claude Code compacts it into a summary and carries on; under Orca the Peer size limit is meant to hand the task to a fresh session before that. Keep the limit below where Claude Code compacts, or it never fires. The audit shows both.

## The audit

What agents read during the work can cost more. In one measured week a 95 KB plan was read whole 23 times. After the team has worked for a week or so, run:

```
/dev-team:audit
```

It looks back over the last week of sessions (`/dev-team:audit 14` for two weeks). From each call's own usage it shows what each peer or role spent, how long its sessions ran, and where Claude Code compacted them, plus what every call carries: tool schemas and each MCP server, with whether anyone used it. It prices each file at its size times how often those sessions loaded it. A big plan nobody opened costs nothing. A 45 KB `CLAUDE.md` that every session loads is about 11k tokens each time, or about 2.3M across 200 sessions a week, though the prompt cache makes repeat loads cheaper.

You get one table of the bloat it found, such as rules stated twice or documents over the [size limit](/dev-team/workspace/#small-files-on-purpose), with the expected saving for each. It applies only what you approve and never changes what a rule means. When the last audit is about two weeks old, the orchestrator offers a new one.

Full rules: [commands/audit.md](https://github.com/J-T-McC/dev-team/blob/main/commands/audit.md).
