---
name: bootstrap
description: Scaffold the dev-team workspace into the current project — workspace and feature folders, seeds, status, and the dev-team section (own project or guest); harvests standards from an existing codebase. Run once per project; safe to re-run.
---

# Bootstrap the dev-team workspace

Scaffold the per-project workspace this plugin's agents work in. **Idempotent:** never overwrite an existing file; report anything skipped. Layout and settings: `${CLAUDE_PLUGIN_ROOT}/workflow/workspace.md`.

## First: three questions

```bash
git log --oneline -1 2>/dev/null; ls docs CLAUDE.md CLAUDE.local.md 2>/dev/null
```

1. **Own project or guest?** Guest: someone else's project whose team does not use dev-team — nothing may show up in their work (`workflow/workspace.md` § Guest mode).
2. **Greenfield or existing?** A repository with code and history predating this session is existing — run steps 0 and 6 as well (`${CLAUDE_PLUGIN_ROOT}/workflow/adoption.md`). Genuinely ambiguous → ask the Owner.
3. **Workspace settings** — offer the defaults, then ask about **each of the four**; root and features folder are separate questions. A question tool that takes only a few questions at once means asking in two rounds — never drop one:
   - **Root:** `docs` (guest: `.dev-team`).
   - **Features folder:** `<root>/features`, or anywhere else — e.g. next to the team's own feature or task folders. dev-team only ever writes into feature folders it created.
   - **Folder naming:** `slug` (small projects), `F###-slug` (large, many features), `<ticket>-slug` (work comes from tickets).
   - **Committed:** yes (history with the code) or no (excluded locally; the root becomes its own git repository so history is kept).

## Steps

0. **Existing projects — survey before writing** (`workflow/adoption.md`):
   - **The chosen folders already exist:** list what is in them. A published site or generated output may build, deploy, or wipe new folders — report that risk and get the Owner's go-ahead.
   - **Own project, `CLAUDE.md` exists:** scan it for rules on commit messages, document locations, review or approval process, and branch/PR policy. Report each conflict as a pair (project's rule vs. the seed's) and have the Owner name the winner; delete the loser. Guest projects skip this — their rules simply win.

1. **The dev-team section** — the seed `${CLAUDE_PLUGIN_ROOT}/seeds/CLAUDE.project.md`, with its Workspace line set to the chosen values:
   - **Own project:** append it to `CLAUDE.md` (or create the file) unless a "Development Organization" section exists.
   - **Guest:** write it to `CLAUDE.local.md` — never `CLAUDE.md` — and replace its **Commits** convention with "follow this repository's conventions". Tell the Owner to install the plugin at local scope (`/plugin install dev-team@dev-team --scope local`) so it exists for them only.

2. **Uncommitted workspace** (either mode): add the root, and the features folder if it is outside the root, to `.git/info/exclude` (never `.gitignore`), then `git init` inside the root. The plugin's Stop hook commits it whenever it changes.

3. Run the seed sync: follow `${CLAUDE_PLUGIN_ROOT}/commands/sync.md` — it creates the folders and copies missing seeds, never overwriting. Seeds become **project-owned**.

4. Own project only, optional (ask first): check a marketplace registration into `.claude/settings.json` so collaborators get the plugin:

```json
{
  "extraKnownMarketplaces": {
    "dev-team": { "source": { "source": "github", "repo": "J-T-McC/dev-team" } }
  },
  "enabledPlugins": { "dev-team@dev-team": true }
}
```

5. **Owner preferences** — ask, then record in the dev-team section (skip any the Owner defers; defaults apply):
   - **Autonomy:** `supervised`, `standard` (default), or `autonomous`, plus any gates to keep (`${CLAUDE_PLUGIN_ROOT}/workflow/handoffs.md` § Autonomy).
   - **Ticket system:** Linear, Jira, GitHub, or another tracker? Yes → run `${CLAUDE_PLUGIN_ROOT}/commands/tickets.md`. No → `/dev-team:tickets` enables it later.
   - **Orca:** does the Owner run Claude from Orca? Yes → add the Runtime line (`${CLAUDE_PLUGIN_ROOT}/workflow/orca.md` § Opt in) and offer `/dev-team:checkins`.
   - **Design tool:** Figma, Penpot, or another tool with an MCP server? Yes → fill `<ws>/standards/design.md` § Design tool. No → mockups are HTML in each feature's `mockups/`.

6. **Existing projects — harvest, then draw the line** (`workflow/adoption.md`):
   - **Harvest:** invoke the `dev-team:principal-engineer` skill to propose `<ws>/stack/stack.md`, `<ws>/standards/coding.md`, and `<ws>/standards/testing.md` from the repository — manifests, CI, lint/format config, test layout, a source sample, commit history. Every line cites the file it came from; anything unanswered stays `_TBD_`. Guest: record only what the repo does not already document. The Owner approves each file.
   - **Declare in-flight work:** one `<ws>/status.md` row per feature already under way (with its ticket ID if tickets are configured), `Phase` at its true position, `Approvals: pre-adoption`. Upstream gates are waived; downstream gates apply from today.
   - **Never document backwards.** No PRD, plan, or ADR for work already shipped. The next *new* piece of work starts at Product Manager triage.

7. Report what was created vs. skipped, then remind the Owner to fill placeholders in `<ws>/stack/stack.md` and `<ws>/standards/*.md` (agents stop and ask while placeholders remain), and to commit — unless the workspace is uncommitted.
