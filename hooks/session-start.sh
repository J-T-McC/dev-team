#!/bin/bash
# Announce the dev-team plugin to the main conversation. Kept tiny for token efficiency.
if [ -f "${CLAUDE_PROJECT_DIR:-.}/docs/status.md" ]; then
  echo "dev-team plugin active. Workspace: docs/ (status: docs/status.md). Delegate feature work to the dev-team agents: orchestrator, product-manager, designer, principal-engineer, task-planner, senior-developer, reviewer."
else
  echo "dev-team plugin active, but this project has no docs/status.md. If the user wants to use the dev-team workflow here, run the dev-team:bootstrap skill to scaffold the workspace."
fi
