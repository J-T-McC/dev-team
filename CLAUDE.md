# dev-team — framework repository

This repo **is** the dev-team Claude Code plugin and its marketplace. Do not scaffold a `docs/` workspace here; there is no product being built in this repo.

## Layout

- `agents/` + `skills/` — the six roles (orchestrator is skill-only, no agent); each agent is a thin launcher — preloads its skill via `skills:`, sets effort and memory, pins no tools or model (skills are the single source of truth for role definitions)
- `commands/` — `/dev-team:sync` seed-sync command; `/dev-team:tickets` ticket-system setup/tuning; `/dev-team:checkins` Orca check-in setup
- `bin/` — check-in trigger scripts and the coordinator lock, run by Orca automations (copied into each project's git dir by the hook); `peer`, the Orca coordinator's dispatch / tell / watch helper
- `templates/`, `workflow/` — framework reference shipped with the plugin, referenced via `${CLAUDE_PLUGIN_ROOT}`; `workflow/handoffs.md` is the canonical home of gate-validity rules, `workflow/adoption.md` of existing-project adoption rules, `workflow/orca.md` of the optional Orca runtime, `workflow/tickets.md` of ticket-system rules
- `seeds/` — files the `bootstrap` skill copies into consuming projects (standards, stack, status, backlog index, project CLAUDE.md); project-owned after copy
- `examples/workspace/` — worked example (one feature folder plus its ADR) referenced by the skills
- `hooks/` — tiny SessionStart announcement; refreshes check-in scripts
- `.claude-plugin/` — `plugin.json` (no version field: every commit is an update) + `marketplace.json`

## When editing

- Keep role boundaries non-overlapping; state each cross-cutting rule once in its canonical home and reference it elsewhere in ≤1 line
- Agent and skill `description:` frontmatter is loaded into every consuming session — keep each under ~30 words
- Path rules: plugin-internal references use `${CLAUDE_PLUGIN_ROOT}/…`; workspace references use project-relative `docs/…`
- Run `claude plugin validate .` and `tests/*.sh` before committing
- Consuming projects pull changes with `/plugin update dev-team@dev-team`, then `/dev-team:sync` for seed drift
