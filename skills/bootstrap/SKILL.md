---
name: bootstrap
description: Scaffold the dev-team workspace into the current project — creates the docs/ tree, seeds the standards and stack config, creates docs/status.md and the project CLAUDE.md section. Run once per project; safe to re-run (never overwrites existing files).
---

# Bootstrap the dev-team workspace

Scaffold the per-project workspace this plugin's agents work in. **Idempotent:** never overwrite an existing file; report anything skipped.

## Steps

1. Run the seed sync: follow `${CLAUDE_PLUGIN_ROOT}/commands/sync.md` — it creates the `docs/` directories and copies any missing seeds (standards, stack, status), never overwriting. Seeds become **project-owned**: customized and committed to the project repo.

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
   - Fill in `docs/stack/stack.md` and customize `docs/standards/*.md` — agents are instructed to stop and ask rather than guess while placeholders remain.
   - Commit the scaffolded files to the **project** repo.
