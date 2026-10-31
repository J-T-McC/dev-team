---
description: Sync plugin seeds into the project workspace — moves an old type-first layout to feature folders, copies missing files, reports seed sections, rules, and settings an existing project lacks. Never overwrites.
---

Sync this project's workspace with the plugin's seeds. Seeds are **project-owned after copy** — never overwrite or modify an existing project file without explicit approval. Layout and settings: `${CLAUDE_PLUGIN_ROOT}/workflow/workspace.md`.

1. **Read the Workspace line** (from `CLAUDE.local.md`, else `CLAUDE.md`):

```bash
source "${CLAUDE_PLUGIN_ROOT}/bin/_workspace.sh" . && echo "root=$WS features=$FEATURES committed=$WS_COMMITTED"
```

A project with no Workspace line uses the defaults; offer to add the line to its dev-team section so the settings are visible.

2. **Old layout?** If `$WS/product/`, `$WS/plans/`, or `$WS/tasks/` exists, run `"${CLAUDE_PLUGIN_ROOT}/bin/migrate-layout"` (dry run) and show the plan. On approval, run it with `--apply`, then show `git status`. It moves files with `git mv`, rewrites links, names feature folders per the `folders` setting, and moves finished status rows and closed backlog rows to their archives.

3. **Directories and seeds** (`cp -n` never overwrites):

```bash
mkdir -p "$WS/architecture" "$WS/backlog" "$WS/fixes" "$WS/standards" "$WS/stack" "$FEATURES"
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/stack.md"           "$WS/stack/stack.md"
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/status.md"          "$WS/status.md"
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/status-done.md"     "$WS/status-done.md"
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/triage.md"          "$WS/triage.md"
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/backlog-index.md"   "$WS/backlog/index.md"
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/backlog-archive.md" "$WS/backlog/archive.md"
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/standards/"*.md     "$WS/standards/"
```

**Guest mode** (the dev-team section is in `CLAUDE.local.md`): copy only the process standards — `planning.md`, `documentation.md`, `review.md`. Code conventions (`coding.md`, `testing.md`, `architecture.md`, `design.md`) come from the repo itself; copy one only if the repo documents nothing on that subject and the Owner wants it. `tickets.md` and `checkins.md` are never copied here — `/dev-team:tickets` and `/dev-team:checkins` add them when enabled.

4. **Drift check** on what already existed: `"${CLAUDE_PLUGIN_ROOT}/bin/seed-drift" .` lists what the plugin added since the project's copies were made — seed sections missing from `$WS/standards/*.md`, seed rules missing from the dev-team section (`CLAUDE.md`, or `CLAUDE.local.md` in guest mode), and Orca Runtime-line settings renamed or added (`${CLAUDE_PLUGIN_ROOT}/workflow/orca.md` § Opt in). It compares names only; every other difference is a project customization and always wins.

5. **Report** four lists: **moved** (step 2), **copied** (was missing), **up to date**, **behind** (each `seed-drift` line). For each behind item, offer the fix: append a missing section verbatim from its seed, append a missing rule bullet verbatim from `${CLAUDE_PLUGIN_ROOT}/seeds/CLAUDE.project.md`, or update the Runtime line to the setting it names. Apply only what the user approves. Never delete or rewrite existing content beyond that.

6. Remind the user to fill placeholders in newly copied files and to commit — to the project repo, or, for an uncommitted workspace, nothing to do: the Stop hook commits the workspace's own repository.
