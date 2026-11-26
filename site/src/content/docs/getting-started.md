---
title: Get started
description: Install the plugin, set up a project, and start the first piece of work.
---

## Install

In Claude Code, inside your project:

```
/plugin marketplace add J-T-McC/dev-team
/plugin install dev-team@dev-team
```

On someone else's project ([guest mode](/dev-team/workspace/#guest-mode)), install it for yourself only by adding `--scope local` to the second command.

## Check what your project costs

dev-team doesn't pick your stack, skills or tools. Every role runs on what your project already gives a Claude session, so a team is as lean, or as heavy, as the project it runs in.

That matters most when several roles run at once. Each agent, and under the [Orca runtime](/dev-team/orca/) each peer, starts with the project's whole context:

- every `CLAUDE.md` it reads, and the files those import;
- the description of every skill and plugin you have installed;
- each MCP server's instructions and tool list, and under Orca a separate copy of each server's process for every peer;
- whatever SessionStart hooks add, such as a memory plugin's recap.

One measured peer started at about 35k tokens, and most of that was a memory plugin's recap. Under Orca every task starts a fresh session, so that cost comes again with each task, for each peer.

Run `/context` in a new session in the project to see what every session starts with. Then trim what the roles don't use: keep `CLAUDE.md` to what every session needs, remove skills and plugins the project doesn't use, and turn off MCP servers no role needs (`/mcp`).

That covers what a session starts with. What agents read during the work can cost more. In one measured week, a 95 KB plan was read whole 23 times, and a notes file with one heading for 51 entries could only ever be read whole. Once the team has worked for a week or so, run `/dev-team:audit`. It reads the project's session transcripts with a script and gives the coordinator a summary: the files that cost the most to read, whole and in part, who read them, and what every session loads. The coordinator then lists the bloat it found in one table (rules stated twice, retired rules, history inside rules, documents over the size limit or with no headings) with the expected saving for each. It applies only what you approve, never changes what a rule means, and records the run in the friction log. The orchestrator offers a new audit when the last one is about two weeks old.

The audit looks back over the last week of the team's sessions, or as many days as you give it (`/dev-team:audit 14` looks back two weeks). Those days are a sample of real use. The audit isn't looking for documents that grew. It works out what each file costs, which is its size times how often sessions loaded it:

- A document agents read during the work costs what its reads in those days came to. A big plan nobody opened costs nothing; a smaller one read whole for every task costs a lot.
- A file every session loads, such as `CLAUDE.md`, `CLAUDE.local.md` or the memory index, is measured as it is now, and the days give the number of sessions. A 45 KB `CLAUDE.md` is about 11k tokens, so across 200 sessions a week it comes to about 2.3M tokens. The prompt cache makes repeated loads cheaper, but every session still carries the file in its context.

Keeping documents from growing is the job of the [size rule and its hook](/dev-team/workspace/#small-files-on-purpose). The audit is the check that shows what is still expensive, and each run's friction-log entry lets the next run show whether costs went down.

The plugin keeps its own share small. Roles run in your conversation unless there's a reason to start an agent, the descriptions it adds to every session are short, the coordinator reads summaries and document headers rather than transcripts, specs point to files instead of pasting them, and waiting on peers or CI spends nothing while it waits.

## Set up the project

Ask Claude:

```
run the dev-team:bootstrap skill
```

Bootstrap asks three things first, one at a time:

1. Is this your project, or are you a guest? Guest mode is for a project whose team doesn't use dev-team. Nothing of dev-team shows up in their code, commits or PRs.
2. Is it new, or does it already have code and history? An existing codebase takes the adoption path below.
3. Where do the documents go? It asks about the workspace folder (default `docs`), the features folder, how feature folders are named, and whether the workspace is committed.

It then writes the dev-team section into `CLAUDE.md` (in guest mode, `CLAUDE.local.md`) and copies the seed files. Last come your preferences: how involved you want to be, whether to connect a ticket system, whether you run Claude from Orca (and if so, whether to take the [recommended setup](/dev-team/orca-recommended/)), whether you want the Owner board, and whether you design in a tool such as Figma or Penpot. Skip any of them. Each has its own command for later.

Before the first real work, fill in `stack/stack.md` and the files in `standards/` inside the workspace. Roles stop and ask while placeholders remain; they don't guess. Then commit what bootstrap made.

## Existing codebases

Most of what the standards ask is already answered by your code, so bootstrap reads it instead of quizzing you. The principal-engineer goes through the manifests, CI config, lint and test setup, a sample of source files and the commit history, then proposes the stack file and the coding and testing standards. Every line names the file it came from. Anything the repository doesn't answer stays `_TBD_`. You approve each file.

Bootstrap also reads your existing `CLAUDE.md` for rules on the same subjects as the seed (commit format, where docs live, review process, branch policy) and asks you which rule wins in each clash. The loser is deleted, so you never end up with two rules on one subject.

Work already under way gets a row in `status.md` at its real phase, marked `pre-adoption`. Gates before that phase are waived; gates after it apply in full. Nothing already shipped is documented after the fact. There are no retro PRDs and no retro ADRs, and the next new piece of work starts with the product-manager like any other.

## Start work

Tell Claude what you want, the way you'd brief a team lead. The orchestrator sorts it. Bugs and chores go straight to the senior-developer, who fixes them with tests and writes a short record in `fixes/`. Everything else goes to the product-manager, who writes a brief or a PRD and plans the path.

Ask "what's next?" whenever you like. The orchestrator reads `status.md` and tells you what's in flight, what's waiting on you, and what it will do next.

## Give your team the plugin

To have collaborators get the plugin automatically, check this into the project's `.claude/settings.json` (bootstrap offers to do it on your own projects):

```json
{
  "extraKnownMarketplaces": {
    "dev-team": { "source": { "source": "github", "repo": "J-T-McC/dev-team" } }
  },
  "enabledPlugins": { "dev-team@dev-team": true }
}
```
