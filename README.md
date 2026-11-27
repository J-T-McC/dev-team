# dev-team

A [Claude Code](https://code.claude.com) plugin that runs feature work the way a small software team does. Six roles take a request from requirements to reviewed code and write everything down in your repo as they go. You sign off where it matters and nowhere else.

**Docs: [j-t-mcc.github.io/dev-team](https://j-t-mcc.github.io/dev-team/)**

## Install

```
/plugin marketplace add J-T-McC/dev-team
/plugin install dev-team@dev-team
```

Run both inside your project and pick **Install for you, in this repo only (local scope)**. The first choice, user scope, loads the plugin into every session in every project. From a shell in the project folder, `claude plugin install dev-team@dev-team --scope local` skips the menu.

Then ask Claude to `set up dev-team in this project`. Setup reads the project before it asks anything, and asks at most three rounds of questions, each with a suggested answer ([Get started](https://j-t-mcc.github.io/dev-team/getting-started/)).

You need macOS or Linux (WSL on Windows) and git. The Orca runtime, the Owner board, check-ins and the audit also need Python 3.9+, and the Orca runtime and Owner board need the GitHub CLI (`gh`).

## How it works

A request moves through the roles in order: product manager, designer (UI work only), principal engineer, senior developer, reviewer. The orchestrator routes it between them. Each role hands off through a document in the workspace folder, so the requirements, decisions, plans, task records and reviews end up in your repo, and the next session starts from the files rather than from memory.

Most work takes a shorter path. A clear request gets a short brief instead of a PRD, each role decides whether its own phase is needed, and bugs and chores go straight to a developer ([Pipeline](https://j-t-mcc.github.io/dev-team/pipeline/)). The roles follow shared rules: write plainly, check your own work against the documents, prove a requirement before adding it, and log what slowed you down so the workflow gets fixed ([Team rules](https://j-t-mcc.github.io/dev-team/team-rules/)).

Two lines in the project's `CLAUDE.md` decide how much happens without you. `Autonomy` sets who signs each step: `supervised`, `standard` (you approve requirements, releases and major decisions) or `autonomous`. At every level, anything irreversible, security-sensitive, paid, or leaving the repo waits for you. `Next work` sets whether the team starts work on its own: only what you hand it, the product you described, your tickets as they arrive, or what the product manager picks from tickets and the backlog ([Autonomy](https://j-t-mcc.github.io/dev-team/autonomy/)).

## Two ways to run it

By default every role runs inside your own Claude Code conversation, one at a time. Claude loads the role's rules, does the phase and hands off through a document, so most work never pays for an agent's startup. An agent starts only when it earns its cost: streams of work running at once, a review by fresh eyes, or a phase too big for the conversation.

On the [Orca runtime](https://j-t-mcc.github.io/dev-team/orca/), every role runs as its own top-level Claude Code session with your project's full tools, and several developers build at once in their own worktrees. Your session becomes the coordinator: it hands out tasks, answers the team and takes your approvals, and waiting costs it nothing. Every task starts a fresh session, so this mode spends more. It pays when parallel work is worth that.

The plugin brings no stack, skills or tools of its own. Every role, agent or Orca session starts with your `CLAUDE.md` files, installed skills and plugins, MCP servers and SessionStart hooks, so trim what the roles don't use before running several at once ([What your project costs](https://j-t-mcc.github.io/dev-team/costs/)).

## Extras

Each is off until you set it up, and each has a command that does it.

- [Orca runtime](https://j-t-mcc.github.io/dev-team/orca/) (`/dev-team:orca`), with a [recommended setup](https://j-t-mcc.github.io/dev-team/orca-recommended/) sized for your Claude plan.
- [Owner board](https://j-t-mcc.github.io/dev-team/board/) (`/dev-team:board`): a live, private claude.ai page with what's waiting on you first, then who's on what, then the work in flight. It works with either runtime.
- [Check-ins](https://j-t-mcc.github.io/dev-team/checkins/) (`/dev-team:checkins`): Orca automations that keep work moving on a schedule. An idle project costs nothing.
- [Ticket systems](https://j-t-mcc.github.io/dev-team/tickets/) (`/dev-team:tickets`): Linear, Jira, GitHub Issues or Projects as the source of work. Only what you allow goes back to the tracker.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="examples/board/board-dark.png">
  <img alt="Owner board with sample data: two questions waiting on the Owner, seven roles and their current tasks, and work grouped as Reporting, Mobile and Platform with ticket, PR, state and next step." src="examples/board/board-light.png">
</picture>

## Update

```
/plugin marketplace update dev-team
/plugin update dev-team@dev-team
```

Every commit is a new version, and each merged feature or fix is also tagged as a [release](https://github.com/J-T-McC/dev-team/releases): a feature raises the minor version, a fix the patch. Updates never touch what setup copied into your project, such as the dev-team section, `standards/` and `stack/`. Run `/dev-team:sync` afterwards. It copies seed files you're missing, reports sections and rules the plugin has added since, moves an older workspace layout, and changes nothing without your yes ([Updating](https://j-t-mcc.github.io/dev-team/updating/)).

## Develop the framework locally

```
/plugin marketplace add /path/to/dev-team    # local checkout as a second marketplace
# after edits:
/plugin marketplace update dev-team
/reload-plugins
```

Validate with `claude plugin validate .` and run `tests/*.sh`.

## Layout

| Path | What | Updated by the plugin |
|---|---|---|
| `agents/`, `skills/` | The six roles (the orchestrator is skill-only) and the setup skill | yes |
| `commands/` | `/dev-team:sync`, `tickets`, `checkins`, `board`, `orca` and `audit` | yes |
| `templates/`, `workflow/` | Document templates; the pipeline, handoff and communication rules | yes |
| `bin/` | Check-in triggers and the coordinator lock; `peer` and `slot` for the Orca runtime; `board-drift` for the Owner board; `seed-drift` and `migrate-layout` for sync; `token-audit` for the audit | yes |
| `hooks/` | Session start; the coordinator's guard hooks; the Stop hook that commits an uncommitted workspace; the edit hook that flags a feature document past the size limit | yes |
| `seeds/` | Files setup and sync copy into a project | no: the project owns its copy |
| `examples/` | A worked workspace, and the Owner board's sample data and screenshots | yes |
| `site/` | The docs site, built with Astro Starlight and published to GitHub Pages | not used by projects |
