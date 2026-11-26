---
name: bootstrap
description: Set up dev-team in this project, or change an existing setup. Reads the project first, asks a few questions with suggested answers, then writes the workspace and the dev-team section.
---

# Set up dev-team

Read the project, ask at most three rounds of questions (plus the stack facts, when the team picks and the description left some out), write everything, check it, and finish with a next step. Layout and the Workspace line: `${CLAUDE_PLUGIN_ROOT}/workflow/workspace.md`. Existing projects: `${CLAUDE_PLUGIN_ROOT}/workflow/adoption.md`. **Never overwrite a file that was there before setup;** report anything skipped.

## How to ask

- **Every question has a recommended answer,** listed first, and every answer has a one-line meaning. Use `setup-detect`'s suggestion, with its reason, where it has one.
- **Plain words for someone new to dev-team.** Explain each dev-team word where it first appears: *the team* (dev-team's roles: a product manager, a designer, a lead engineer, developers and a reviewer), *you* as the Owner (the person who decides), *the workspace* (the folder where the team keeps its documents), *Orca* (an app that runs each role as its own Claude session), *the Owner board* (a live page of what needs you). Never offer something only as a slash command: say what it does; the command can follow in brackets.
- **Use the question tool when the session has it** (AskUserQuestion): one dialog per round, up to four questions, the recommended answer first and marked "(Recommended)". Setup is the one place a dialog is right (`${CLAUDE_PLUGIN_ROOT}/workflow/communication.md` § Talking to the Owner). Without the tool, ask the round as a numbered list in chat, each answer on its own line with its meaning, and end the turn.
- **Answers already given count,** in any words. Ask only what is still missing; with nothing missing, go straight to writing. "Don't ask me anything else" means: take the recommended answer for anything missing, and say which ones you took.
- **Write nothing until the last round is answered,** with a tool call or a shell command alike. An existing project's digest comes after writing.
- **Never ask what has a default:** the workspace folder, the features folder, folder naming. Show them in the summary, where the Owner can change them.

## 1. Read the project

```bash
"${CLAUDE_PLUGIN_ROOT}/bin/setup-detect"
```

It prints JSON: the project (`state`, `access`, `dev_team_dir`), its commit style, its code and tools, the machine, Claude's plan and whether this runs inside Orca, and `suggest` (a suggested answer, with a reason, for each question below). Never ask what it already answers. Pass on its `notices` that matter for this setup, after the questions, in plain words, explaining any term they use.

- `state: set-up` → **Already set up**, below. Nothing else in this file applies.
- `state: existing` → every step, including step 5.
- `state: new` → every step except step 5.

## 2. Round 1: the basics

1. **Whose project is this?** Recommend `suggest.project`, with its reason; with no suggestion, recommend "just me for now".
   - **My project, shared with the team:** dev-team's rules go in `CLAUDE.md` and its documents are committed with your code, so everyone on the repository sees both.
   - **My project, just me for now:** the rules go in your own `CLAUDE.local.md`, and the documents are kept out of the repository's history, in a history of their own. Nothing changes for anyone else until you share it.
   - **Someone else's project (guest):** like "just me", and their conventions always win: nothing in the code, commits or pull requests mentions dev-team.
2. **How involved do you want to be?**
   - **Standard (Recommended):** you approve what gets built, each release, and big decisions such as a new dependency; the team handles the rest.
   - **Supervised:** you approve every step.
   - **Autonomous:** the team approves its own work. You still decide anything that can't be undone, costs money, touches security, or leaves the repository.
3. **Commit messages.** Guests always keep the project's style; say so.
   - `suggest.commits` is `project`: **keep this project's style (Recommended)**: say what it is in words (from `commits.style` and `commits.ticket_prefix`, such as "conventional commits with ENG ticket IDs"), and quote `commits.example` exactly. Then dev-team's style, with its example, then your own.
   - Otherwise: **dev-team's style (Recommended):** `<type>(<scope>): <ticket ID> <what changed>`, such as `feat(auth): ENG-123 add login timeout`; with no ticket system, the task's ID takes the ticket's place. Then your own; then this project's style, only when it has history to quote.
4. **New projects: what are you building?** Ask it in chat, after the dialog (or with the list, without one): what it is, who it's for, where it runs (web, phone, desktop, a service), where you'd host it if you know, and anything it must use. The stack question needs it.

## 3. Round 2: how the team works

Only the questions that apply; skip the round when none do.

- **The stack** (new projects only):
  - **Let the team pick (Recommended):** the lead engineer chooses from your description and writes down why. Anything that costs money still comes to you.
  - **I'll name it:** say the languages and frameworks; suggest some from what `machine.tools` shows installed, and, with the Owner's yes, from their other projects (`setup-detect --other-projects <their projects folder>`).
  - **Decide at the first feature:** the team proposes a stack with the first plan, for your yes.

  **Let the team pick** needs the facts in `${CLAUDE_PLUGIN_ROOT}/workflow/stack-pick.md` § Facts first. Ask for each one the description left out, each with a suggested answer and room for their own, and pick nothing until they're answered.
- **Where the team runs** (only when `machine.tools` has `orca`, or `claude.in_orca` is true): recommend `suggest.runtime`, with its reason. The answers: **here, in this conversation** (one role at a time), or **Orca, sized for your plan** (each role its own session, side by side; sizes in `${CLAUDE_PLUGIN_ROOT}/workflow/orca-recommended.md` § Team shape), or Orca at another size.
- **Anything else to set up now?** Several answers allowed. Offer the board and check-ins only when `suggest.extras.available` lists them, and say in one line why one can't be offered yet:
  - **A live board of what needs you** (the Owner board): one page showing what's waiting on you, who's working on what, and the work in flight.
  - **Scheduled check-ins:** Orca checks on the team on a timer, for new tickets and stalled work.
  - **A ticket system:** the team takes work from your tickets and keeps them updated. Name the one found (`tickets: GitHub`); Linear and Jira work too.
  - **Share the plugin with teammates** (shared projects only): adds dev-team to the repository's Claude settings, so teammates get it when they open the project.

## 4. Write

1. **The dev-team section:** `${CLAUDE_PLUGIN_ROOT}/seeds/CLAUDE.project.md`, with:
   - **The Workspace line** for the answer to question 1 (`workflow/workspace.md` § Whose project). Root `dev-team`, guest `.dev-team`; if `dev_team_dir` is `taken`, use `.dev-team` and say so. Features `<root>/features`, folders `slug`.
   - **Autonomy** set to the answer.
   - **Commits:** dev-team's style keeps the seed's line. The project's style: `- Commits: follow this project's style, e.g. \`<commits.example>\``. Their own: their words. Guest: `- Commits: follow this repository's conventions`.
   - **Shared:** append it to `CLAUDE.md`, or create the file. Never change the project's own lines; rules on the same subject follow `workflow/adoption.md` § Before writing anything. **Just me, guest:** write it to `CLAUDE.local.md`, never `CLAUDE.md`. If `claude.install_scope` has no `local`, tell them to install the plugin for this project only (`/plugin install dev-team@dev-team --scope local`).
2. **Just me, guest: the workspace's own history.** Three separate commands, so one that is blocked doesn't stop the others: add the root and, unless `git check-ignore -q CLAUDE.local.md` says it's ignored already, `CLAUDE.local.md` to `.git/info/exclude` (never `.gitignore`), with `printf`; `mkdir -p <root>`; then `git -C <root> init -q` (for example `git -C .dev-team init -q`). If a step fails, as `git init` does where a sandbox blocks writing a new repository, say so plainly and give the Owner the exact commands to run themselves. From then on the plugin's Stop hook commits the workspace whenever it changes.
3. **Folders and seeds:** follow `${CLAUDE_PLUGIN_ROOT}/commands/sync.md` step 3. It creates the folders and copies the seeds that apply; `design.md` only when `code.ui` is true or the description has screens.
4. **The stack** (new projects): the **Product** line in `<ws>/stack/stack.md` comes from the description.
   - **The team picks:** invoke the `dev-team:principal-engineer` skill to pick and record it (`workflow/stack-pick.md`).
   - **Named:** fill the rows they named, each checked as current (`workflow/stack-pick.md` § Defaults); the rest stay _open_.
   - **Later:** the rows stay _open_.
5. **Where the team runs, and extras:** follow each chosen command's file. Orca: `${CLAUDE_PLUGIN_ROOT}/commands/orca.md`, `recommended` at the chosen size. The board: `commands/board.md`. Check-ins: `commands/checkins.md`. Tickets: `commands/tickets.md`. Sharing the plugin: add this to `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "dev-team": { "source": { "source": "github", "repo": "J-T-McC/dev-team" } }
  },
  "enabledPlugins": { "dev-team@dev-team": true }
}
```

## 5. Existing projects: harvest, then one digest

1. **Harvest:** invoke the `dev-team:principal-engineer` skill's adoption harvest to write `<ws>/stack/stack.md`, `<ws>/standards/coding.md` and `<ws>/standards/testing.md` (`workflow/adoption.md` § Harvesting). What runs is the standard (`code.runs`, `code.tools_run`). Each line cites its file. A section the code doesn't answer gets a suggestion, marked `(suggested at setup)`. Guest: only what the repository doesn't already document.
2. **Mismatches go to the backlog,** one `debt` item each: config nothing runs (`code.config_not_run`), a tool only the docs name. Use the plugin's `templates/backlog-item.md` and add a row to `<ws>/backlog/index.md`. Never ask the Owner to sort them out at setup.
3. **Work in flight:** one `<ws>/status.md` row per feature already under way, `Approvals: pre-adoption` (`workflow/adoption.md` § In-flight work). Propose the Owner's open pull requests (`open_prs`) as candidates in the digest, and write their rows only once the Owner confirms them.
4. **The digest** is the finish message, with one question. It lists the stack and standards found, each with the file it came from; the suggestions for what the code didn't show; any rule pairs from their `CLAUDE.md`; the backlog items filed; and the in-flight candidates. Then ask: **use these (Recommended)** / **show me the files first** / **change something**.

## 6. Check it works

```bash
source "${CLAUDE_PLUGIN_ROOT}/bin/_workspace.sh" . && echo "root=$WS mode=$WS_MODE committed=$WS_COMMITTED" && ls "$WS/status.md" && "${CLAUDE_PLUGIN_ROOT}/bin/seed-drift" .
```

The root, mode and committed match the answers, `status.md` exists, and `seed-drift` says `up to date`. Fix anything that doesn't before finishing.

## 7. Finish

- **Existing projects:** the digest (step 5) is the finish message.
- **What was set up,** in a few lines: where the documents are and whether they're committed, the autonomy level, the commit style, the stack (picked, named, or proposed with the first feature), where the team runs, and the extras turned on.
- **Committed workspace:** offer to commit the new files.
- **Nothing left as homework.** Never list or count open sections, and never ask the Owner to fill in files: the first plan that needs a section sets it.
- **End with the next step,** in plain words: tell the team the first thing to build, with an example drawn from what they're building. Then one line on what they can ask for later, such as a ticket system or the board, in plain words.

## Already set up

`setup-detect` says `state: set-up`. Write nothing until the Owner picks a change.

1. **Show the settings** from the dev-team section (`CLAUDE.local.md` first, then `CLAUDE.md`): where the documents are and whether they're committed; whose project (`_workspace.sh`'s `WS_MODE`); autonomy; the commit style; where the team runs (a Runtime line or not); and the extras turned on (an `**Owner board:**` line, `<ws>/standards/tickets.md`, `<ws>/standards/checkins.md`).
2. **Ask what to change:** **nothing, it's fine (Recommended)** / **change a setting** / **bring the workspace up to date with the plugin** (`commands/sync.md`) / **set up something extra** (the board, check-ins, tickets, Orca).
3. **Then make only that change.** Moving the folders or changing whether they're committed moves files: `commands/sync.md`'s migration, on approval. Sharing a "just me" setup with the team: `workflow/workspace.md` § Whose project.
