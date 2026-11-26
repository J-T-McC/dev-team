---
title: Get started
description: Install the plugin, set up a project, and start the first piece of work.
---

## Install

You need Claude Code on macOS or Linux (on Windows, use WSL) and git. Some optional parts need more:

- the [Orca runtime](/dev-team/orca/), the [Owner board](/dev-team/board/), [check-ins](/dev-team/checkins/) and the [audit](/dev-team/costs/#the-audit) run small Python scripts, so they need Python 3.9 or newer (`python3`; a Mac with git already has it);
- the Orca runtime and the Owner board follow pull requests with the GitHub CLI (`gh`).

In Claude Code, inside your project:

```
/plugin marketplace add J-T-McC/dev-team
/plugin install dev-team@dev-team --scope local
```

`--scope local` installs it for you, in this project only. Leave it out and it installs for you in every project, and every Claude Code session you start, anywhere, loads it. The same command is right on someone else's project ([guest mode](/dev-team/workspace/#guest-mode)). To give everyone on your repository the plugin, see [Give your team the plugin](#give-your-team-the-plugin); bootstrap offers to set that up.

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

Before you run several roles at once, or switch to the Orca runtime, read [what it costs](/dev-team/costs/): your project's own setup decides most of it.

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
