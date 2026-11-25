---
description: Set up or refresh the Owner board — a live claude.ai page of what needs the Owner, who is on what, and work in flight.
argument-hint: "[change, e.g. 'link tickets to Jira']"
---

`<ws>` below is the workspace root: `source "${CLAUDE_PLUGIN_ROOT}/bin/_workspace.sh" . && echo $WS`.

Set up the project's Owner board. Rules: `${CLAUDE_PLUGIN_ROOT}/workflow/board.md`.

Request: $ARGUMENTS

1. **Preconditions.** This session has the `Artifact` and `ArtifactData` tools (claude.ai artifacts). Otherwise stop and say so; under the Orca runtime, Orca's worktree cards (`workflow/orca.md` § Worktree cards) are the lighter fallback.

2. **New or refresh.** The dev-team section (`CLAUDE.md`, or `CLAUDE.local.md` in guest mode) has an `**Owner board:** <url>` line → refresh: read that artifact (`Artifact` `read`) and republish the current template to the same URL in step 4, omitting `capabilities` so its data and rules carry over. Otherwise create a new board.

3. **Config** — ask once, offering defaults, and keep current values on a refresh unless the request changes them:
   - **Project name** for the title (default: the repository's folder name).
   - **How the board names the Owner** in "Waiting on …" (default `you`).
   - **Ticket link base**, with the ticket ID appended: from `<ws>/standards/tickets.md` § Scope when a system is configured — Linear `https://linear.app/<workspace>/issue/`, GitHub `https://github.com/<owner/repo>/issues/`, Jira `https://<site>/browse/` — else none (IDs show as plain text).
   - **Repository** for PR links: `gh repo view --json nameWithOwner -q .nameWithOwner`. Work in other repos: the short names rows will use, mapped to `owner/name` (`repos`).

4. **Publish.** Copy `${CLAUDE_PLUGIN_ROOT}/templates/board.html` to the scratchpad, replace both `{{PROJECT}}` with the project name, and publish it with the `Artifact` tool: icon `board`, a one-line description, and on a new board `capabilities: {"db": {"rules": [{"path": "", "read": "view", "write": "owner"}]}, "user": {}}` — viewers read, only the Owner (and the coordinator writing as them) changes data.

5. **Status first.** `"${CLAUDE_PLUGIN_ROOT}/bin/board-drift" --status <ws>/status.md` lists the rows whose PRs have all merged or closed. Bring those rows up to date — or move them to `status-done.md` — before seeding, so the board does not start from stale rows; a row whose outcome the workspace logged elsewhere gets the same fix.

6. **Seed** with one `ArtifactData` `batch`: `meta/config` (`owner`, `ticketUrl`, `repo`, `repos` — omit empty ones), `meta/board.updated`, one `work` row per `<ws>/status.md` row, one `asks` row per pending ✋ gate or feature blocked on the Owner (a gate the Owner has parked is a `held` row, with no ask), and `peers` rows (under Orca, `peer list --board-json <dir>` writes them as files for `file_path`). A new board with nothing in flight starts empty.

7. **Verify and stamp.** `ArtifactData` `list` each collection with `out_dir` and confirm the rows match `<ws>/status.md`, then `"${CLAUDE_PLUGIN_ROOT}/bin/peer" board-stamp --rows <the work rows' dir>`.

8. **Record.** New board: add `- **Owner board:** <url> — the orchestrator keeps it current (dev-team workflow/board.md).` to the dev-team section. Show the diff; write on approval.

9. Give the Owner the link and offer to pin it (`Artifact` `pin`) — it is a page they will keep reopening.
