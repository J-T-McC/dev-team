---
description: Sync plugin seeds into the project workspace — moves an old type-first layout to feature folders, copies missing files, reports seed sections, rules, and settings an existing project lacks. Never overwrites.
---

Sync this project's workspace with the plugin's seeds. Seeds are **project-owned after copy** — never overwrite or modify an existing project file without explicit approval. Layout and settings: `${CLAUDE_PLUGIN_ROOT}/workflow/workspace.md`.

1. **Read the Workspace line** (from `CLAUDE.local.md`, else `CLAUDE.md`):

```bash
source "${CLAUDE_PLUGIN_ROOT}/bin/_workspace.sh" . && echo "root=$WS features=$FEATURES committed=$WS_COMMITTED mode=$WS_MODE"
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
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/friction-log.md"    "$WS/friction-log.md"
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/backlog-index.md"   "$WS/backlog/index.md"
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/backlog-archive.md" "$WS/backlog/archive.md"
for f in planning documentation review coding testing architecture design; do  # only those that apply, below
  cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/standards/$f.md" "$WS/standards/"
done
```

Copy only the standards that apply. `design.md` only when the project has a user interface or will have one (its stack or features say so). **Guest mode** (`mode=guest`): copy only the process standards — `planning.md`, `documentation.md`, `review.md`. Code conventions (`coding.md`, `testing.md`, `architecture.md`, `design.md`) come from the repo itself; copy one only if the repo documents nothing on that subject and the Owner wants it. `tickets.md` and `checkins.md` are never copied here — `/dev-team:tickets` and `/dev-team:checkins` add them when enabled.

4. **Drift check** on what already existed: `"${CLAUDE_PLUGIN_ROOT}/bin/seed-drift" .` lists what the plugin added since the project's copies were made — seed sections missing from `$WS/standards/*.md`, workspace files missing, seed rules missing from the dev-team section (`CLAUDE.md`, or `CLAUDE.local.md` in guest mode) and from its Team setup section when the project took the recommended Orca setup, Orca Runtime-line settings renamed or added (`${CLAUDE_PLUGIN_ROOT}/workflow/orca.md` § Opt in), and links inside the workspace to a folder that contains them (a loop for every tool that walks it). It compares names only; every other difference is a project customization and always wins.

5. **Report** four lists: **moved** (step 2), **copied** (was missing), **up to date**, **behind** (each `seed-drift` line). For each behind item, offer the fix: append a missing section verbatim from its seed, append a missing rule bullet verbatim from `${CLAUDE_PLUGIN_ROOT}/seeds/CLAUDE.project.md` (a Team setup rule from `${CLAUDE_PLUGIN_ROOT}/seeds/orca-recommended.md`), or update the Runtime line to the setting it names. Apply only what the user approves. Never delete or rewrite existing content beyond that.

6. **Under the Orca runtime** with no `## Team setup` section in the dev-team section, end the report with one line: the recommended setup is available with `/dev-team:orca recommended` (`${CLAUDE_PLUGIN_ROOT}/workflow/orca-recommended.md`). An offer, not drift. With the section, `seed-drift` reports any rule it lacks.

7. Offer to commit what was copied, for a committed workspace. An uncommitted one needs nothing: the Stop hook commits the workspace's own repository, and pushes it once it has an upstream. Sections marked _open_ in copied files are not homework: the first plan that needs one sets it.
