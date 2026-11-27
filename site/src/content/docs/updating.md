---
title: Update and sync
description: Pull plugin changes into a project, then bring the project's own copies up to date.
---

## Update the plugin

```
/plugin marketplace update dev-team
/plugin update dev-team@dev-team
```

Every commit is a new version, and nothing is pinned. Start a new Claude session afterwards so the new skills and hooks load.

To see what changed, read the [commit history](https://github.com/J-T-McC/dev-team/commits/main). Merged features and fixes are also tagged on the [releases page](https://github.com/J-T-McC/dev-team/releases), with notes. A feature raises the minor version, a fix the patch, a breaking change the major.

## Sync the project's copies

Updates never touch what setup copied into your project: the standards, the stack file, the status files and the dev-team section in `CLAUDE.md`. Those are yours, so a file or rule the plugin added later won't be there, and the roles don't fall back to the plugin's copy. Run sync after every update:

```
/dev-team:sync
```

It moves an old type-first workspace into feature folders and rewrites the links, after a dry run you approve. It also copies any seed file the project lacks. Then it reports drift:

- standards sections your copies lack
- rules missing from the dev-team section, or from Team setup if you took the [recommended setup](/dev-team/orca-recommended/)
- Orca Runtime line settings that were renamed or added
- links that point back at a folder containing them, which send tools round in a loop

It compares names only, so your own edits never count as drift. It never overwrites a seed file you have, and adds only what you approve. Commit the result.
