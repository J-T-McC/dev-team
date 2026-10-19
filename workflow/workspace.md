# Workspace

Where dev-team keeps its documents, how they are named, and how it lives inside a project it does not own. Canonical for layout and naming; other files write `<ws>/…` for the workspace root and `<feature>/…` for the current feature's folder.

## The Workspace line

One line in the project's dev-team section — `CLAUDE.md`, or `CLAUDE.local.md` in guest mode — sets everything:

```
- **Workspace:** `docs` · features `docs/features` · folders `slug` · committed
```

| Setting | Values | Default |
|---|---|---|
| root (first value) | any folder | `docs` (guest mode: `.dev-team`) |
| `features` | any folder, inside or outside the root | `<root>/features` |
| `folders` | `slug`, `F###-slug`, `<ticket>-slug` | `slug` |
| committed | `committed`, `not committed` | `committed` |

No line means `docs`, `docs/features`, `slug`, committed. Change a setting only together with a migration (`/dev-team:sync` moves files).

## Layout

```
<ws>/
  status.md            features in flight: phase, role, blockers, approvals
  status-done.md       finished features, newest first
  architecture/        ADRs, shared by all features: adr-001-session-storage.md
  backlog/             index.md (open items), archive.md (done, dropped), B001-bulk-import.md
  fixes/               fast-path records: 2026-10-18-login-timeout.md
  standards/           project conventions (tickets.md, checkins.md only when enabled)
  stack/stack.md
<features>/
  <feature folder>/    e.g. user-auth/, F014-user-auth/, ENG-123-user-auth/
    prd.md
    design.md  mockups/
    plan.md
    tasks/       index.md  T01-users-table.md
    questions/   q001-session-lifetime.md
    review.md
```

- **One folder per feature** holds everything that feature produces. ADRs stay in `<ws>/architecture/` because they outlive the feature that made them; the plan links them.
- **Indexes hold only live rows.** At Done, the Orchestrator moves the feature's row from `status.md` to the top of `status-done.md` (feature, date, outcome, folder). The Product Manager moves done and dropped backlog rows to `backlog/archive.md`. Agents re-read the live files constantly; the archives cost nothing until someone opens them.
- **Names sort and never collide.** Backlog IDs are three digits (`B001`), ADRs three digits, tasks two (`T01`), questions three (`q001`), fixes start with their date. Feature folders follow the `folders` setting; `F###` numbers are assigned by the Product Manager in PRD order.
- **Link, don't search.** A feature's Handoff lists **Related** features by folder name and the ADRs its plan made or follows.
- **Write only in folders dev-team made.** If the features location is shared with other people's folders, never write into one you did not create; on a name clash, pick a different name.

## Guest mode

For a project dev-team does not own: the team does not use dev-team, so it must not show up in their work.

- **Invisible to them.** The dev-team section goes in `CLAUDE.local.md` (never committed); the plugin is installed at local scope. Never edit their `CLAUDE.md`, `.gitignore`, or `.claude/settings.json`. Default root `.dev-team/` — a hidden folder their agents' searches skip.
- **Their conventions win.** Commit format, branches, PRs, code style, review process, test commands: whatever their repo says. `<ws>/standards/` records only what their repo does not already document — a standard missing from it means: follow the repo.
- **No trace outside the workspace.** Code, comments, commit messages, PRs, and ticket comments never mention dev-team, its roles, or workspace paths — teammates cannot follow those links. Task-to-commit mapping lives in the task files, not in their history.
- **Committed or not.** `committed`: the workspace is versioned with their code. `not committed`: the root (and any feature folders outside it) are listed in `.git/info/exclude`, the workspace root is its own git repository so history is kept, and the plugin's Stop hook commits it whenever it changed.
- **Keep feature folders inside the root when not committed.** Only the root is its own repository; feature folders placed elsewhere are excluded too, but have no history.
- **Worktrees.** An uncommitted workspace is not in new git worktrees; peers there use the main checkout's workspace by absolute path.

## Moving an existing project

Older projects use the type-first layout (`docs/product/`, `docs/plans/`, …). `/dev-team:sync` detects it and runs `${CLAUDE_PLUGIN_ROOT}/bin/migrate-layout` — a dry run first, then `--apply` on the Owner's approval. It moves files with `git mv`, rewrites links, assigns folder names, and splits finished rows into `status-done.md`.
