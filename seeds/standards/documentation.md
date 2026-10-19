# Documentation Standards

## Active conventions
- One document per feature per type; always start from the dev-team plugin's `templates/`.
- Layout and naming: dev-team `workflow/workspace.md` — one folder per feature; shared ADRs, backlog, fixes, standards, and stack in `<ws>/`.
- Live indexes hold only live rows: finished features move to `<ws>/status-done.md`, closed backlog items to `<ws>/backlog/archive.md`.
- Every artifact carries Status, Author, Approval, and a Handoff section (plugin `workflow/handoffs.md`).
- Link, never duplicate. If a section exceeds roughly a page, split the feature.
- Approvals are recorded in the artifact **and** `<ws>/status.md`.

## Write dense
Agents re-read these documents many times and people have to skim them; every word is paid for repeatedly.
- Plain English: short sentences, common words. Say what was done or what is needed, then stop.
- One line per fact. Tables and bullets over prose; sentence fragments are fine.
- No filler ("it is important to note…"), no restating upstream content — link it.
- Say it once: if a fact lives in another artifact or section, reference it.
- Dense ≠ cryptic: names, criteria, and decisions stay explicit and testable.

## Placeholders (customize per project)

### Diagrams
_TBD — tool and format (e.g. Mermaid in markdown)._

### Document lifecycle
_TBD — archival policy for superseded documents._
