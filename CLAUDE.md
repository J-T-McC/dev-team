# dev-team — framework repository

This repo **is** the dev-team Claude Code plugin and its marketplace. Do not scaffold a `docs/` workspace here; there is no product being built in this repo.

## Layout

- `agents/` + `skills/` — the six roles; each agent preloads its skill via `skills:` frontmatter (skills are the single source of truth for role definitions)
- `templates/`, `workflow/` — framework reference shipped with the plugin, referenced via `${CLAUDE_PLUGIN_ROOT}`
- `seeds/` — files the `bootstrap` skill copies into consuming projects (standards, stack, status, project CLAUDE.md); project-owned after copy
- `examples/user-authentication/` — worked example referenced by the skills
- `hooks/` — tiny SessionStart announcement
- `.claude-plugin/` — `plugin.json` (no version field: every commit is an update) + `marketplace.json`

## When editing

- Keep role boundaries non-overlapping; keep documents concise and free of duplication
- Path rules: plugin-internal references use `${CLAUDE_PLUGIN_ROOT}/…`; workspace references use project-relative `docs/…`
- Run `claude plugin validate .` before committing
- Consuming projects pull changes with `/plugin update dev-team@dev-team`
