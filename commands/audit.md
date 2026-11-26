---
description: Token audit — what the team's sessions pay to read files and load at start, the bloat behind it, and trims on approval.
argument-hint: "[days, default 7]"
---

Find what the team's frequently read and always-loaded files cost in tokens, and trim the bloat without changing what any rule means. Run it in the coordinator's conversation. `<ws>` is the workspace root: `source "${CLAUDE_PLUGIN_ROOT}/bin/_workspace.sh" . && echo $WS`.

Request: $ARGUMENTS

1. **Measure.** Run `"${CLAUDE_PLUGIN_ROOT}/bin/token-audit" --days <N> .` (N from the request, default 7) and read only its summary; never open the transcripts. It lists the files that cost the most to read, whole-file and partial, with their readers (peer home, inline role, or agent), then the totals per reader.

2. **Size.** The same output lists what every session loads, with sizes: the `CLAUDE.md` chain and its imports, the dev-team section and its Team setup, the memory index, and the SessionStart hook output sessions actually got. Then the workspace documents over the size limit (`<ws>/standards/documentation.md` § Size and reading; 25 KB by default) that were read or changed in the window.

3. **Find bloat** in the always-loaded files and the most-read files. Read each by section: its headings first (`grep -n '^#' <file>`), then only the parts in question. Look for:
   - the same rule stated in two always-loaded places: it stays in its canonical home, and the other place keeps at most a one-line reference;
   - rules or helpers marked off, retired, superseded or done;
   - dated history and run logs inside rules: they belong in the friction log, a fix record, or git;
   - coordinator-only material that every peer loads: it moves to a file only the coordinator reads, behind a one-line pointer;
   - a frequently read file with no headings, or one section holding most of it, so nobody can read part of it: one heading per entry;
   - a live document over the limit or often read whole: its owning role replaces superseded text in place and splits it into part files.

   Expected saving: the share of a file cut × its weekly read cost, or, for an always-loaded file, the tokens cut × sessions per week.

4. **Report** one short table, the largest saving first, and the total:

   | File | Cost / week | Fix | Expected saving |
   |---|---|---|---|

   Then apply only what is approved:
   - checked-in files that agents load (`CLAUDE.md`, `AGENTS.md`, `.claude/rules/`, project skills): the Owner (`${CLAUDE_PLUGIN_ROOT}/workflow/friction.md` § Fixing);
   - the project's own local files (`CLAUDE.local.md`, memories, helper notes): the coordinator, unless autonomy is *supervised*, when the Owner approves (`${CLAUDE_PLUGIN_ROOT}/workflow/handoffs.md` § Autonomy);
   - workspace documents: the role that owns each one makes the change, as a doc correction;
   - the plugin's own files: a suggestion to the Owner for the plugin.

   **Never change what a rule means.** Cut repeats, retired text and history; reword only to say the same thing in fewer words. Not sure a cut keeps the meaning → leave it, and list it in the table as a question for the Owner.

5. **Record** the run as one friction-log entry titled `Token audit <YYYY-MM-DD>` (area: token burns; `${CLAUDE_PLUGIN_ROOT}/workflow/friction.md` § Logging): the window and session count, the total read cost and whole-file share, the top costs, what changed with its expected saving, and what still waits, on whom. The next audit compares against it.
