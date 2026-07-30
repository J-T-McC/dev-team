---
name: bootstrap
description: Scaffold the dev-team workspace into the current project — creates the docs/ tree, seeds the standards and stack config, creates docs/status.md and the project CLAUDE.md section. Run once per project; safe to re-run (never overwrites existing files).
---

# Bootstrap the dev-team workspace

Scaffold the per-project workspace this plugin's agents work in. **Idempotent:** never overwrite an existing file; report anything skipped.

## Steps

1. Create the workspace directories:

```bash
mkdir -p docs/product docs/plans docs/tasks docs/questions docs/reviews docs/architecture docs/standards docs/stack
```

2. Copy the seeds — these become **project-owned** and should be customized and committed to the project repo (`cp -n` skips existing files):

```bash
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/standards/"*.md docs/standards/
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/stack.md" docs/stack/stack.md
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/status.md" docs/status.md
```

3. Project `CLAUDE.md`:
   - If the project has no `CLAUDE.md`: `cp "${CLAUDE_PLUGIN_ROOT}/seeds/CLAUDE.project.md" CLAUDE.md`
   - If one exists and does not already contain a "Development Organization" section: append the seed's content to it.
   - If the section already exists: skip.

4. Optional (ask the user first): check a marketplace registration into the project's `.claude/settings.json` so collaborators auto-get this plugin:

```json
{
  "extraKnownMarketplaces": {
    "dev-team": { "source": { "source": "github", "repo": "J-T-McC/dev-team" } }
  },
  "enabledPlugins": { "dev-team@dev-team": true }
}
```

5. Report what was created vs. skipped, then remind the user:
   - Fill in `docs/stack/stack.md` and customize `docs/standards/*.md` — agents are instructed to stop and ask rather than guess while placeholders remain.
   - Commit the scaffolded files to the **project** repo.
