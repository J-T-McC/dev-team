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
/plugin install dev-team@dev-team
```

The install asks where to put it. Pick **Install for you, in this repo only (local scope)**. The first choice, user scope, installs it for you in every project, and every Claude Code session you start, anywhere, loads it. From a shell in the project folder, `claude plugin install dev-team@dev-team --scope local` does the same without the menu. Local scope is right on someone else's project too ([guest mode](/dev-team/workspace/#guest-mode)). To give everyone on your repository the plugin, see [Give your team the plugin](#give-your-team-the-plugin); setup offers to do that.

## Set up the project

Ask Claude, in your own words:

```
set up dev-team in this project
```

Setup reads the project and your machine before it asks anything: the commit history, the tools your scripts and CI run, who owns the repository, your Claude plan, and whether Orca is installed. Every question comes with a suggested answer, so you can take the suggestions and be done in three rounds or fewer.

The first round covers the basics. Whose project is it? Yours and shared with the team puts dev-team's rules in `CLAUDE.md` and commits its documents with your code. Yours alone for now puts the rules in your own `CLAUDE.local.md` and keeps the documents out of the repository, in a history of their own. Someone else's is [guest mode](/dev-team/workspace/#guest-mode). Then how involved you want to be ([autonomy](/dev-team/autonomy/)), and the commit style: the project's own, quoted from its history, dev-team's, or yours. A new project is also asked what you're building.

The second round asks only what applies. A new project decides who picks the stack: the team, you, or nobody until the first feature. With Orca installed, you choose where the team runs: here in the conversation, or in [Orca](/dev-team/orca/), sized for your plan, with each role made when work first needs it or the whole team made at once. You choose [what the team works on](/dev-team/autonomy/#what-the-team-works-on). On a new project that's building what you described, starting it and waiting for you, or waiting for your first task. On an existing one it's only what you hand it, your tickets as they arrive, or what the product manager picks. Last come the extras: the [Owner board](/dev-team/board/), [check-ins](/dev-team/checkins/), a [ticket system](/dev-team/tickets/), and giving teammates the plugin.

An existing project then gets one summary of what setup found in your code ([below](#existing-codebases)), ending with: use these, show me the files first, or change something. If the team works only on what you hand it, and you have a ticket system or open pull requests, setup also asks which one to start on. On an existing project the team never picks its own first task.

The documents go in `dev-team/` (`.dev-team/` for a guest), and setup shows where everything went. A standard it couldn't fill isn't homework: the team proposes it when the first piece of work needs it. Setup ends by starting the team on what you described, if you said to, or by suggesting the first thing to ask for. Nothing from your project is ever sent back to the plugin's repository.

If you let the team pick the stack, it needs a few facts first: where the product runs, where it's hosted, who uses it, what it stores, and what it must use. Setup asks for any your description left out. The lead engineer then chooses current, well-established tools that fit, and writes down why in the project's first decision record (ADR-001). Anything that costs money, such as paid hosting, still comes to you.

Run setup again at any time. On a project that's already set up, it shows the current settings and asks what to change, without copying anything again.

## Existing codebases

Most of what the standards ask is already answered by your code, so setup reads it instead of quizzing you. The principal-engineer goes through the manifests, CI config, lint and test setup, a sample of source files and the commit history, then writes the stack file and the coding and testing standards. Every line names the file it came from.

What runs counts, not what's lying around. A linter that the scripts or CI run is the standard. A config file nothing runs, or a tool only the README mentions, goes into the backlog as one item to sort out later, and setup doesn't ask you about it. Where the code doesn't answer something, setup suggests a choice and marks it as a suggestion. The summary lists it so you can say yes or change it.

Setup also reads your existing `CLAUDE.md` for rules on the same subjects as dev-team's (commit format, where docs live, review process, branch policy). Your rule wins by default, since it's the one in use, and the summary lists each pair in case you'd rather take dev-team's. Your own lines are never changed without your yes.

Work already under way gets a row in `status.md` at its real phase, marked `pre-adoption`. Your open pull requests are offered as candidates. Gates before that phase are waived; gates after it apply in full. Nothing already shipped is documented after the fact, so there are no retro PRDs or ADRs, and the next new piece of work starts with the product-manager like any other.

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
