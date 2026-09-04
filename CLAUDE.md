# dev-team — framework repository

This repo **is** the dev-team Claude Code plugin and its marketplace. Do not scaffold a `docs/` workspace here; there is no product being built in this repo.

## Layout

- `agents/` + `skills/` — the six roles (orchestrator is skill-only, no agent); each agent preloads its skill via `skills:` frontmatter (skills are the single source of truth for role definitions)
- `commands/` — `/dev-team:sync` seed-sync command
- `templates/`, `workflow/` — framework reference shipped with the plugin, referenced via `${CLAUDE_PLUGIN_ROOT}`; `workflow/handoffs.md` is the canonical home of gate-validity rules, `workflow/adoption.md` of existing-project adoption rules
- `seeds/` — files the `bootstrap` skill copies into consuming projects (standards, stack, status, backlog index, project CLAUDE.md); project-owned after copy
- `examples/user-authentication/` — worked example referenced by the skills
- `hooks/` — tiny SessionStart announcement
- `.claude-plugin/` — `plugin.json` (no version field: every commit is an update) + `marketplace.json`

## When editing

- Keep role boundaries non-overlapping; state each cross-cutting rule once in its canonical home and reference it elsewhere in ≤1 line
- Agent and skill `description:` frontmatter is loaded into every consuming session — keep each under ~30 words
- Path rules: plugin-internal references use `${CLAUDE_PLUGIN_ROOT}/…`; workspace references use project-relative `docs/…`
- Run `claude plugin validate .` before committing
- Consuming projects pull changes with `/plugin update dev-team@dev-team`, then `/dev-team:sync` for seed drift
