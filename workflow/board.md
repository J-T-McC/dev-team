# Owner Board (optional)

A live page for the Project Owner: what needs them, who is on what, and every piece of work in flight. Once several roles run at once, the coordinator's conversation moves too fast to follow and the workspace documents are written for agents, not people — the board is the Owner's view. `<ws>/status.md` stays the source of truth: the board is derived from it, and no role reads the board for state.

Works under either runtime. It needs Claude Code's claude.ai artifacts (the `Artifact` and `ArtifactData` tools). Set up with `/dev-team:board`; it is on when the project's dev-team section has an `**Owner board:** <url>` line. This file is the canonical home of the rules below.

## Data

A private claude.ai artifact with its own database. The page (`${CLAUDE_PLUGIN_ROOT}/templates/board.html`) only reads; the orchestrator writes, with `ArtifactData`.

| Path | One document per | Fields |
|---|---|---|
| `asks/<id>` | question or approval waiting on the Owner | `ticket`, `question` — one plain sentence: the decision needed and why — `order` |
| `peers/<id>` | role session: an Orca home, or under the default runtime the role now running | `name`, `role`, `doing` (current task, or `Idle`), `order` |
| `work/<id>` | feature or ticket in flight; id = feature folder or ticket ID | `ticket`, `title`, `group`, `group_order`, `peer`, `pr`, `repo` (only when not the config's), `state`, `next` |
| `meta/board` | — | `updated` (ISO time of the last write) |
| `meta/config` | — | `owner` (how the board names the Owner; default "you"), `ticketUrl` (the ticket ID is appended), `repo` (`owner/name`) |

`state` is one of: `planning` (Requirements through Technical Design), `building`, `review`, `fixing` (review findings or a failed check), `ready` (reviewed, checks green), `owner` (waiting on the Owner — it also has an `asks` row), `blocked`, `queued`, `done`.

## Rules

- **Same turn as `<ws>/status.md`.** Every status change, dispatch, settlement, and question routed to the Owner updates the board in the same turn — one `ArtifactData` `batch`, including `meta/board.updated`. The Owner trusts the board; a lagging one is worse than none.
- **Asks come and go at once.** A question or approval for the Owner becomes an `asks` row the moment it is routed to them, and its work row goes to `owner`. The row is deleted in the turn the answer arrives.
- **Stacked PRs:** a row's `next` names its stack (`merges with #415 and #418`); a lower PR stays `ready` until the whole stack merges together (`<ws>/standards/coding.md` § Stacked PRs).
- **Done rows** stay `done` until the Owner has seen them, then are deleted — at the latest the next day.
- **Read cheaply, fix drift.** Read rows with an `ArtifactData` `list` using `out_dir` (files, not context). `${CLAUDE_PLUGIN_ROOT}/bin/board-drift <dir>` prints the work rows whose PR moved on its own — merged, a failed check, marked ready — fix only those. Run it whenever the coordinator wakes (under Orca, after every `peer watch`) and before answering the Owner on status.
- **Only the orchestrator writes.** Roles report through their normal channels; peers never touch the board.
- **Pre-authorized.** Turning the board on approves these writes; they are not floor actions (`workflow/handoffs.md` § Autonomy). The board stays private unless the Owner shares it, and nothing secret goes on it.
