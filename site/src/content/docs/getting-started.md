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

Pick **Install for you, in this repo only (local scope)**. The first choice, user scope, loads the plugin into every session in every project. From a shell, `claude plugin install dev-team@dev-team --scope local` skips the menu.

You need macOS or Linux (WSL on Windows) and git. The [Orca runtime](/dev-team/orca/), [Owner board](/dev-team/board/), [check-ins](/dev-team/checkins/) and [audit](/dev-team/costs/#the-audit) also need Python 3.9+, and Orca and the board need the GitHub CLI (`gh`).

## Set up the project

```
set up dev-team in this project
```

Setup reads your project first, then asks up to three rounds of questions. Each has a suggested answer: when unsure, take it.

- Whose project it is: yours and shared, yours alone for now, or someone else's ([guest mode](/dev-team/workspace/#guest-mode))
- How involved you want to be ([autonomy](/dev-team/autonomy/)), and your commit style
- New projects: what you're building, and who picks the stack
- Where the team runs, if Orca is installed, and [what it works on](/dev-team/autonomy/#what-the-team-works-on)
- Extras: the Owner board, check-ins, a ticket system, the plugin for teammates

It ends by starting the team, or by suggesting a first request. There's nothing left for you to fill in, and nothing from your project goes back to the plugin's repo. Run it again any time to change a setting.

**Existing code** is read, not asked about. The lead engineer writes your stack and standards from what your scripts and CI actually run, and you approve them in one summary. Your `CLAUDE.md` rules win over dev-team's. Work already under way joins at its current phase. Unless you let the team work through your tickets, it starts only on what you pick.

## Start work

Tell Claude what you want, the way you'd brief a team lead. Bugs and chores go straight to a developer; everything else starts with the product manager. Ask "what's next?" any time.

Running several roles at once? Read [what it costs](/dev-team/costs/) first.

## Give your team the plugin

Check this into `.claude/settings.json` (setup offers to when the project is shared):

```json
{
  "extraKnownMarketplaces": {
    "dev-team": { "source": { "source": "github", "repo": "J-T-McC/dev-team" } }
  },
  "enabledPlugins": { "dev-team@dev-team": true }
}
```
