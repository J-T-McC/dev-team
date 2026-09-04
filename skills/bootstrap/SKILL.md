---
name: bootstrap
description: Scaffold the dev-team workspace into the current project — creates the docs/ tree, seeds standards and stack config, status.md, and the project CLAUDE.md section; harvests standards from an existing codebase. Run once per project; safe to re-run.
---

# Bootstrap the dev-team workspace

Scaffold the per-project workspace this plugin's agents work in. **Idempotent:** never overwrite an existing file; report anything skipped.

## First: greenfield or existing?

```bash
git log --oneline -1 2>/dev/null; ls docs 2>/dev/null; ls CLAUDE.md 2>/dev/null
```

A repository with source code and history predating this session is an **existing project** — run step 0 and step 5 as well, per `${CLAUDE_PLUGIN_ROOT}/workflow/adoption.md`. A fresh or near-empty repository is greenfield: skip both. When it is genuinely ambiguous, ask the Owner rather than guessing — the wrong branch either interrogates the Owner for answers the code holds, or invents standards for a project with none.

## Steps

0. **Existing projects — survey before writing** (`workflow/adoption.md`):
   - **`docs/` already exists:** list what is in it. If it is a published site or generated output, adding subdirectories may get them built, deployed, or wiped — report that risk and get the Owner's go-ahead before creating anything inside it.
   - **`CLAUDE.md` already exists:** scan it for rules on commit messages, document locations, review or approval process, and branch/PR policy. Report each conflict as a pair (project's rule vs. the seed's) and have the Owner name the winner. Delete the loser; never leave two rules on one subject.

   Resolve both before continuing.

1. Run the seed sync: follow `${CLAUDE_PLUGIN_ROOT}/commands/sync.md` — it creates the `docs/` directories and copies any missing seeds (standards, stack, status, backlog index), never overwriting. Seeds become **project-owned**: customized and committed to the project repo.

2. Project `CLAUDE.md`:
   - If the project has no `CLAUDE.md`: `cp "${CLAUDE_PLUGIN_ROOT}/seeds/CLAUDE.project.md" CLAUDE.md`
   - If one exists and does not already contain a "Development Organization" section: append the seed's content to it.
   - If the section already exists: skip.

3. Optional (ask the user first): check a marketplace registration into the project's `.claude/settings.json` so collaborators auto-get this plugin:

```json
{
  "extraKnownMarketplaces": {
    "dev-team": { "source": { "source": "github", "repo": "J-T-McC/dev-team" } }
  },
  "enabledPlugins": { "dev-team@dev-team": true }
}
```

4. Report what was created vs. skipped, then remind the user:
   - Fill in `docs/stack/stack.md` and customize `docs/standards/*.md` — agents are instructed to stop and ask rather than guess while placeholders remain. Existing projects: step 5 fills most of this from the code instead.
   - Commit the scaffolded files to the **project** repo.

5. **Existing projects — harvest, then draw the line** (`workflow/adoption.md`):
   - **Harvest:** invoke the `dev-team:principal-engineer` skill to propose `docs/stack/stack.md`, `docs/standards/coding.md`, and `docs/standards/testing.md` from the repository — manifests, CI and container config, lint/format config, test layout, a representative sample of source, and commit history. Every proposed line cites the file it came from; anything the repository does not answer stays `_TBD_`. Record what the project does, not what it should do. The Owner approves each file.
   - **Declare in-flight work:** one `docs/status.md` row per feature already under way, `Phase` at its true position, `Approvals: pre-adoption`. Upstream gates are waived by that record; downstream gates apply in full from today.
   - **Never document backwards.** No PRD, plan, or ADR for work already shipped — documents are written forward, for the next change. The next *new* feature runs the pipeline from the top.
