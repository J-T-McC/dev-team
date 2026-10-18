# Check-ins

Scheduled Orca automations that keep work moving. Orca runtime only; rules in the dev-team `workflow/orca.md` § Check-ins. Edit this file, then run `/dev-team:checkins` to apply it. Mark a check-in `(off)` to pause it.

Every check-in reuses its session. Its trigger check runs first and skips the run — at no token cost — when there is nothing to do or another coordinator is active. A run that does go ahead re-sends the whole session, usually with a cold prompt cache, so it costs about the session's size: keep check-in sessions small.

Trigger checks shipped with the plugin: `has-work` (docs changed since its last run), `stalled [hours]` (a worker failed or exited without finishing, or features in flight have not moved for `hours`, default 4), `new-tickets [source]` (tickets newly assigned to you: `linear <team-key> [workspace-id]` via Orca's Linear client — the team is required, so other projects' tickets never trigger this one — `github` issues in this repo, or `github-project <owner> <number> [query]` via `gh`). `always` (no trigger check — runs on every schedule tick; use for rare check-ins whose work needs an MCP server, which a shell check cannot reach). Any other shell command works too: exit 0 runs the check-in.

## advance (active)
- **Schedule:** `*/30 * * * *` (every 30 minutes) *(hourly, daily, weekdays, weekly, a cron expression, or an RRULE; daily/weekdays/weekly take a time `HH:MM`)*
- **Role:** orchestrator
- **Runs when:** has-work
- **Job:** For each feature in flight, answer "what's next?" and dispatch what is ready.
- **May:** act within the project's autonomy level

## stalled (active)
- **Schedule:** hourly
- **Role:** orchestrator
- **Runs when:** stalled 4
- **Job:** Find failed or stuck work. Re-dispatch failed tasks to live peers. Report sessions that are not responding — never restart them.
- **May:** act within the project's autonomy level

## groom (off)
- **Schedule:** weekdays 09:00
- **Role:** product-manager
- **Runs when:** always *(work comes through the project's ticket MCP server; with `Via: orca`, `new-tickets linear <team key>` makes idle days free)*
- **Job:** Triage new tickets assigned to the Owner: route each per `docs/standards/tickets.md`, file backlog items, set priority.
- **May:** flag only

## Tuning log

| Date | Change | Why |
|---|---|---|
