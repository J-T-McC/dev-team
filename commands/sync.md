---
description: Sync plugin seeds into the project workspace — copies missing standards/stack/status files, reports seed sections missing from existing project files. Never overwrites.
---

Sync this project's workspace with the plugin's seeds. Seeds are **project-owned after copy** — never overwrite or modify an existing project file without explicit approval.

1. Ensure directories exist:

```bash
mkdir -p docs/product docs/design docs/plans docs/tasks docs/backlog docs/fixes docs/questions docs/reviews docs/architecture docs/standards docs/stack
```

2. Copy any seed file the project is missing (`cp -n` skips existing):

```bash
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/standards/"*.md docs/standards/
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/stack.md" docs/stack/stack.md
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/status.md" docs/status.md
cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/backlog-index.md" docs/backlog/index.md
```

3. Drift check on files that already existed: for each `docs/standards/*.md` with a same-named seed, compare `##` headings. List seed headings absent from the project file — these are sections added to the plugin since the project's copy. Ignore all other differences (project customizations always win; do not report them).

4. Report three lists: **copied** (was missing), **up to date** (all seed headings present), **behind** (seed headings missing — name them). For each "behind" file, offer to append the missing seed sections verbatim; append only the sections the user approves. Never delete or rewrite existing content.

5. Remind the user to fill any placeholders in newly copied files and commit the changes to the project repo.
