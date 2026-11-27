# Planning Standards

> Owned by the Principal Engineer's task-breakdown process; customize thresholds per project.

## Task sizing (active)
- One sitting, one concern, independently verifiable.
- One file per task: `<feature>/tasks/T<NN>-<slug>.md`; `index.md` holds the status table and dependency order.
- Every task lists: dependencies, files, acceptance criteria, testing.
- Every task traces to a technical plan element; every plan element maps to at least one task.
- No task may depend on a later task.

## Backlog (active)
Work that is real but not now. Canonical structure — one index, one file per item:
- `<ws>/backlog/index.md` — open items only: the status table (ID, item, type, priority, status) plus the promotion log. Never a dump of item detail.
- `<ws>/backlog/archive.md` — done and dropped items, newest first, moved there by the Product Manager.
- `<ws>/backlog/B<NNN>-<slug>.md` (three digits: `B001`) — one item: what, why not now, promotion trigger, links to its source.
- The index is seeded once (`<ws>/backlog/index.md`); each item starts from the plugin's `templates/backlog-item.md`. IDs are sequential and never reused.

Rules:
- **Any role files** an item (feature idea, deferred scope, tech debt, known bug not being fixed now); the **Product Manager owns the index** — priority, status, and promotion.
- **The index's row order is the rank,** top first; re-ranking moves rows there, never notes in item files. An item waiting on the Owner (the floor, `workflow/handoffs.md` § Autonomy) sits last, marked *parked*, so nothing queues behind it.
- One item per row and per file; an item too large to state in a few lines is a feature — file it as a feature item and let it become a PRD.
- Promotion is the only exit into work: `feature` → PM writes a PRD (pipeline); `bug`/`debt` → Owner delegates to the Senior Developer (fast path); with Next work `steered`, the PM promotes them itself. Record the destination in the promotion log and flip Status.
- The backlog is not a queue or a status board: `<ws>/status.md` tracks work in flight, the backlog tracks work not started. An item leaves the backlog the moment it enters either path.
- Not in the backlog: review follow-ups (they stay in the review record until the Owner acts on them), and open questions (they are question docs).

## Steering (active)
How the Product Manager picks the next item when the project's Next work is `steered` (dev-team `workflow/handoffs.md` § Next work). Tune the mix to the project.
- **Bugs that hurt users first,** then tickets from the work query (the Owner's priorities) ahead of backlog items of the same priority.
- **About one cleanup item for every two features:** enough that the code doesn't rot, not so much that nothing new ships. A debt item blocking the next feature goes first. The count starts with the first feature on the default branch: before there's code there's nothing to clean, and a cleanup item is never invented to meet the mix.
- **Small before large** at the same priority, so something finishes every day or so.
- Each pick gets one line of why, in the PM's report.

## Agent limits (active)
What agents in this project cannot do; the Product Manager checks every request against it before triage, and any role that hits one mid-work stops and marks the feature blocked on the Owner.
- Anything on the autonomy floor: deploys and releases outside the repo, payments, deleting or migrating existing data, security-sensitive changes the Owner has not signed.
- Steps that need a person: meetings, sign-offs, stakeholder or customer conversations.
- Systems agents cannot reach in this project, and work the team keeps for people: none listed yet. Add them as they come up.

## Estimation
None: work is sized as tasks instead (§ Task sizing).

## Definition of done
Acceptance criteria met, tests written and passing, completion notes recorded in the task file, status flipped in the index.
