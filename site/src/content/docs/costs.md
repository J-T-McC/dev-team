---
title: What it costs
description: Your project's setup decides most of what each session costs; the audit shows what's still expensive.
---

dev-team doesn't pick your stack, skills or tools. Every role runs on what your project already gives a Claude session, so a team is as lean, or as heavy, as the project it runs in.

## What every session starts with

This matters most when several roles run at once. Each agent, and under the [Orca runtime](/dev-team/orca/) each peer, starts with the project's whole context:

- every `CLAUDE.md` it reads, and the files those import;
- the description of every skill and plugin you have installed;
- each MCP server's instructions and tool list, and under Orca a separate copy of each server's process for every peer;
- whatever SessionStart hooks add, such as a memory plugin's recap.

One measured peer started at about 35k tokens, and most of that was a memory plugin's recap. Under Orca every task starts a fresh session, so that cost comes again with each task, for each peer.

Run `/context` in a new session in the project to see what every session starts with. Then trim what the roles don't use: keep `CLAUDE.md` to what every session needs, remove skills and plugins the project doesn't use, and turn off MCP servers no role needs (`/mcp`).

## The audit

That covers what a session starts with. What agents read during the work can cost more. In one measured week, a 95 KB plan was read whole 23 times, and a notes file with one heading for 51 entries could only ever be read whole. Once the team has worked for a week or so, run `/dev-team:audit`. It reads the project's session transcripts with a script and gives the coordinator a summary: the files that cost the most to read, whole and in part, who read them, and what every session loads. The coordinator then lists the bloat it found in one table (rules stated twice, retired rules, history inside rules, documents over the size limit or with no headings) with the expected saving for each. It applies only what you approve, never changes what a rule means, and records the run in the friction log. The orchestrator offers a new audit when the last one is about two weeks old.

The audit looks back over the last week of the team's sessions, or as many days as you give it (`/dev-team:audit 14` looks back two weeks). Those days are a sample of real use. The audit isn't looking for documents that grew. It works out what each file costs, which is its size times how often sessions loaded it:

- A document agents read during the work costs what its reads in those days came to. A big plan nobody opened costs nothing; a smaller one read whole for every task costs a lot.
- A file every session loads, such as `CLAUDE.md`, `CLAUDE.local.md` or the memory index, is measured as it is now, and the days give the number of sessions. A 45 KB `CLAUDE.md` is about 11k tokens, so across 200 sessions a week it comes to about 2.3M tokens. The prompt cache makes repeated loads cheaper, but every session still carries the file in its context.

Keeping documents from growing is the job of the [size rule and its hook](/dev-team/workspace/#small-files-on-purpose). The audit is the check that shows what is still expensive, and each run's friction-log entry lets the next run show whether costs went down.

## The plugin's own share

The plugin keeps its own share small. Roles run in your conversation unless there's a reason to start an agent, the descriptions it adds to every session are short, the coordinator reads summaries and document headers rather than transcripts, specs point to files instead of pasting them, and waiting on peers or CI spends nothing while it waits.

Install it per project (local scope, [Get started](/dev-team/getting-started/#install)), not for every project: a user-scope install loads its descriptions and hooks into every Claude Code session you start, in every project.
