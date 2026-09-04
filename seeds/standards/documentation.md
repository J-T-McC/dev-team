# Documentation Standards

## Active conventions
- One document per feature per type; always start from the dev-team plugin's `templates/`.
- Naming: `<feature-slug>-<type>.md`; tasks `docs/tasks/<feature-slug>/` (`index.md` + `T<NN>-<slug>.md`); ADRs `adr-<NNN>-<slug>.md`; questions `<feature-slug>-q<NNN>.md`; backlog `docs/backlog/` (`index.md` + `B<NN>-<slug>.md`).
- Every artifact carries Status, Author, Approval, and a Handoff section (plugin `workflow/handoffs.md`).
- Link, never duplicate. If a section exceeds roughly a page, split the feature.
- Approvals are recorded in the artifact **and** `docs/status.md`.

## Write dense
Agents re-read these documents many times; every word is paid for repeatedly.
- One line per fact. Tables and bullets over prose; sentence fragments are fine.
- No filler ("it is important to note…"), no restating upstream content — link it.
- Say it once: if a fact lives in another artifact or section, reference it.
- Dense ≠ cryptic: names, criteria, and decisions stay explicit and testable.

## Placeholders (customize per project)

### Diagrams
_TBD — tool and format (e.g. Mermaid in markdown)._

### Document lifecycle
_TBD — archival policy for superseded documents._
