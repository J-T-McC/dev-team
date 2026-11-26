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

`--scope local` installs it for you, in this project only. Leave it out and it installs for you in every project, and every Claude Code session you start, anywhere, loads it. The same command is right on someone else's project ([guest mode](/dev-team/workspace/#guest-mode)). To give everyone on your repository the plugin, see [Give your team the plugin](#give-your-team-the-plugin); setup offers to do that.

## Set up the project

Ask Claude, in your own words:

```
set up dev-team in this project
```

Setup reads the project and your machine first: its commit history, the tools its scripts and CI run, who owns the repository, your Claude plan, and whether Orca is installed. Every question then comes with a suggested answer, so you can accept the suggestions and be done. There are at most three rounds:

1. **The basics.**
   - **Whose project is it?**
     - *Your project, shared with the team*: dev-team's rules go in `CLAUDE.md` and its documents are committed with your code.
     - *Your project, just you for now*: the rules go in your own `CLAUDE.local.md`, and the documents are kept out of the repository, in a history of their own.
     - *Someone else's*: [guest mode](/dev-team/workspace/#guest-mode).
   - **How involved do you want to be?** Supervised, standard or autonomous ([autonomy](/dev-team/autonomy/)).
   - **Commit messages:** the project's own style, quoted from its history, or dev-team's, or your own.

   A new project is also asked what you're building.
2. **How the team works,** only where it applies:
   - **The stack,** for a new project: let the team pick, name it yourself, or decide at the first feature.
   - **Where the team runs,** when Orca is installed: here in the conversation, or in [Orca](/dev-team/orca/), sized for your plan.
   - **Extras,** where you can pick several: the [Owner board](/dev-team/board/), [check-ins](/dev-team/checkins/), a [ticket system](/dev-team/tickets/), and giving teammates the plugin.
3. **For an existing project,** one summary of what it found in your code, ending with: use these, show me the files first, or change something.

The documents go in `dev-team/` (`.dev-team/` for a guest), and setup shows where it put everything. Anything still open in the standards isn't homework: the team proposes it when the first piece of work needs it. Setup finishes by suggesting the first thing to ask the team for.

**Letting the team pick the stack** needs a few facts first: where it runs, where it's hosted, who uses it, what it stores, and what it must use. Setup asks for any your description left out. The lead engineer then chooses current, well-established tools that fit the product, and writes down why in the project's first decision record (ADR-001). Anything that costs money, such as paid hosting, still comes to you.

Run setup again at any time. On a project that's already set up, it shows the current settings and asks what to change, without copying anything again.

## Existing codebases

Most of what the standards ask is already answered by your code, so setup reads it instead of quizzing you. The principal-engineer goes through the manifests, CI config, lint and test setup, a sample of source files and the commit history, then writes the stack file and the coding and testing standards. Every line names the file it came from.

What runs counts, not what's lying around. A linter that the scripts or CI run is the standard. A config file nothing runs, or a tool only the README mentions, goes into the backlog as one item to sort out later, and setup doesn't ask you about it. Where the code doesn't answer something, setup suggests a choice and marks it as a suggestion. The summary lists it so you can say yes or change it.

Setup also reads your existing `CLAUDE.md` for rules on the same subjects as dev-team's (commit format, where docs live, review process, branch policy). Your rule wins by default, since it's the one in use, and the summary lists each pair in case you'd rather take dev-team's. Your own lines are never changed without your yes.

Work already under way gets a row in `status.md` at its real phase, marked `pre-adoption`. Your open pull requests are offered as candidates. Gates before that phase are waived; gates after it apply in full. Nothing already shipped is documented after the fact. There are no retro PRDs and no retro ADRs, and the next new piece of work starts with the product-manager like any other.

## Start work

Tell Claude what you want, the way you'd brief a team lead. The orchestrator sorts it. Bugs and chores go straight to the senior-developer, who fixes them with tests and writes a short record in `fixes/`. Everything else goes to the product-manager, who writes a brief or a PRD and plans the path.

Ask "what's next?" whenever you like. The orchestrator reads `status.md` and tells you what's in flight, what's waiting on you, and what it will do next.

Before you run several roles at once, or switch to the Orca runtime, read [what it costs](/dev-team/costs/): your project's own setup decides most of it.

## Give your team the plugin

To have collaborators get the plugin automatically, check this into the project's `.claude/settings.json` (setup offers to do it when the project is shared):

```json
{
  "extraKnownMarketplaces": {
    "dev-team": { "source": { "source": "github", "repo": "J-T-McC/dev-team" } }
  },
  "enabledPlugins": { "dev-team@dev-team": true }
}
```
