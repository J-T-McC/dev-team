---
description: Set up or change the project's scheduled Orca check-ins — edits docs/standards/checkins.md and makes Orca's automations match it.
argument-hint: "[change, e.g. 'add a nightly review check-in']"
---

Apply the project's check-in config to Orca. Rules: `${CLAUDE_PLUGIN_ROOT}/workflow/orca.md` § Check-ins. The config is a project-owned standard: show every change as a diff and write only what the user approves.

Request: $ARGUMENTS

1. **Preconditions.** The project `CLAUDE.md` declares **Runtime: Orca** and `orca status --json` works. Otherwise stop and say what is missing.

2. **Config.** If `docs/standards/checkins.md` is missing, copy it: `cp -n "${CLAUDE_PLUGIN_ROOT}/seeds/checkins.md" docs/standards/checkins.md`, then walk the user through each check-in (keep, change, or turn off). If the request asks for a change, edit only the affected check-in and add a Tuning log row. Show the diff; write on approval.

3. **Scripts.** Install the trigger checks where Orca can always find them, even after plugin updates:
   ```bash
   D="$(git rev-parse --path-format=absolute --git-common-dir)/dev-team/bin"
   mkdir -p "$D" && cp "${CLAUDE_PLUGIN_ROOT}"/bin/* "$D"/
   ```
   (The session-start hook refreshes these every session.)

4. **Reconcile.** List Orca's automations (`orca automations list --json`); the ones this command owns are named `dev-team: <check-in>`. For each check-in in the config:
   - `(off)` or removed → disable or remove its automation.
   - otherwise create it, or edit it to match:
     ```
     orca automations create --name "dev-team: <name>" --provider claude \
       --trigger <schedule> [--time HH:MM] [--day 0-6] \
       --workspace <this worktree> --workspace-mode existing --reuse-session \
       --precheck "$D/<trigger check> <name> [args]" \
       --prompt "<prompt>" --enabled
     ```
     A built-in trigger check gets the check-in's name as its first argument; a custom command is used as written. `new-tickets linear` takes the team key and workspace from `docs/standards/tickets.md` § Scope — refuse to create it when the Scope is missing.
   - The prompt (with `$D` expanded to the absolute path):
     > You are the dev-team **<role>** running the **<name>** check-in. If the `dev-team:<role>` skill is not loaded in this conversation, invoke it. Take the lock: `"$D/dev-team-lock" acquire <name>` — if it fails, stop. Job: <job>. Limits: <may>, never beyond the project's autonomy level. When done: `"$D/has-work" --mark <name>`, then `"$D/dev-team-lock" release`. Report in five lines or fewer.

5. **Verify.** Run each enabled check-in's trigger check once by hand and show whether it would run now. List the resulting automations.
