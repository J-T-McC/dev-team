---
description: Sync plugin seeds into the project workspace — moves an old type-first layout to feature folders, copies missing files, reports seed sections missing from existing standards. Never overwrites.
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

4. **Drift check** on files that already existed: for each `$WS/standards/*.md` with a same-named seed, compare `##` headings. List seed headings absent from the project file — sections added to the plugin since the project's copy. Ignore all other differences (project customizations always win).

5. **Report** four lists: **moved** (step 2), **copied** (was missing), **up to date**, **behind** (seed headings missing — name them). For each "behind" file, offer to append the missing sections verbatim; append only what the user approves. Never delete or rewrite existing content.

6. Remind the user to fill placeholders in newly copied files and to commit — to the project repo, or, for an uncommitted workspace, nothing to do: the Stop hook commits the workspace's own repository.
