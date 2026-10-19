---
description: Set up, tune, or disable the project's ticket-system integration (Linear, Jira, … via MCP) — edits <ws>/standards/tickets.md with Owner approval.
argument-hint: "[change to make, e.g. 'stop posting release comments']"
---

`<ws>` below is the workspace root: `source "${CLAUDE_PLUGIN_ROOT}/bin/_workspace.sh" . && echo $WS`.

Configure how this project uses its ticket system. Rules every config obeys: `${CLAUDE_PLUGIN_ROOT}/workflow/tickets.md`. The config is a project-owned standard: show every change as a diff and write only what the user approves. **Never write to the ticket system from this command** — reads only.

Request: $ARGUMENTS

1. **Config file.** If `<ws>/standards/tickets.md` is missing, copy it: `cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/tickets.md" <ws>/standards/tickets.md`. Read it.

2. **Pick the mode:**
   - Request asks to turn it off → set `System: none`, log it, done.
   - `System: none` (or the request asks for setup) → **setup**, step 3.
   - Otherwise → **tune**, step 4.

3. **Setup.**
   - Find the available connections: ticket MCP servers in this session (names like `linear`, `atlassian`/`jira`, `github`, `shortcut`, `asana`), with each one's scope from `claude mcp get <name>`; Orca's Linear client (`orca linear team list` succeeds); the GitHub CLI (`gh auth status` succeeds). None → tell the user to connect one first, and stop.
   - Ask whether other projects on this machine must never reach this tracker (e.g. client work next to personal projects). **Yes** → recommend an MCP server at local scope, logged in to this project's workspace only, and explain that Orca's Linear client, `gh`, user-scope servers, and claude.ai connectors are open to every project. To close the Orca path too: disconnect Linear from Orca, or add `"permissions": { "deny": ["Bash(orca linear:*)"] }` to each *other* project's `.claude/settings.json` (not user settings — a deny there would block this project as well). **No** → any connection works; prefer a CLI (`orca`, `gh`) for its narrower output.
   - Ask, one topic at a time, offering real values read from the server where a cheap read can supply them (teams/projects, workflow status names, labels): which system, connection (`Via`), and workspace or repo/Project; the work query; routing by type or label; status on intake; the status-sync table (if the tracker or Orca already moves tickets on its own — e.g. Orca's per-team Linear status sync on worktree creation — leave that status blank so the ticket is not updated twice); what to elevate (release comment? which backlog items become tickets?); `Watch comments`.
   - Fill the config. **Scope is required** — workspace and team/project (and `Account` for `gh`); offer the real values from the connection, and do not enable the integration without them. Keep the seed's defaults for anything else the user skips.
   - Ensure the project `CLAUDE.md` carries the ticket rule (it is not in the seed; it is added only when tickets are enabled). If missing, propose adding to its rules:

     ```
     - **Ticket system** (only if `<ws>/standards/tickets.md` enables one): only the orchestrator and product-manager write to it, as that file allows; other roles read a ticket once at intake, then work from the workspace and file backlog items (dev-team `workflow/tickets.md`).
     ```

4. **Tune.** Map the request to the section it changes (Intake, Status sync, Elevation, Never elevate, Templates). Edit only that section. Reject or rework a change that breaks a rule in `workflow/tickets.md` (e.g. another role writing tickets), saying which rule.

5. **Verify isolation** (when other projects must stay out). With a local-scope MCP server, list the workspaces and teams it can see: anything beyond this project's workspace means the login is broader than the project — tell the user before continuing.

6. **Verify, read-only.** Run the work query once and show how many tickets match plus the first few titles, so the user can confirm the filter — and confirm every result is inside the Scope (team key or repo); any result outside it means the query is not scoped, so fix it before enabling. Check that every status the config names exists in the system.

7. **Log and approve.** Add a Tuning log row (date, change, why — in the user's words). Show the diff; write on approval. Remind the user to commit `<ws>/standards/tickets.md`.
