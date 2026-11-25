---
title: Update and sync
description: Pull plugin changes into a project, then bring the project's own copies up to date.
---

## Update the plugin

```
/plugin marketplace update dev-team
/plugin update dev-team@dev-team
```

Every commit to the repository is a new version, and nothing is pinned. Start a new Claude session afterwards so the new skills and hooks load.

## Sync the project's copies

Updates never touch what bootstrap copied into your project: the standards, the stack file, the status files and the dev-team section in `CLAUDE.md`. Those files are yours. The catch is that a project set up before the plugin added a file or a rule simply doesn't have it, and the roles have no fallback to the plugin's copy. So run sync after every update:

```
/dev-team:sync
```

Sync moves a workspace in the old type-first layout (`docs/product/`, `docs/plans/` and so on) into feature folders. It shows you a dry run first, then moves the files with `git mv` and rewrites the links. It copies any seed file the project lacks and never overwrites one it has.

Then it reports drift:

- sections in the plugin's standards that your copies lack;
- rules missing from the dev-team section;
- settings on the Orca Runtime line that were renamed or added;
- rules missing from the Team setup section, if you took the [recommended setup](/dev-team/orca-recommended/);
- links inside the workspace that point back at a folder containing them, which send any tool walking the workspace round in a loop.

It compares names only, so your own edits never count as drift. It adds only what you approve. Commit the result.

A project on the Orca runtime without the recommended setup gets one line at the end saying `/dev-team:orca recommended` can add it.

## What changed

The [commit history](https://github.com/J-T-McC/dev-team/commits/main) lists every change, and releases have notes on the [releases page](https://github.com/J-T-McC/dev-team/releases).
