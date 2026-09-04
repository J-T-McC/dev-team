# Planning Standards

> Owned by the Principal Engineer's task-breakdown process; customize thresholds per project.

## Task sizing (active)
- One sitting, one concern, independently verifiable.
- One file per task: `docs/tasks/<feature-slug>/T<NN>-<slug>.md`; `index.md` holds the status table and dependency order.
- Every task lists: dependencies, files, acceptance criteria, testing.
- Every task traces to a technical plan element; every plan element maps to at least one task.
- No task may depend on a later task.

## Backlog (active)
Work that is real but not now. Canonical structure — one index, one file per item:
- `docs/backlog/index.md` — the status table (ID, item, type, priority, status) plus the promotion log. Never a dump of item detail.
- `docs/backlog/B<NN>-<slug>.md` — one item: what, why not now, promotion trigger, links to its source.
- The index is seeded once (`docs/backlog/index.md`); each item starts from the plugin's `templates/backlog-item.md`. IDs are sequential and never reused.

Rules:
- **Any role files** an item (feature idea, deferred scope, tech debt, known bug not being fixed now); the **Product Manager owns the index** — priority, status, and promotion.
- One item per row and per file; an item too large to state in a few lines is a feature — file it as a feature item and let it become a PRD.
- Promotion is the only exit into work: `feature` → PM writes a PRD (pipeline); `bug`/`debt` → Owner delegates to the Senior Developer (fast path). Record the destination in the promotion log and flip Status.
- The backlog is not a queue or a status board: `docs/status.md` tracks work in flight, the backlog tracks work not started. An item leaves the backlog the moment it enters either path.
- Not in the backlog: review follow-ups (they stay in the review record until the Owner acts on them), and open questions (they are question docs).

## Estimation
_TBD — whether estimates are used at all._

## Definition of done
_TBD — default: acceptance criteria met, tests written and passing, completion notes recorded in the task file, status flipped in the index._
