---
description: Set up or tune the Orca runtime: the Runtime line, the subagent deny, and optionally the recommended team setup. Shows every change; writes on approval.
argument-hint: "[recommended [small | medium | large] | a change, e.g. 'advisor off']"
---

Set up or change how this project runs under Orca. Rules: `${CLAUDE_PLUGIN_ROOT}/workflow/orca.md`. The recommended setup, and why each value: `${CLAUDE_PLUGIN_ROOT}/workflow/orca-recommended.md`. The dev-team section is in `CLAUDE.md`, or `CLAUDE.local.md` in guest mode. Show every change as a diff; write only what the Owner approves.

Request: $ARGUMENTS

1. **Preconditions.** `orca status --json` works; otherwise stop and say Orca is not reachable. `<ws>` is the workspace root: `source "${CLAUDE_PLUGIN_ROOT}/bin/_workspace.sh" . && echo $WS`.

2. **Which setup.** No Runtime line yet → offer two choices: the **recommended setup** (one choice that sets everything below) or **just the runtime** (ask Team model, Fallback model, and Advisor, `workflow/orca.md` § Launch settings). `recommended` as the request → step 4, whether or not a Runtime line exists. **Size:** the one the request names; otherwise suggest the one `"${CLAUDE_PLUGIN_ROOT}/bin/setup-detect"` gives in `suggest.runtime` (`orca-small`, `-medium`, `-large`; small when it suggests none), with the table in `workflow/orca-recommended.md` § Team shape. A Runtime line already there and any other request → change only what it asks.

3. **Runtime line and subagent deny.** Write the Runtime line under the dev-team section's Rules (`workflow/orca.md` § Opt in). Make sure the subagent tool is denied: `"permissions": { "deny": ["Agent"] }` in `.claude/settings.json`, or in guest mode `.claude/settings.local.json`, never their settings.

4. **Recommended setup.** From `${CLAUDE_PLUGIN_ROOT}/seeds/orca-recommended.md`:
   - **Runtime line:** use the seed's, keeping any value the project already set unless the Owner takes the preset's.
   - **Team setup section:** append it to the dev-team section, replacing an older copy, with the Homes rule listing only the chosen size's homes. Ask the Owner for each `⟨…⟩` value, one at a time; a skipped one stays as `⟨…⟩`.
   - **When to make the team:** ask, once the section is written, unless setup already has the answer. **As work needs them (Recommended):** each home's worktree is made on its first task, so a role the project never uses costs nothing. **All now:** run `"${CLAUDE_PLUGIN_ROOT}/bin/peer" team --create`: every home's worktree at once, shown by name in Orca's sidebar; no session starts, and no usage is spent, until a home's first task. Then show `peer team`: who is who.
   - **Tests:** if `<ws>/standards/testing.md` has the seed's `The Senior Developer runs the full suite before marking any task complete.`, replace it with `Mid-work, the Senior Developer runs only the tests for what changed; related suites run at the end, and the full suite when the coordinator's spec says so (dev-team section § Team setup).` The Reviewer's own run stays.
   - **Workspace:** committed with the code → leave the Workspace rule out and keep the project's choice; moving it is a separate decision (`/dev-team:sync` moves files). Not committed → ask for a remote, then `git -C <ws> remote add origin <url>` and `git -C <ws> push -u origin HEAD`; the Stop hook pushes after that.
   - **Owner board:** no `**Owner board:**` line → offer `/dev-team:board`.

5. **Report** what changed. Live peers take a changed model line now with `peer switch`, run in the same turn, and the Team setup rules from their next dispatch. Homes from an earlier layout keep their worktrees until their next dispatch names a new one (`--worktree new-top-level --name <home>`).
