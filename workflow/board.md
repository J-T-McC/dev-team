# Owner Board (optional)

A live page for the Project Owner: what needs them, who is on what, and every piece of work in flight. Once several roles run at once, the coordinator's conversation moves too fast to follow and the workspace documents are written for agents, not people — the board is the Owner's view. `<ws>/status.md` stays the source of truth: the board is derived from it (and from the task indexes and PRs, § Work rows), and no role reads the board for state.

Works under either runtime. It needs Claude Code's claude.ai artifacts (the `Artifact` and `ArtifactData` tools). Set up with `/dev-team:board`; it is on when the project's dev-team section has an `**Owner board:** <url>` line. This file is the canonical home of the rules below.

## Data

A private claude.ai artifact with its own database. The page (`${CLAUDE_PLUGIN_ROOT}/templates/board.html`) only reads; the orchestrator writes, with `ArtifactData`.

| Path | One document per | Fields |
|---|---|---|
| `asks/<id>` | question or approval waiting on the Owner | `ticket`, `question` — one plain sentence: the decision needed and why — `order` |
| `peers/<id>` | role session: an Orca home, or under the default runtime the role now running | `name` (an Orca home's name, `workflow/orca.md` § Topology), `role`, `doing` (current task, or `Idle`), `order` — under Orca, `peer list --board-json <dir>` writes one file per home, for `ArtifactData` `file_path` |
| `work/<id>` | piece of work in flight with one owner and at most one PR (§ Work rows); id = ticket ID, feature folder, or `<feature folder>/<task ID>` | `ticket`, `title`, `group`, `group_order`, `peer` (the home or role on it now), `pr`, `repo` (only when not the config's), `state`, `next` |
| `meta/board` | — | `updated` (ISO time of the last write) |
| `meta/config` | — | `owner` (how the board names the Owner; default "you"), `ticketUrl` (the ticket ID is appended), `repo` (`owner/name`), `repos` (short names a row's `repo` may use, e.g. `{"mobile": "acme/mobile-app"}`) |

`state` is one of: `planning` (Requirements through Technical Design), `building`, `review`, `fixing` (review findings or a failed check), `ready` (reviewed, checks green), `owner` (waiting on the Owner — it also has an `asks` row), `blocked`, `queued`, `held` (the Owner's hold — no `asks` row, shown muted), `done`.

## Work rows

A row is what one owner is doing, so the Owner can see who has which PR and where it stands.

- **Before tasks exist** (planning, or a ticket with no plan), the feature or ticket is one row.
- **From the task list on**, each task that has started, or has a PR, is a row of its own: the developer or reviewer on it, its PR, its state. Tasks not started get no row. The feature's own row is dropped while any of its tasks has one, and comes back when none does: a whole-feature review, or tasks waiting for a developer.
- **A stack** of PRs for one task or ticket is one row per PR, its `next` naming the stack.
- **`group`** is the feature's name for task rows, so a feature's tasks sit together; ticket work uses the project's own grouping (area, epic or milestone). `group_order` follows the backlog index order.
- **Sources.** `<ws>/status.md` for features, phases and a feature row's `next`, the feature's `tasks/index.md` for tasks, the PR records (`peer prs`, `gh`) for PR state.

## Rules

- **Same turn as `<ws>/status.md`.** Every status change, dispatch, settlement, and question routed to the Owner updates the board in the same turn — one `ArtifactData` `batch`, including `meta/board.updated`. The Owner trusts the board; a lagging one is worse than none.
- **Asks come and go at once.** A question or approval for the Owner becomes an `asks` row the moment it is routed to them, and its work row goes to `owner`. The row is deleted in the turn the answer arrives.
- **Held is the Owner's.** When the Owner says to wait — "leave it until I've looked", or a gate they park — the row goes to `held`, its `asks` row is deleted, `next` says what it waits for, and nobody asks again. Only the Owner takes it out of `held`. The `<ws>/status.md` row says the same in Blockers (`held by the Owner: <what for>`).
- **Stacked PRs:** a row's `next` names its stack (`merges with #415 and #418`); a lower PR stays `ready` until the whole stack merges together (`<ws>/standards/coding.md` § Stacked PRs).
- **Done rows** stay `done` until the Owner has seen them, then are deleted — at the latest the next day.
- **Stamp every write.** After each board write, `${CLAUDE_PLUGIN_ROOT}/bin/peer board-stamp` records that the board matches `<ws>/status.md` and `status-done.md` now. While either has changed since the stamp, the plugin's Stop hook sends the coordinator's turn back once and its prompt hook says so — keeping the board current never depends on remembering. The hook acts in the checkout the stamp came from, and under Orca only in the coordinator's session.
- **Read cheaply, fix drift.** Read rows with an `ArtifactData` `list` using `out_dir` (files, not context), then `peer board-stamp --rows <dir>`. `${CLAUDE_PLUGIN_ROOT}/bin/board-drift <dir>` prints the work rows whose PR moved on its own — merged, a failed check, marked ready or back to draft — fix only those; a `held` row moves only when its PR merges or closes. Under Orca `peer watch` runs it on that directory each time it wakes. Otherwise run it whenever the coordinator wakes and before answering the Owner on status.
- **Status drifts too.** Rows with no PR are never checked, and `<ws>/status.md` itself goes stale when a PR merges or an outcome is logged elsewhere. `board-drift --status <ws>/status.md` lists the rows whose PRs (`#123`, `repo#123`, `repo #123`) have all merged or closed, whose task count disagrees with the feature's task index, or whose cells have grown into a log — update or move them before seeding a board, and whenever board-drift runs. Repo names go through `meta/config`'s `repos`, read from the rows the last `peer board-stamp --rows` recorded (or `--config`); a row naming a repo it cannot place is listed as not checked: reword it (`#123`, or `repo#123`).
- **Only the orchestrator writes.** Roles report through their normal channels; peers never touch the board.
- **Pre-authorized.** Turning the board on approves these writes; they are not floor actions (`workflow/handoffs.md` § Autonomy). The board stays private unless the Owner shares it, and nothing secret goes on it.
