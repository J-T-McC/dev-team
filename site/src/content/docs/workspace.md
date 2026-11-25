---
title: Workspace
description: Where the team keeps its documents, how they're named, and guest mode for projects you don't own.
---

Everything the team writes goes in one workspace inside your project. Each feature gets one folder holding everything it produces. Shared material (status, ADRs, backlog, fixes, standards, stack) sits at the workspace root.

```
docs/                     workspace root
  status.md               work in flight: phase, role, blockers, approvals, path
  status-done.md          finished work, newest first
  triage.md               requests only a person can do, with the reason
  friction-log.md         what slowed the team down
  architecture/           ADRs: adr-001-session-storage.md
  backlog/                index.md, archive.md, B001-bulk-import.md
  fixes/                  2026-10-18-login-timeout.md
  standards/  stack/
  features/               (can live anywhere)
    user-auth/            brief.md or prd.md, discovery.md, design.md, mockups/,
                          plan.md, tasks/, questions/, review.md
```

## The Workspace line

One line in the dev-team section of `CLAUDE.md` sets the layout:

```
- **Workspace:** `docs` · features `docs/features` · folders `slug` · committed
```

| Setting | Values | Default |
|---|---|---|
| root (first value) | any folder | `docs` (guest mode: `.dev-team`) |
| `features` | any folder, inside the root or not | `<root>/features` |
| `folders` | `slug`, `F###-slug`, `<ticket>-slug` | `slug` |
| committed | `committed`, `not committed` | `committed` |

Use `slug` on small projects, `F###-slug` on large ones with many features, and `<ticket>-slug` when work comes from tickets. Change a setting only together with a move: `/dev-team:sync` moves the files.

## Small files on purpose

Agents re-read the live files constantly, so those stay small. At Done, a feature's row moves from `status.md` to the top of `status-done.md`, and finished backlog items move to `backlog/archive.md`. The archives cost nothing until someone opens them.

Names sort and never collide: three-digit backlog items and ADRs (`B001`, `adr-001`), two-digit tasks (`T01`), three-digit questions (`q001`), and fixes that start with their date. A feature's handoff lists related features by folder name and the ADRs it made or follows, so agents follow links instead of searching. If the features folder is shared with other people's folders, the team writes only in folders it created.

## Guest mode

Guest mode is for a project dev-team doesn't own, where the team doesn't use it and mustn't see it.

The dev-team section goes in `CLAUDE.local.md`, which is never committed, and the plugin is installed at local scope. Their `CLAUDE.md`, `.gitignore` and `.claude/settings.json` are never edited. The workspace defaults to `.dev-team/`, a hidden folder their own agents' searches skip.

Their conventions win for commits, branches, PRs, code style, reviews and test commands. The workspace's standards record only what their repository doesn't already document. Code, comments, commit messages, PRs and ticket comments never mention dev-team, its roles or its paths, since teammates couldn't follow those links anyway.

The workspace can be committed with their code or not. Not committed, it's listed in `.git/info/exclude` and becomes its own git repository, so its history is kept, and a Stop hook commits it whenever it changes. Give that repository a remote (`git -C .dev-team push -u origin HEAD`) and the hook pushes it too, so your other machines can pull the specs. Keep feature folders inside the root in that case: folders outside it are excluded too, but get no history. New git worktrees don't contain an uncommitted workspace, so peers working in one use the main checkout's workspace by its full path.

## Moving an older project

Projects set up before feature folders use a type-first layout (`docs/product/`, `docs/plans/` and so on). `/dev-team:sync` spots it and runs `migrate-layout`: a dry run first, then, once you approve, it moves the files with `git mv`, rewrites links, names the feature folders, and splits finished rows into `status-done.md`.
