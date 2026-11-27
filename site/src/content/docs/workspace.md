---
title: Workspace
description: Where the team keeps its documents, how they're named, and guest mode for projects you don't own.
---

Everything the team writes goes in one workspace inside your project. Each feature gets its own folder. Shared material sits at the root.

```
dev-team/                 workspace root
  status.md               work in flight: phase, role, blockers, approvals
  status-done.md          finished work, newest first
  triage.md               requests only a person can do
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

One line in the dev-team section sets the layout:

```
- **Workspace:** `dev-team` · features `dev-team/features` · folders `slug` · committed
```

| Setting | Values | Default |
|---|---|---|
| root (first value) | any folder | `dev-team` (guest mode: `.dev-team`) |
| `features` | any folder, inside the root or not | `<root>/features` |
| `folders` | `slug` for small projects, `F###-slug` for large ones, `<ticket>-slug` for work from tickets | `slug` |
| committed | `committed`, `not committed` | `committed` |
| `just me` | there or not | not there |

A project with no Workspace line uses `docs`, so older projects keep working. Change a setting only together with a move. `/dev-team:sync` moves the files, and also moves an old type-first layout (`docs/product/`, `docs/plans/`) into feature folders.

## Whose project

Setup's first question fills the line in. For a shared project of yours, the section goes in `CLAUDE.md` and the workspace is committed with your code. For one that's yours alone for now (`just me`) or someone else's ([guest mode](#guest-mode)), it goes in `CLAUDE.local.md`, and the workspace keeps its own history outside the repository. With "just me" the conventions are yours. When you want the team in, ask to share dev-team and the workspace moves into your code.

## Small files on purpose

Agents re-read the live files all the time, so finished work moves out to `status-done.md` and `backlog/archive.md`. A live brief, plan or design stays under about 25 KB (`standards/documentation.md` § Size and reading). Past that, a hook warns the agent. Edits replace old text instead of piling up below it, because git keeps the history.

In a features folder shared with other people, the team writes only in folders it created.

## Guest mode

This is for a project you don't own, where the team doesn't use dev-team and mustn't see it. The section goes in `CLAUDE.local.md` and the plugin is installed at local scope. Their `CLAUDE.md`, `.gitignore` and `.claude/settings.json` are never edited. By default the workspace is `.dev-team/`, a hidden folder their agents' searches skip.

Their conventions win, from commits to test commands, and nothing the team writes in their repository or tracker mentions dev-team.

The workspace is listed in `.git/info/exclude` and is a git repository of its own, which a Stop hook commits whenever it changes. Give it a remote (`git -C .dev-team push -u origin HEAD`) and the hook pushes too, so your other machines can pull the specs. Keep feature folders inside the root, or they get no history.

Full rules: [workflow/workspace.md](https://github.com/J-T-McC/dev-team/blob/main/workflow/workspace.md).
