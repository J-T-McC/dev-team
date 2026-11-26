# dev-team — framework repository

This repo **is** the dev-team Claude Code plugin and its marketplace. Do not scaffold a `docs/` workspace here; there is no product being built in this repo.

## Layout

- `agents/` + `skills/` — the six roles (orchestrator is skill-only, no agent); each agent is a thin launcher — preloads its skill via `skills:`, sets effort and memory, pins no tools or model (skills are the single source of truth for role definitions)
- `commands/` — `/dev-team:sync` seed-sync command; `/dev-team:tickets` ticket-system setup/tuning; `/dev-team:checkins` Orca check-in setup; `/dev-team:board` Owner board setup; `/dev-team:orca` Orca runtime setup, with the recommended preset; `/dev-team:audit` the token audit
- `bin/` — check-in trigger scripts and the coordinator lock, run by Orca automations (copied into each project's git dir by the hook); `peer`, the Orca coordinator's dispatch / tell / switch / sleep / watch / PR helper and the Owner board's stamp (also behind the guard hooks); `slot`, the machine-wide turn-taking for heavy jobs and long-lived containers; `board-drift`, the Owner board's PR check; `seed-drift`, sync's drift check; `token-audit`, the audit's transcript summary
- `templates/`, `workflow/` — framework reference shipped with the plugin, referenced via `${CLAUDE_PLUGIN_ROOT}`; `workflow/handoffs.md` is the canonical home of gate-validity rules, `workflow/adoption.md` of existing-project adoption rules, `workflow/orca.md` of the optional Orca runtime, `workflow/orca-recommended.md` of its recommended preset, `workflow/tickets.md` of ticket-system rules, `workflow/board.md` of the Owner board, `workflow/friction.md` of the friction log
- `seeds/` — files the `bootstrap` skill copies into consuming projects (standards, stack, status, backlog index, project CLAUDE.md); project-owned after copy
- `examples/workspace/` — worked example (one feature folder plus its ADR) referenced by the skills; `examples/board/` — Owner board sample data and README screenshots (made-up data only)
- `site/` — the public docs site (Astro Starlight, deployed to GitHub Pages by `.github/workflows/pages.yml`): plain explanations for people that link to `workflow/` for the rules, never restate them in full; `tests/site.sh` fails when a command, setting, environment variable, or board state is missing from it
- `hooks/` — tiny SessionStart announcement; refreshes check-in scripts; the coordinator's UserPromptSubmit / Stop guard (silent unless the checkout has peer homes or an Owner board); a PostToolUse note when an edit takes a feature document past the size limit
- `.claude-plugin/` — `plugin.json` (no version field: every commit is an update) + `marketplace.json`

## When editing

- Keep role boundaries non-overlapping; state each cross-cutting rule once in its canonical home and reference it elsewhere in ≤1 line
- Agent and skill `description:` frontmatter is loaded into every consuming session — keep each under ~30 words
- Path rules: plugin-internal references use `${CLAUDE_PLUGIN_ROOT}/…`; workspace references use project-relative `docs/…`
- A change people would notice — a command, setting, state, or behaviour — updates its `site/` page in the same PR
- Run `claude plugin validate .` and `tests/*.sh` before committing; CI (`.github/workflows/tests.yml`) runs `tests/*.sh` on Linux and macOS for every PR
- A PR's title becomes its squash commit and sets the release (`.github/workflows/release.yml`): `feat` → minor, `fix` or `perf` → patch, `!` → major, other types → none. The `pr title` check fails a title that isn't a conventional commit
- Consuming projects pull changes with `/plugin update dev-team@dev-team`, then `/dev-team:sync` for seed drift
