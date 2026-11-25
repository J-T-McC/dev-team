# Friction log

Problems with how the team works, logged as they happen and fixed as maintenance, so the same mistake does not come back and the Owner does not have to stop work to correct it. The log is `<ws>/friction-log.md`; this file is the canonical home of its rules.

## What counts

- **Instructions** — `CLAUDE.md`, skills, the plugin and its templates, memories, specs: wrong, stale, contradictory, or missing.
- **How the team runs** — handoffs, reviews, dispatch, CI, test runs, previews, helpers that do not do what they should.
- **Slowdowns** — waits, reruns, stalled jobs, steps that take longer than they should.
- **Token burns** — long reads, repeated work, costly loops, output nobody needed, a session start made heavy by project context no role uses (`CLAUDE.md`, skills, MCP servers, hook output).
- **Repeated problems in the product work** — the same kind of UX miss, bug, wrong assumption, or review finding again.
- **Course corrections** — any time the Owner stops work to correct it.

## Logging

- **Any role logs friction in the same turn it hits it.**
- **Number a new entry by re-reading the file just before writing,** then taking the next free number: roles write at the same time. When an entry already covers it, raise that entry's count and add one line instead.
- **Each entry gives:** the area (from the list above), what happened, what it cost (the Owner's time, tokens, a delay), the cause in the workflow, how many times, and what changed — or `open`.
- **Every report ends with one line:** `Friction: none`, or what was logged (`Friction: logged #12; +1 on #7`).

```
## 7. A plan named a test helper that does not exist
- **Area:** instructions (plan and task files)
- **What happened:** T02 said to use `UserFactory`; there is none, and the developer wrote one.
- **Cost:** one failed run, about 20k tokens.
- **Cause:** the plan named the helper without opening it.
- **Times:** 2
- **Changed:** open
```

## Fixing

Fixing is maintenance, done by the orchestrator (the coordinator under the Orca runtime): between features, or when the Owner asks, pick the entry that stands out — it keeps repeating, or it costs the most — and change the workflow so it stops: a rule in the project's `CLAUDE.md` or `CLAUDE.local.md`, a spec template, a helper script, a memory. Record the change in the entry, and tell the Owner in one line.

- Changes to checked-in files that agents load (`CLAUDE.md`, `AGENTS.md`, project skills) go to the Owner first: they reach everyone on the repository.
- A fix that belongs in the dev-team plugin itself goes to the Owner as a suggestion for it.
