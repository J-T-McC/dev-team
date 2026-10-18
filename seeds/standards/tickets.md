# Ticket System

How this project uses an external ticket system through its MCP server. `System: none` disables all of it. The plugin's `workflow/tickets.md` sets the rules every setting here obeys (who may touch the system, read once, allowlist out). Tune this file freely — `/dev-team:tickets` walks through changes — and log each change below.

## Connection (active)
- **System:** none *(e.g. `linear`, `jira`, `github`)*
- **Via:** mcp *(`mcp` — any tracker with an MCP server; `orca` — Orca's built-in Linear client; `gh` — the GitHub CLI. The CLIs need no MCP server and return less output.)*
- **MCP server:** _TBD_ *(only for `Via: mcp` — the server name as Claude Code lists it)*
- **Workspace / team / project:** _TBD_

## Intake (active)
- **Work query:** _TBD_ *(e.g. team `ENG`, label `dev-team`, status `Ready`; GitHub: `assignee:@me label:dev-team`, or a Project number plus its query)*
- **Routing** — ticket type or label → destination:
  - feature → Product Manager (PRD)
  - bug, chore → Senior Developer fast path (fix record)
  - idea, debt → backlog item
- **On intake, set status to:** _TBD_ *(blank = leave unchanged)*
- **Watch comments:** never *(never | at gates)*

## Status sync (active)
Phase reached → ticket status. Leave a status blank to skip that update.

| Phase | Ticket status |
|---|---|
| Technical Design | In Progress |
| Review | In Review |
| Done | Done |

## Elevation (active)
The allowlist of what leaves `docs/`. Anything not listed here stays in documents.
- **Release comment** on the source ticket when a feature reaches Done (Orchestrator), from the template below.
- **New tickets** from backlog items (Product Manager): `bug` with priority high. *(Add rules, e.g. `debt` filed from review follow-ups.)*
- **Cap:** at most one comment per ticket per phase transition.

## Never elevate (active)
Minor findings, question documents, task completion notes, drafts, self-review notes, anything still in progress.

## Templates (active)

Release comment:
```
Released: <feature> — <one-line outcome>.
Review: <recommendation>; follow-ups: <ticket IDs or none>.
Docs: <PRD path>, <review path> @ <head commit>
```

New ticket:
```
Title: <backlog item name>
Body: <What> — <Why not now>. Source: <doc path>
```

## Tuning log

| Date | Change | Why |
|---|---|---|
