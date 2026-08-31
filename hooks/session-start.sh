#!/bin/bash
# Announce the dev-team plugin to the main conversation. Kept tiny for token efficiency.
if [ -f "${CLAUDE_PROJECT_DIR:-.}/docs/status.md" ]; then
  echo "dev-team plugin active. Workspace: docs/ (status: docs/status.md). Run roles inline via the dev-team:<role> skills (orchestrator routes — ask 'what's next?'); spawn a role's agent only for parallel work, independent review, or context relief."
else
  echo "dev-team plugin active, but this project has no docs/status.md. If the user wants to use the dev-team workflow here, run the dev-team:bootstrap skill to scaffold the workspace."
fi

# Warn when an agent's memory directory grows beyond ~64KB so the user can ask that agent to curate it.
mem_dir="${CLAUDE_PROJECT_DIR:-.}/.claude/agent-memory"
if [ -d "$mem_dir" ]; then
  oversized=$(du -sk "$mem_dir"/*/ 2>/dev/null | awk '$1 > 64 {print $2}')
  [ -n "$oversized" ] && echo "dev-team: agent memory is getting large in: $oversized — delegate to that agent with: 'Curate your memory: merge or drop stale entries and trim topic files. Do nothing else.'"
fi
