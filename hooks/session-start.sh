#!/bin/bash
# Announce the dev-team plugin to the main conversation. Kept tiny for token efficiency.
P="${CLAUDE_PROJECT_DIR:-.}"
source "${CLAUDE_PLUGIN_ROOT}/bin/_workspace.sh" "$P"
paths="Workspace: $WS/ (status: $WS/status.md; features: $FEATURES/)."
rules="Write plainly; comment code only where the why is not obvious."
grep -qs "Workspace:\*\*" "$P/CLAUDE.local.md" && rules="Guest mode: follow this repo's own conventions and never mention dev-team outside the workspace. $rules"

if [ -f "$P/$WS/status.md" ] && grep -qs "Runtime: Orca" "$P/CLAUDE.md" "$P/CLAUDE.local.md"; then
  echo "dev-team plugin active (Orca runtime). $paths Roles run as top-level Orca peers per the plugin's workflow/orca.md; never spawn subagents. $rules"
elif [ -f "$P/$WS/status.md" ]; then
  echo "dev-team plugin active. $paths Run roles inline via the dev-team:<role> skills (orchestrator routes — ask 'what's next?'); spawn a role's agent only for parallel work, independent review, or context relief. $rules"
else
  echo "dev-team plugin active, but this project has no $WS/status.md. If the user wants to use the dev-team workflow here, run the dev-team:bootstrap skill to scaffold the workspace."
fi
[ -d "$P/$WS/product" ] && echo "dev-team: this workspace uses the old type-first layout — run /dev-team:sync to move it to feature folders."

# Warn when an agent's memory directory grows beyond ~64KB so the user can ask that agent to curate it.
mem_dir="$P/.claude/agent-memory"
if [ -d "$mem_dir" ]; then
  oversized=$(du -sk "$mem_dir"/*/ 2>/dev/null | awk '$1 > 64 {print $2}')
  [ -n "$oversized" ] && echo "dev-team: agent memory is getting large in: $oversized — delegate to that agent with: 'Curate your memory: merge or drop stale entries and trim topic files. Do nothing else.'"
fi

# Keep check-in trigger scripts where Orca automations can find them across plugin updates.
if [ -f "$P/$WS/standards/checkins.md" ]; then
  d="$(git -C "$P" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)/dev-team/bin"
  [ "$d" != "/dev-team/bin" ] && mkdir -p "$d" && cp "${CLAUDE_PLUGIN_ROOT}"/bin/* "$d"/ 2>/dev/null
fi
exit 0
