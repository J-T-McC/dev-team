---
description: Set up, tune, or disable the project's ticket-system integration (Linear, Jira, … via MCP) — edits docs/standards/tickets.md with Owner approval.
argument-hint: "[change to make, e.g. 'stop posting release comments']"
---

Configure how this project uses its ticket system. Rules every config obeys: `${CLAUDE_PLUGIN_ROOT}/workflow/tickets.md`. The config is a project-owned standard: show every change as a diff and write only what the user approves. **Never write to the ticket system from this command** — reads only.

Request: $ARGUMENTS

1. **Config file.** If `docs/standards/tickets.md` is missing, copy it: `cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/standards/tickets.md" docs/standards/tickets.md`. Read it.

2. **Pick the mode:**
   - Request asks to turn it off → set `System: none`, log it, done.
   - `System: none` (or the request asks for setup) → **setup**, step 3.
   - Otherwise → **tune**, step 4.

3. **Setup.**
   - Find the available connections: ticket MCP servers in this session (names like `linear`, `atlassian`/`jira`, `github`, `shortcut`, `asana`); Orca's Linear client (`orca linear team list` succeeds); the GitHub CLI (`gh auth status` succeeds). Prefer a CLI where it covers the system. None → tell the user to connect one first, and stop.
   - Ask, one topic at a time, offering real values read from the server where a cheap read can supply them (teams/projects, workflow status names, labels): which system, connection (`Via`), and workspace or repo/Project; the work query; routing by type or label; status on intake; the status-sync table; what to elevate (release comment? which backlog items become tickets?); `Watch comments`.
   - Fill the config. Keep the seed's defaults for anything the user skips.
   - Ensure the project `CLAUDE.md` carries the ticket rule (it is not in the seed; it is added only when tickets are enabled). If missing, propose adding to its rules:

     ```
     - **Ticket system** (only if `docs/standards/tickets.md` enables one): only the orchestrator and product-manager write to it, as that file allows; other roles read a ticket once at intake, then work from `docs/` and file backlog items (dev-team `workflow/tickets.md`).
     ```

4. **Tune.** Map the request to the section it changes (Intake, Status sync, Elevation, Never elevate, Templates). Edit only that section. Reject or rework a change that breaks a rule in `workflow/tickets.md` (e.g. another role writing tickets), saying which rule.

5. **Verify, read-only.** Run the work query once and show how many tickets match plus the first few titles, so the user can confirm the filter. Check that every status the config names exists in the system.

6. **Log and approve.** Add a Tuning log row (date, change, why — in the user's words). Show the diff; write on approval. Remind the user to commit `docs/standards/tickets.md`.
